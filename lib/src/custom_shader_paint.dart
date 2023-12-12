// ignore_for_file: omit_local_variable_types

import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

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
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      mainImage: mainImage,
      buffers: buffers,
      iTime: iTime,
      iFrame: iFrame,
      iMouse: iMouse,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderCustomShaderPaint renderObject) {
    renderObject
        ..mainImage
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
  /// Creates a render object that delegates its painting.
  RenderCustomShaderPaint({
    required double devicePixelRatio,
    required LayerBuffer mainImage,
    required double iTime,
    required double iFrame,
    required IMouse iMouse,
    List<LayerBuffer> buffers = const [],
    Size preferredSize = Size.zero,
  })  : _devicePixelRatio = devicePixelRatio,
        _mainImage = mainImage,
        _iTime = iTime,
        _iFrame = iFrame,
        _iMouse = iMouse,
        _buffers = buffers,
        _preferredSize = preferredSize;

  LayerBuffer get mainImage => _mainImage;
  LayerBuffer _mainImage;

  set mainImage(LayerBuffer value) {
    if (mainImage == value) {
      return;
    }
    _mainImage = value;
    markNeedsLayout();
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

  /// The device pixel ratio.
  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio;

  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsCompositedLayerUpdate();
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
  bool get isRepaintBoundary => alwaysNeedsCompositing;

  @override
  bool get alwaysNeedsCompositing => true;

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
      ..textDirection = TextDirection.ltr
      ..onTap = () {
        print('TAPPED');
      };
  }

  @override
  void performLayout() {
    double width = 0;
    double height = 0;

    /// firstChild is always [mainImage], the others are the buffers
    RenderBox? child = lastChild;
    // while (child != null) {
    //   final childParentData = child.parentData as CustomShaderParentData?;
    //
    //   child.layout(
    //     BoxConstraints(maxWidth: constraints.maxWidth),
    //     parentUsesSize: true,
    //   );
    //   height += child.size.height;
    //   width = max(width, child.size.width);
    //
    //   child = childParentData?.nextSibling;
    // }

    var s = child?.debugDescribeChildren();

    Size sizeWithChildren = Size.zero;
    Size sizeWithoutChildren = Size.zero;
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
    if (!sizeWithChildren.isEmpty)
      size = sizeWithChildren;
    else
      size = sizeWithoutChildren;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) {
      return;
    }
    assert(offset == Offset.zero, '');

    for (var i = 0; i < (buffers.length ?? 0); i++) {
      buffers[i].computeLayer(
        size,
        _iTime,
        iFrame,
        iMouse,
      );
    }

    mainImage.computeLayer(
      size,
      iTime,
      iFrame,
      iMouse,
    );

    // defaultPaint(context, offset);
    /// Only paint firstChild which represent [mainImage]
    if (firstChild != null) {
      context.paintChild(firstChild!, offset);
    }
    // context.canvas.drawImage(
    //     mainImage.channels?.first.assetsTexture ?? mainImage.blankImage!,
    //     Offset.zero,
    //     Paint());
  }
}
