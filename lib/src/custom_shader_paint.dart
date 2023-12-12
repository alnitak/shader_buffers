// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

///
class CustomShaderPaint extends SingleChildRenderObjectWidget {
  /// Creates a widget that delegates its painting.
  const CustomShaderPaint({
    required this.mainImage,
    super.key,
    this.buffers,
  });

  /// Main layer shader.
  final LayerBuffer mainImage;

  /// Other optional channels
  final List<LayerBuffer>? buffers;
  
  @override
  RenderCustomShaderPaint createRenderObject(BuildContext context) {
    return RenderCustomShaderPaint(
      mainImage: mainImage,
      buffers: buffers,
    );
  }
}

///
class RenderCustomShaderPaint extends RenderProxyBox {
  /// Creates a render object that delegates its painting.
  RenderCustomShaderPaint({
    required this.mainImage,
    this.buffers,
    Size preferredSize = Size.zero,
  })  : _preferredSize = preferredSize;

  /// Main layer shader.
  final LayerBuffer mainImage;

  /// Other optional channels
  final List<LayerBuffer>? buffers;

  /// The size that this [RenderCustomShaderPaint] should aim for, given
  /// the layout constraints, if there is no child.
  ///
  /// Defaults to [Size.zero].
  ///
  /// If there's a child, this is ignored, and the size of the child is used
  /// instead.
  Size get preferredSize => _preferredSize;
  Size _preferredSize;
  set preferredSize(Size value) {
    if (preferredSize == value) {
      return;
    }
    _preferredSize = value;
    markNeedsLayout();
  }
}
