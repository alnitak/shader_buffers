// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

/// class to define the kind of channel textures that will
/// be used by [LayerBuffer].
///
/// Only one of the parameters can be given.
class IChannel {
  IChannel({
    this.child,
    this.buffer,
    this.assetsTexturePath,
    this.texture,
    this.isSelf = false,
  }) : assert(
          !(!isSelf &&
              child != null &&
              buffer != null &&
              assetsTexturePath != null &&
              texture != null),
          'Only [isSelf] or [child] or [buffer] or [assetsTexturePath] '
          ' or [texture] must be given!',
        );

  /// the widget used by this [IChannel]
  final Widget? child;

  /// the assets image if [child] exists
  ui.Image? childTexture;

  final bool isSelf;

  /// the buffer used by this [IChannel]
  LayerBuffer? buffer;

  /// the assets image path used by this [IChannel]
  String? assetsTexturePath;

  /// the assets image if [assetsTexturePath] exists
  ui.Image? texture;

  /// all textures loaded?
  bool isInited = false;

  // ignore: use_setters_to_change_properties
  void updateTexture(ui.Image image) => texture = image;

  /// eventually load textures
  Future<bool> init() async {
    if (isInited) return true;

    isInited = true;

    if (texture != null) return isInited;

    // Load the assets texture
    if (assetsTexturePath != null) {
      try {
        final assetImageByteData = await rootBundle.load(assetsTexturePath!);
        final codec = await ui.instantiateImageCodec(
          assetImageByteData.buffer.asUint8List(),
        );
        texture = (await codec.getNextFrame()).image;
      } catch (e) {
        debugPrint('Error loading assets image! $e');
        isInited = false;
      }
    }

    return isInited;
  }
}
