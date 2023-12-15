// ignore_for_file: omit_local_variable_types

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shader_buffers/src/imouse.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

///
class CustomShaderPaint extends MultiChildRenderObjectWidget {
  /// Creates a widget that delegates its painting.
  const CustomShaderPaint({
    required this.mainImage,
    required this.iTime,
    required this.iFrame,
    required this.iMouse,
    required this.buffers,
    super.key,
    super.children,
  });

  /// Main layer shader.
  final LayerBuffer mainImage;

  /// Other optional channels.
  final List<LayerBuffer> buffers;

  final double iTime;
  final double iFrame;
  final IMouse iMouse;

  @override
  RenderCustomShaderPaint createRenderObject(BuildContext context) {
    return RenderCustomShaderPaint(
      mainImage: mainImage,
      buffers: buffers,
      iTime: iTime,
      iFrame: iFrame,
      iMouse: iMouse,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomShaderPaint renderObject) {
    renderObject
      ..mainImage = mainImage
      ..iTime = iTime
      ..iFrame = iFrame
      ..iMouse = iMouse
      ..buffers = buffers;
  }
}

///
// class CustomExpandedShader extends ParentDataWidget<CustomShaderParentData> {
//   ///
//   const CustomExpandedShader({
//     required super.child,
//     this.flex = 1,
//     super.key,
//   }) : assert(flex > 0, '');

//   final int flex;

//   @override
//   void applyParentData(RenderObject renderObject) {
//     final parentData = renderObject.parentData as CustomShaderParentData?;

//     if (parentData != null && parentData.flex != flex) {
//       parentData.flex = flex;
//       final targetObject = renderObject.parent;
//       if (targetObject is RenderObject) {
//         targetObject.markNeedsLayout();
//       }
//     }
//   }

//   @override
//   Type get debugTypicalAncestorWidgetClass => CustomShaderPaint;
// }

class CustomShaderParentData extends ContainerBoxParentData<RenderBox> {
  int? flex;
}

///
class RenderCustomShaderPaint extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, CustomShaderParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, CustomShaderParentData> {
  ///
  RenderCustomShaderPaint({
    required LayerBuffer mainImage,
    required double iTime,
    required double iFrame,
    required IMouse iMouse,
    List<LayerBuffer> buffers = const [],
    Size preferredSize = Size.zero,
  })  : _mainImage = mainImage,
        _iTime = iTime,
        _iFrame = iFrame,
        _iMouse = iMouse,
        _buffers = buffers,
        _preferredSize = preferredSize;

  late final TapAndPanGestureRecognizer _tapGestureRecognizer;
  var hasChildWidgets = false;

  LayerBuffer get mainImage => _mainImage;
  LayerBuffer _mainImage;

  set mainImage(LayerBuffer value) {
    if (mainImage == value) {
      return;
    }
    _mainImage = value;

    /// When the layer change, reload the shaders
    shaderInitialized = false;
    loadShaders().then((value) {
      shaderInitialized = value;
      if (value) markNeedsLayout();
    });
  }

  List<LayerBuffer> get buffers => _buffers;
  List<LayerBuffer> _buffers;

  set buffers(List<LayerBuffer> value) {
    if (buffers == value) {
      return;
    }
    _buffers = value;
    markNeedsLayout();
  }

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

  double get iTime => _iTime;
  double _iTime;

  set iTime(double value) {
    if (_iTime == value) {
      return;
    }
    _iTime = value;
    // markNeedsLayout();
    markNeedsPaint();
  }

  double get iFrame => _iFrame;
  double _iFrame;

  set iFrame(double value) {
    if (iFrame == value) {
      return;
    }
    _iFrame = value;
    // markNeedsLayout();
    markNeedsPaint();
  }

  IMouse get iMouse => _iMouse;
  IMouse _iMouse;

  set iMouse(IMouse value) {
    if (iMouse == value) {
      return;
    }
    _iMouse = value;
    // markNeedsLayout();
    markNeedsPaint();
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool get isRepaintBoundary => alwaysNeedsCompositing;

  @override
  bool get alwaysNeedsCompositing => true;

  var shaderInitialized = false;

  Future<bool> loadShaders() async {
    var initialized = true;

    /// Eventually dispose Layers
    for (var i = 0; i < _buffers.length; i++) {
      _buffers[i].dispose();
    }
    _mainImage.dispose();

    /// Initialize layers
    for (var i = 0; i < _buffers.length; i++) {
      initialized &= await _buffers[i].init();
    }
    initialized &= await _mainImage.init();
    shaderInitialized = initialized;
    return initialized;
  }

  @override
  void dispose() {
    /// Eventually dispose Layers
    for (var i = 0; i < _buffers.length; i++) {
      _buffers[i].dispose();
    }
    _mainImage.dispose();
    super.dispose();
  }

  @override
  void detach() {
    super.detach();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    shaderInitialized = false;
    loadShaders().then((value) {
      shaderInitialized = value;
      // if (value) markNeedsLayout();
    });
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! CustomShaderParentData) {
      child.parentData = CustomShaderParentData();
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    config
      ..isImage = true
      ..hint = 'Shader renderer'
      ..textDirection = TextDirection.ltr;
  }

  @override
  void performLayout() {
    double width = 0;
    double height = 0;

    /// firstChild is always [mainImage], the others are the buffers
    RenderBox? child = lastChild;

    Size sizeWithChildren = constraints.biggest;
    Size sizeWithoutChildren = constraints.biggest;
    hasChildWidgets = false;
    while (child != null) {
      final childParentData = child.parentData as CustomShaderParentData?;

      if (child is RenderImage) {
        child.layout(
          BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
            minWidth: constraints.maxWidth,
            minHeight: constraints.maxHeight,
          ),
          parentUsesSize: true,
        );
        sizeWithoutChildren = Size(constraints.maxWidth, constraints.maxHeight);
      } else {
        hasChildWidgets = true;
        child.layout(
          BoxConstraints(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          ),
          parentUsesSize: true,
        );
        sizeWithChildren = child.size;
      }

      child = childParentData?.previousSibling;
    }
    if (hasChildWidgets) {
      size = sizeWithChildren;
    } else {
      size = sizeWithoutChildren;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty || !shaderInitialized) {
      return;
    }
    assert(offset == Offset.zero, '');

    for (var i = 0; i < (buffers.length ?? 0); i++) {
      buffers[i].computeLayer(size, iTime, iFrame, iMouse);
    }

    mainImage.computeLayer(size, iTime, iFrame, iMouse);

    /// Only paint firstChild which represent [mainImage]
    RenderBox? child = firstChild;

    /// Cycle from the first child, if exists, to the last, to mark
    /// them to be painted
    if (hasChildWidgets) {
      while (child != null) {
        final childParentData = child.parentData as CustomShaderParentData?;
        context.paintChild(child, offset);
        child = childParentData?.nextSibling;
      }
    }
    context.canvas.drawImage(
        mainImage.layerImage ?? mainImage.blankImage!, Offset.zero, Paint());
    // paintImage(
    //   canvas: context.canvas,
    //   rect: offset & size,
    //   image: mainImage.layerImage ?? mainImage.blankImage!,
    // );
  }
}
