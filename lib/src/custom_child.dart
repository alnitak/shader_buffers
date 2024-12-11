import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shader_buffers/src/i_channel.dart';

/// Highly inspired from
/// https://github.com/jonahwilliams/flutter_shaders/blob/main/lib/src/animated_sampler.dart
/// by Jonah Williams

/// RenderBox which allow to store the snapshot of its child
/// into [layerChannel.childTexture] to be used as texture.
/// When enable the snapshot is performed otherwise the child
/// acts normal.
class CustomChildBuilder extends SingleChildRenderObjectWidget {
  ///
  const CustomChildBuilder({
    required this.enabled,
    required this.layerChannel,
    super.child,
    super.key,
  });

  final bool enabled;
  final IChannel layerChannel;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderCustomChildWidget(
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      layerChannel: layerChannel,
      enabled: enabled,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _RenderCustomChildWidget)
      ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context)
      ..layerChannel = layerChannel
      ..enabled = enabled;
  }
}

///
class _RenderCustomChildWidget extends RenderProxyBox {
  ///
  _RenderCustomChildWidget({
    required double devicePixelRatio,
    required IChannel layerChannel,
    required bool enabled,
  })  : _devicePixelRatio = devicePixelRatio,
        _layerChannel = layerChannel,
        _enabled = enabled;

  /// The device pixel ratio used to create the child image.
  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;

  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsCompositedLayerUpdate();
  }

  bool get enabled => _enabled;
  bool _enabled;

  set enabled(bool value) {
    if (value == enabled) {
      return;
    }
    _enabled = value;
    markNeedsPaint();
    markNeedsCompositingBitsUpdate();
  }

  ///
  IChannel get layerChannel => _layerChannel;
  IChannel _layerChannel;

  set layerChannel(IChannel value) {
    if (value == layerChannel) {
      return;
    }
    _layerChannel = value;
    markNeedsCompositedLayerUpdate();
  }

  @override
  bool get isRepaintBoundary => alwaysNeedsCompositing;

  @override
  bool get alwaysNeedsCompositing => enabled;

  @override
  OffsetLayer updateCompositedLayer({
    required covariant _CustomChildLayer? oldLayer,
  }) {
    final layer = (oldLayer ?? _CustomChildLayer(layerChannel))
      ..size = size
      ..devicePixelRatio = devicePixelRatio;
    return layer;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      return;
    }
    assert(!_enabled || offset == Offset.zero, '');
    return super.paint(context, offset);
  }
}

/// The layer that creates and save the [ui.Image] into the  [layerChannel]
class _CustomChildLayer extends OffsetLayer {
  _CustomChildLayer(this._layerChannel);

  ui.Picture? _lastPicture;

  Size get size => _size;
  Size _size = Size.zero;

  set size(Size value) {
    if (value == size) {
      return;
    }
    _size = value;
    markNeedsAddToScene();
  }

  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio = 1;

  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsAddToScene();
  }

  IChannel get layerChannel => _layerChannel;
  IChannel _layerChannel;

  set layerChannel(IChannel value) {
    if (value == layerChannel) {
      return;
    }
    _layerChannel = value;
    markNeedsAddToScene();
  }

  ui.Image _buildChildScene(Rect bounds, double pixelRatio) {
    final builder = ui.SceneBuilder();
    final transform = Matrix4.diagonal3Values(pixelRatio, pixelRatio, 1);
    builder.pushTransform(transform.storage);
    addChildrenToScene(builder);
    builder.pop();
    return builder.build().toImageSync(
          (pixelRatio * bounds.width).ceil(),
          (pixelRatio * bounds.height).ceil(),
        );
  }

  @override
  void dispose() {
    _lastPicture?.dispose();
    super.dispose();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (size.isEmpty) return;
    final image = _buildChildScene(
      offset & size,
      devicePixelRatio,
    );
    final pictureRecorder = ui.PictureRecorder();
    // final canvas =
    Canvas(pictureRecorder);
    try {
      _layerChannel.childTexture = image.clone();
    } finally {
      image.dispose();
    }
    final picture = pictureRecorder.endRecording();
    _lastPicture?.dispose();
    _lastPicture = picture;
    builder.addPicture(offset, picture);
  }
}
