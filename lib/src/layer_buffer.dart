// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shader_buffers/src/i_channel.dart';

import 'package:shader_buffers/src/imouse.dart';
import 'package:shader_buffers/src/uniforms.dart';

/// Class used to define a buffers or the main image layer.
///
class LayerBuffer {
  /// Class used to define a buffers or the main image.
  ///
  /// It takes the [shaderAssetsName] and a list of [IChannel]
  /// used as textures.
  ///
  /// ```dart
  /// final bufferA = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader3_bufferA.glsl',
  /// );
  /// // you can then set optional channels:
  /// bufferA.setChannels([
  ///   IChannel(assetsTexturePath: 'assets/bricks.jpg'),
  /// ]);
  /// ```
  LayerBuffer({
    required this.shaderAssetsName,
    this.scaleRenderView = 1,
    this.uniforms,
  }) : assert(scaleRenderView > 0, 'scaleRenderView must be > 0');

  /// The fragment shader source to use
  final String shaderAssetsName;

  /// Scale the rendered window.
  ///
  /// It happens that a shader could be computationally heavy.
  /// You can reduce the resolution of the rendered window: by setting
  /// [scaleRenderView] to 0.5 for example, you will get a half
  /// resolution image. But this could cause pixelation. If you want instead
  /// to get a higher resolution image, ie for zooming, you can set the value
  /// to 2.
  final double scaleRenderView;

  /// additional uniforms
  Uniforms? uniforms;

  /// the channels this shader will use
  List<IChannel>? channels;

  /// the fragment program used by this layer
  ui.FragmentProgram? _program;

  /// the fragment shader used by this layer
  ui.FragmentShader? _shader;

  /// The last image computed
  ui.Image? layerImage;

  /// Used internally when shader or channel are not yet initialized
  ui.Image? blankImage;

  double _deviceAspectRatio = 1;

  List<void Function()> conditionalOperation = [];

  /// set channels of this layer
  void setChannels(List<IChannel> chan) {
    channels = chan.toList();
  }

  /// Initialize the shader and the textures if any
  Future<bool> init() async {
    var loaded = true;
    loaded = await _loadShader();
    loaded &= await _loadAssetsTextures();
    _deviceAspectRatio =
        PlatformDispatcher.instance.displays.first.devicePixelRatio;
    debugPrint('LayerBuffer.init() loaded: $loaded  $shaderAssetsName');
    return loaded;
  }

  /// load fragment shader
  Future<bool> _loadShader() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(shaderAssetsName);
      _shader = _program?.fragmentShader();
    } on Exception catch (e) {
      debugPrint('Cannot load shader $shaderAssetsName! $e');
      return false;
    }
    return true;
  }

  /// load the blank image and initialize all channel textures
  Future<bool> _loadAssetsTextures() async {
    /// setup blankImage. Displayed when the layerImage is not yet available
    try {
      final assetImageByteData = await rootBundle
          .load('packages/shader_buffers/assets/blank_16x16.bmp');
      final codec = await ui.instantiateImageCodec(
        assetImageByteData.buffer.asUint8List(),
      );
      blankImage = (await codec.getNextFrame()).image;
    } on Exception catch (e) {
      debugPrint('Cannot load blankImage! $e');
      return false;
    }

    // Load all the assets textures if any
    if (channels == null) return true;
    for (var i = 0; i < channels!.length; ++i) {
      for (final element in channels!) {
        if (!element.isInited) {
          if (!await channels![i].init()) return false;
        }
      }
    }
    return true;
  }

  void dispose() {
    // _shader?.dispose();
    layerImage?.dispose();
    layerImage = null;
  }

  /// Draw the shader into [layerImage].
  ///
  /// Using the same [layerImage] of this layer as the input texture,
  /// cause a memory leak:
  /// https://github.com/flutter/flutter/issues/138627
  ///
  /// Clear unfreed cached mem on linux
  /// sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
  void computeLayer(
    Size iResolution,
    double iTime,
    double iFrame,
    IMouse iMouse,
  ) {
    if (_shader == null) return;

    final realPixels = iResolution * _deviceAspectRatio * scaleRenderView;

    _shader!
      ..setFloat(0, realPixels.width) // iResolution
      ..setFloat(1, realPixels.height)
      ..setFloat(2, iTime) // iTime
      ..setFloat(3, iFrame) // iFrame
      ..setFloat(4, iMouse.x) // iMouse
      ..setFloat(5, iMouse.y)
      ..setFloat(6, iMouse.z)
      ..setFloat(7, iMouse.w);

    /// eventually add more floats uniforms from [floatsUniforms]
    for (var i = 0; i < (uniforms?.uniforms.length ?? 0); i++) {
      _shader!.setFloat(i + 8, uniforms!.uniforms[i].value);
    }

    /// eventually add sampler2D uniforms
    for (var i = 0; i < (channels?.length ?? 0); i++) {
      if (channels![i].assetsTexturePath != null) {
        _shader!.setImageSampler(i, channels![i].assetsTexture ?? blankImage!);
      } else if (channels![i].child != null) {
        _shader!.setImageSampler(i, channels![i].childTexture ?? blankImage!);
      } else {
        _shader!.setImageSampler(
          i,
          channels![i].isSelf
              ? layerImage ?? blankImage!
              : channels![i].buffer?.layerImage ?? blankImage!,
        );
      }
    }

    /// While this issue
    /// https://github.com/flutter/flutter/issues/138627
    /// is still open, here the [toImage] will be used instead of [toImageSync]
    ///
    // layerImage?.dispose();
    // layerImage = null;

    // final recorder = ui.PictureRecorder();
    // ui.Canvas(recorder).drawRect(
    //   Offset.zero & iResolution,
    //   ui.Paint()..shader = _shader,
    // );
    // final picture = recorder.endRecording();
    // layerImage = picture.toImageSync(
    //   iResolution.width.ceil(),
    //   iResolution.height.ceil(),
    // );
    // picture.dispose();

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawRect(
      Offset.zero & realPixels,
      ui.Paint()..shader = _shader,
    );
    final picture = recorder.endRecording();
    picture
        .toImage(
          realPixels.width.ceil(),
          realPixels.height.ceil(),
        )
        .then((value) => layerImage = value);
    picture.dispose();

    for (final f in conditionalOperation) {
      f();
    }
  }
}
