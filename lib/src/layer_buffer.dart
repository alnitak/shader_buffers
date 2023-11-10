import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shader_buffers/src/imouse.dart';

/// class to define the kind of channel textures that will
/// be used by [LayerBuffer].
///
/// Only one of the parameters can be given.
class IChannelSource {
  ///
  IChannelSource({
    this.buffer,
    this.assetsImage,
  })  : assert(
          !(buffer == null && assetsImage == null),
          '[buffer] or [assetsImage] must be given!',
        ),
        assert(
          !(buffer != null && assetsImage != null),
          'Only [buffer] or [assetsImage] must be given!',
        );

  /// the buffer id number used by this [IChannelSource]
  final int? buffer;

  /// the assets image path used by this [IChannelSource]
  final String? assetsImage;

  /// the assets image computed whithin [LayerBuffer] init()
  ui.Image? loadedImage;
}

/// Class used to define a buffer or a main image.
///
/// It takes the [shaderAssetsName] and a list of [IChannelSource]
/// used as textures.
///
/// ```dart
/// final bufferA = LayerBuffer(
///   shaderAssetsName: 'assets/shaders/shader3_bufferA.glsl',
///   channels: [
///     /// fragment 'iChannel0' uses buffer id 0
///     IChannelSource(buffer: 0),
///     /// fragment 'iChannel1' uses an assets image
///     IChannelSource(assetsImage: 'assets/bricks.jpg'),
///   ],
/// );
/// ```
class LayerBuffer {
  ///
  LayerBuffer({
    required this.shaderAssetsName,
    this.channels,
  });

  /// The fragment shader source to use
  final String shaderAssetsName;

  /// the channels this shader will use
  final List<IChannelSource>? channels;

  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;

  /// The image computed in the previous frame
  ui.Image? prevLayerImage;

  /// The last image computed
  ui.Image? layerImage;

  /// Used internally when shader or channel are not yet initialized
  late ui.Image _blankImage;

  /// Initialize the shader and the iChannels if any
  Future<bool> init() async {
    await Future.wait<void>([
      _loadIAssetsImages(),
      _loadShader(),
    ]);
    debugPrint('$shaderAssetsName init ${_program != null && _shader != null}');
    return _program != null && _shader != null;
  }

  Future<void> _loadShader() async {
    try {
      _program = await ui.FragmentProgram.fromAsset(shaderAssetsName);
      _shader = _program?.fragmentShader();
    } on Exception catch (e) {
      debugPrint('Cannot load shader $shaderAssetsName! $e');
    }
  }

  /// load all assets images and put into [IChannelSource.loadedImage]
  Future<void> _loadIAssetsImages() async {
    /// setup blankImage. Displyed when the layerImage is not yet available
    final assetImageByteData = await rootBundle.load('assets/black_10x10.png');
    final codec = await ui.instantiateImageCodec(
      assetImageByteData.buffer.asUint8List(),
    );
    _blankImage = (await codec.getNextFrame()).image;

    if (channels == null) return;
    for (var i = 0; i < channels!.length; i++) {
      if (channels![i].assetsImage == null) continue;
      final assetImageByteData =
          await rootBundle.load(channels![i].assetsImage!);
      final codec = await ui.instantiateImageCodec(
        assetImageByteData.buffer.asUint8List(),
      );
      channels![i].loadedImage = (await codec.getNextFrame()).image;
    }
  }

  /// draw the shader into [layerImage]
  void computeLayer(
    List<LayerBuffer> layers,
    Size iResolution,
    double iTime,
    double iFrame,
    IMouse iMouse,
  ) {
    if (_shader == null) return;
    _shader!
      ..setFloat(0, iResolution.width) // iResolution
      ..setFloat(1, iResolution.height)
      ..setFloat(2, iTime) // iTime
      ..setFloat(3, iFrame) // iFrame
      ..setFloat(4, iMouse.x) // iMouse
      ..setFloat(5, iMouse.y)
      ..setFloat(6, iMouse.z)
      ..setFloat(7, iMouse.w);

    for (var i = 0; i < (channels?.length ?? 0); i++) {
      if (channels![i].assetsImage != null) {
        _shader!.setImageSampler(i, channels![i].loadedImage ?? _blankImage);
      } else {
        final img = layers[channels![i].buffer!].prevLayerImage;
        _shader!.setImageSampler(i, img ?? _blankImage);
      }
    }

    //
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder)
        .drawRect(Offset.zero & iResolution, Paint()..shader = _shader);
    final picture = recorder.endRecording();

    if (prevLayerImage != null) prevLayerImage!.dispose();
    if (layerImage != null) layerImage!.dispose();
    layerImage = picture.toImageSync(
      iResolution.width.toInt(),
      iResolution.height.toInt(),
    );
    picture.dispose();
    prevLayerImage = layerImage!.clone();
  }
}
