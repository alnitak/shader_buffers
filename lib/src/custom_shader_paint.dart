import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:shader_buffers/src/imouse.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

typedef ShaderBuilder = void Function(Size size);

///
class CustomShaderPaint extends MultiChildRenderObjectWidget {
  /// Creates a widget that delegates shader layers painting.
  const CustomShaderPaint({
    required this.mainImage,
    required this.buffers,
    required this.iTime,
    required this.iFrame,
    required this.iMouse,
    this.width,
    this.height,
    this.builder,
    this.relayout = 0,
    super.key,
    super.children,
  });

  /// Mark need layout. Used ie when rewind shader.
  final int? relayout;

  /// Callback which return this widget size.
  final ShaderBuilder? builder;

  /// Main layer shader. The result of this is the one displayed by this widget.
  final LayerBuffer mainImage;

  /// Other optional channels.
  final List<LayerBuffer> buffers;

  /// The time since the shader was started.
  final double iTime;

  /// The actual frame number since the shader was started.
  final double iFrame;

  /// Current mouse gesture.
  final IMouse iMouse;

  /// Widget width.
  final double? width;

  /// Widget height.
  final double? height;

  @override
  RenderCustomShaderPaint createRenderObject(BuildContext context) {
    return RenderCustomShaderPaint(
      mainImage: mainImage,
      buffers: buffers,
      iTime: iTime,
      iFrame: iFrame,
      iMouse: iMouse,
      width: width,
      height: height,
      builder: builder,
      relayout: relayout!,
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
      ..width = width
      ..height = height
      ..buffers = buffers
      ..builder = builder
      ..relayout = relayout!;
  }
}

/// TODO: remove this
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
    required int relayout,
    double? width,
    double? height,
    List<LayerBuffer> buffers = const [],
    ShaderBuilder? builder,
  })  : _mainImage = mainImage,
        _iTime = iTime,
        _iFrame = iFrame,
        _iMouse = iMouse,
        _width = width,
        _height = height,
        _buffers = buffers,
        _builder = builder,
        _relayout = relayout;

  late final TapAndPanGestureRecognizer _tapGestureRecognizer;
  var hasChildWidgets = false;

  int get relayout => _relayout;
  int _relayout;
  set relayout(int value) {
    if (relayout == value) {
      return;
    }
    _relayout = value;
    markNeedsLayout();
  }

  ShaderBuilder? get builder => _builder;
  ShaderBuilder? _builder;
  set builder(ShaderBuilder? value) {
    if (builder == value) {
      return;
    }
    _builder = value;
  }

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

  double? get width => _width;
  double? _width;
  set width(double? value) {
    if (width == value) {
      return;
    }
    _width = value;
    markNeedsLayout();
  }

  double? get height => _height;
  double? _height;
  set height(double? value) {
    if (height == value) {
      return;
    }
    _height = value;
    markNeedsLayout();
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

  /// Initialize all the shaders used
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

  // @override
  // void detach() {
  //   super.detach();
  // }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    shaderInitialized = false;
    /// Add a RenderBox if there are no children
    if (childCount == 0) {
      add(RenderImage());
    }
    loadShaders().then((value) {
      shaderInitialized = value;
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
    /// TODO: test for different parent layout (ie inside column)
    /// firstChild is always [mainImage], the others are the buffers
    RenderBox? child = lastChild;

    double w = width ?? constraints.maxWidth;
    double h = height ?? constraints.maxHeight;
    if (w > constraints.maxWidth) w = constraints.maxWidth;
    if (h > constraints.maxHeight) h = constraints.maxHeight;

    Size sizeWithChildren = constraints.biggest;
    Size sizeWithoutChildren = constraints.biggest;
    hasChildWidgets = false;

    /// Loop from last [buffer] to the first and then [mainImage] as
    /// passed to this RenderBox.
    /// Get the widget size:
    /// - if there is a child widget, get the first and give it to this widget
    /// - if there are only images, the first is the resulting size
    while (child != null) {
      final childParentData = child.parentData as CustomShaderParentData?;

      if (child is RenderImage) {
        child.layout(
          BoxConstraints(maxWidth: w, maxHeight: h, minWidth: w, minHeight: h),
          parentUsesSize: true,
        );
        sizeWithoutChildren = Size(w, h);
      } else {
        hasChildWidgets = true;
        child.layout(
          BoxConstraints(maxWidth: w, maxHeight: h),
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

    _builder?.call(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty || !shaderInitialized) {
      return;
    }
    assert(offset == Offset.zero, '');

    for (var i = 0; i < buffers.length; i++) {
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
      mainImage.layerImage ?? mainImage.blankImage!,
      Offset.zero,
      Paint(),
    );

    /// If we will want to have some fun..
    // paintImage(
    //   canvas: context.canvas,
    //   rect: offset & size,
    //   image: mainImage.layerImage ?? mainImage.blankImage!,
    // );
  }
}
