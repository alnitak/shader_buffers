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
    this.isSelf = false,
  }) : assert(
          !(!isSelf &&
              child != null &&
              buffer != null &&
              assetsTexturePath != null),
          'Only [isSelf] or [child] or [buffer] or [assetsTexturePath]'
          ' must be given!',
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
  ui.Image? assetsTexture;

  /// all textures loaded?
  bool isInited = false;

  /// eventually load textures
  Future<bool> init() async {
    if (isInited) return true;

    isInited = true;
    // Load all the assets textures
    if (assetsTexturePath != null) {
      try {
        final assetImageByteData = await rootBundle.load(assetsTexturePath!);
        final codec = await ui.instantiateImageCodec(
          assetImageByteData.buffer.asUint8List(),
        );
        assetsTexture = (await codec.getNextFrame()).image;
      } catch (e) {
        debugPrint('Error loading assets image! $e');
        isInited = false;
      }
    }

    return isInited;
  }
}
