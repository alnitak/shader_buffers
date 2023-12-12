// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shader_buffers/src/animated_sampler.dart';
import 'package:shader_buffers/src/custom_shader_paint.dart';
import 'package:shader_buffers/src/imouse.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

/// the operation parameter to build the check
typedef Operation = ({
  /// the [LayerBuffer] which this check is binded to
  LayerBuffer layerBuffer,

  /// the parameter to check
  Param param,

  /// the type of operator to use (>, <, ==)
  CheckOperator checkType,

  /// the value to check
  double checkValue,

  /// the operation result to give back to dev
  void Function(bool result) operation,
});

/// parameter to check
enum Param {
  /// check X pointer position on the texture
  iMouseX,

  /// check X pointer position on the texture normalized to 0~1 range
  iMouseXNormalized,

  /// check Y pointer position on the texture
  iMouseY,

  /// check Y pointer position on the texture normalized to 0~1 range
  iMouseYNormalized,

  /// check current iTime
  iTime,

  /// check current iFrame
  iFrame,
}

/// Type of check to use (>, <, ==)
enum CheckOperator {
  /// <
  minor,

  /// >
  major,

  /// ==
  equal,
}

/// Current state of the [ShaderBuffers] widget.
enum ShaderState {
  none,
  paused,
  playing,
}

///
class ShaderController {
  void Function(Operation)? _addConditionalOperation;
  VoidCallback? _pause;
  VoidCallback? _play;
  VoidCallback? _rewind;
  ShaderState Function()? _getState;
  IMouse Function()? _getIMouse;
  IMouse Function()? _getIMouseNormalized;

  /// list of all defined operations for this controller
  List<Operation> conditionalOperation = [];

  void _setController(
    void Function(Operation) addConditionalOperation,
    VoidCallback pause,
    VoidCallback play,
    VoidCallback rewind,
    ShaderState Function() getState,
    IMouse Function() getIMouse,
    IMouse Function() getIMouseNormalized,
  ) {
    _addConditionalOperation = addConditionalOperation;
    _pause = pause;
    _play = play;
    _rewind = rewind;
    _getState = getState;
    _getIMouse = getIMouse;
    _getIMouseNormalized = getIMouseNormalized;
  }

  /// add an operation for checking on every frame using the given [params]
  ///
  /// ```dart
  /// // on every frame this will be checked in [shader.mainImage] buffer.
  /// // The [operation] callback will send back the
  /// // result of '(iMouseXNormalized is < 0.5)`
  /// controller.addConditionalOperation(
  ///   (
  ///     layerBuffer: shader.mainImage,
  ///     param: Param.iMouseXNormalized,
  ///     checkType: CheckOperator.minor,
  ///     checkValue: 0.5,
  ///     operation: (result) {
  ///       print('(iMouseXNormalized is < 0.5) is $result');
  ///     },
  ///   ),
  /// );
  /// ```
  void addConditionalOperation(Operation params) {
    if (_addConditionalOperation == null) {
      conditionalOperation.add(params);
    } else {
      _addConditionalOperation?.call(params);
    }
  }

  /// pause
  void pause() => _pause?.call();

  /// play
  void play() => _play?.call();

  /// reset time to zero
  void rewind() => _rewind?.call();

  /// return the state
  ShaderState getState() => _getState?.call() ?? ShaderState.none;

  /// get the mouse position
  IMouse getIMouse() => _getIMouse?.call() ?? IMouse.zero;

  /// get the mouse position normalized to 0~1
  IMouse getIMouseNormalized() => _getIMouseNormalized?.call() ?? IMouse.zero;
}

/// Widget to paint the shader with the given [LayerBuffer]s.
///
class ShaderBuffers extends StatefulWidget {
  /// [mainImage] shader must be given.
  /// The more [buffers] the more performaces will be affected.
  ///
  /// Think of [mainImage] as the `Image` layer fragment
  /// and [buffers] as `Buffer[A-D]` in ShaderToy.com
  /// [mainImage] layer image is the one displayed.
  ///
  /// Each image [buffers] are computed from the 1st to the last,
  /// then [mainImage] that will display the resulting image.
  ///
  /// This widget provides to the fragment shader the following uniforms:
  /// * `sampler2D iChannel[0-N] as many as defined in [LayerBuffer.channels]
  /// * `vec2 iResolution` the widget width and height
  /// * `float iTime` the current time in seconds from the start of rendering
  /// * `float iFrame` the currentrendering frame number
  /// * `vec4 iMouse` for the user interaction with pointer. See [IMouse]
  ///
  /// ```dart
  /// /// The main layer uses `shader_main.frag` as fragment shader source and some float uniforms
  /// final mainImage = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_main.glsl',
  ///   floatUniforms: [0.5, 1],
  /// );
  /// /// This [LayerBuffer] uses 'shader_bufferA.glsl' as the fragment shader
  /// /// and a channel that uses an assets image.
  /// final bufferA = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
  /// );
  /// /// Then you can optionally assign to it the input textures needed by the fragment
  /// bufferA.setChannels([
  ///   IChannel(assetsTexturePath: 'assets/bricks.jpg'),
  /// ]);
  /// /// This [LayerBuffer] uses 'shader_bufferB.glsl' as the fragment shader
  /// /// and `bufferA` as texture
  /// final bufferB = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
  /// ),
  /// bufferB.setChannels([
  ///   IChannel(buffer: bufferA),
  /// ]);
  ///
  /// ShaderBuffer(
  ///   mainImage: mainImage,
  ///   buffers: [ bufferA, bufferB ],
  /// )
  /// ```
  ShaderBuffers({
    required this.mainImage,
    this.width,
    this.height,
    this.startPaused = false,
    this.buffers,
    ShaderController? controller,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerDownNormalized,
    this.onPointerMoveNormalized,
    this.onPointerUpNormalized,
    super.key,
  }) : controller = controller ?? ShaderController();

  /// The width of texture used by this widget if there are no layers with
  /// an IChannel using a child widget.
  final double? width;

  /// The height of texture used by this widget if there are no layers with
  /// an IChannel using a child widget.
  final double? height;

  /// Whether or not to start ticking
  final bool startPaused;

  /// Main layer shader.
  final LayerBuffer mainImage;

  /// Other optional channels
  final List<LayerBuffer>? buffers;

  /// controller for this widget.
  final ShaderController? controller;

  /// pointer callbacks to get position in texture size range.
  final void Function(ShaderController controller, Offset position)?
      onPointerDown;
  final void Function(ShaderController controller, Offset position)?
      onPointerMove;
  final void Function(ShaderController controller, Offset position)?
      onPointerUp;

  /// pointer callbacks to get normalized position 0~1 range
  final void Function(ShaderController controller, Offset position)?
      onPointerDownNormalized;
  final void Function(ShaderController controller, Offset position)?
      onPointerMoveNormalized;
  final void Function(ShaderController controller, Offset position)?
      onPointerUpNormalized;

  @override
  State<ShaderBuffers> createState() => _ShaderBuffersState();
}

class _ShaderBuffersState extends State<ShaderBuffers>
    with TickerProviderStateMixin {
  Ticker? ticker;
  late Stopwatch iTime;
  late IMouseController iMouse;
  late double iFrame;
  late bool isInited;
  late bool startPausedAccomplished;
  late ShaderState state;
  late Offset startingPosition;
  late bool hasChildren;
  late BoxConstraints previousConstraints;

  /// If mainImage has child widget(s), use that widget size instead
  /// overriding the given [widget.width] and [widget.height].
  /// The last child widget in [widget.mainImage.channels] list will
  /// be considered to change the size. If it has not child widget(s),
  /// [widget.buffers] list will be considered.
  Size? mainImageSize;

  /// if a new [mainImageSize] is set, this value is true and not set again
  late bool mainImageSizeChanged;

  @override
  void initState() {
    super.initState();

    iMouse = IMouseController(width: 10, height: 10);
    iFrame = 0;
    iTime = Stopwatch();
    ticker = createTicker(tick);

    ticker?.start();
    iTime.start();
    init();
  }

  void init() {
    isInited = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /// add the operations added before putting this in the widgets tree
      if (widget.controller!.conditionalOperation.isNotEmpty) {
        for (final f in widget.controller!.conditionalOperation) {
          _addConditionalOperation(f);
        }
        widget.controller!.conditionalOperation.clear();
      }

      isInited = false;
      var shaderInited = true;
      disposeLayers();

      for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
        shaderInited &= await widget.buffers![i].init();
      }
      shaderInited &= await widget.mainImage.init();
      iFrame = 0;
      isInited = shaderInited;

      // Check if mainImage or buffers have children widgets
      hasChildren = false;
      for (final channel in (widget.mainImage.channels ?? []).toList()) {
        hasChildren |= channel.child != null;
      }
      for (final b in (widget.buffers ?? []).toList()) {
        for (final channel in (b.channels ?? []).toList()) {
          hasChildren |= channel.child != null;
        }
      }

      tick(Duration.zero);
      if (context.mounted) {
        setState(() {
          tick(Duration.zero);
        });
      }
    });
  }

  void _pause() {}

  void _play() {}

  void _rewind() {}

  ShaderState _getState() => state;

  void _addConditionalOperation(Operation p) {
    switch (p.param) {
      case Param.iMouseX:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.x < p.checkValue);
                }
              },
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.x > p.checkValue);
                }
              },
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.x == p.checkValue);
                }
              },
            );
        }

      case Param.iMouseXNormalized:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().x < p.checkValue);
                }
              },
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().x > p.checkValue);
                }
              },
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().x == p.checkValue);
                }
              },
            );
        }

      case Param.iMouseY:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.y < p.checkValue);
                }
              },
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.y > p.checkValue);
                }
              },
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.iMouse.y == p.checkValue);
                }
              },
            );
        }

      case Param.iMouseYNormalized:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().y < p.checkValue);
                }
              },
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().y > p.checkValue);
                }
              },
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () {
                if (iMouse.currState == PointerState.onPointerMove) {
                  p.operation(iMouse.getIMouseNormalized().y == p.checkValue);
                }
              },
            );
        }

      case Param.iTime:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iTime.elapsedMilliseconds < p.checkValue),
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iTime.elapsedMilliseconds > p.checkValue),
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iTime.elapsedMilliseconds == p.checkValue),
            );
        }

      case Param.iFrame:
        switch (p.checkType) {
          case CheckOperator.minor:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iFrame < p.checkValue),
            );
          case CheckOperator.major:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iFrame > p.checkValue),
            );
          case CheckOperator.equal:
            p.layerBuffer.conditionalOperation.add(
              () => p.operation(iFrame == p.checkValue),
            );
        }
    }
  }

  IMouse _getIMouse() => iMouse.iMouse;

  IMouse _getIMouseNormalized() => iMouse.iMouseNormalized;

  @override
  void didUpdateWidget(covariant ShaderBuffers oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  void dispose() {
    ticker?.dispose();
    disposeLayers();
    super.dispose();
  }

  void disposeLayers() {
    final tickerActive = ticker?.isActive ?? false;
    if (tickerActive) ticker?.stop();
    for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
      widget.buffers?[i].dispose();
    }
    widget.mainImage.dispose();
    if (tickerActive) ticker?.start();
  }

  /// compute layer image at every ticks
  void tick(Duration elapsed) {
    // if (mainImageSize == null) return;

    // for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
    //   widget.buffers![i].computeLayer(
    //     mainImageSize!,
    //     iTime.elapsedMilliseconds / 1000.0,
    //     iFrame,
    //     iMouse.iMouse,
    //   );
    // }

    // widget.mainImage.computeLayer(
    //   mainImageSize!,
    //   iTime.elapsedMilliseconds / 1000.0,
    //   iFrame,
    //   iMouse.iMouse,
    // );

    iFrame++;
    // // if we want to start paused, wait 2 frame before pause
    // if (!startPausedAccomplished &&
    //     widget.startPaused &&
    //     state == ShaderState.playing &&
    //     iFrame >= (hasChildren ? 6 : 2)) {
    //   startPausedAccomplished = true;
    //   _pause();
    // }
    if (context.mounted) setState(() {});
  }

  /// set the new size of this widget if not already.
  /// Gotten from the topmost IChannel wich holds a child widget.
  /// Taken from [widget.mainImage] and [widget.buffers]
  void setNewSize(Size newSize) {
    if (!mainImageSizeChanged) {
      mainImageSize = newSize;
      // setIMouse();
      mainImageSizeChanged = true;
    }
  }

  void setIMouse() {
    if (mainImageSize == null) return;
    iMouse = IMouseController(
      width: mainImageSize!.width,
      height: mainImageSize!.height,
    );
    iMouse.iMouse.x = mainImageSize!.width / 2;
    iMouse.iMouse.y = mainImageSize!.height / 2;
    iMouse.iMouse.z = -iMouse.iMouse.x;
    iMouse.iMouse.w = -iMouse.iMouse.y;
  }

  @override
  Widget build(BuildContext context) {
    if (!isInited) return const SizedBox.shrink();
    final widgets = <Widget>[];

    /// If [mainImage] uses widgets, put them into the
    /// three widgets using [AnimatedSampler]
    for (var i = 0; i < (widget.mainImage.channels?.length ?? 0); i++) {
      if (widget.mainImage.channels![i].child != null) {
        widgets.add(widget.mainImage.channels![i].child!);
      }
      if (widget.mainImage.channels![i].assetsTexturePath != null) {
        widgets.add(RawImage(image: widget.mainImage.layerImage));
      }
    }

    /// If some buffers uses widgets, put them into the
    /// three widgets using [AnimatedSampler]
    for (var n = 0; n < (widget.buffers?.length ?? 1); n++) {
      for (var i = 0; i < (widget.buffers?[n].channels?.length ?? 0); i++) {
        if (widget.buffers![n].channels![i].child != null) {
          widgets.add(widget.buffers![n].channels![i].child!);
        }
        if (widget.buffers![n].channels![i].assetsTexturePath != null) {
          widgets.add(RawImage(image: widget.buffers![n].layerImage));
        }
      }
    }

    return RepaintBoundary(
      child: CustomShaderPaint(
        mainImage: widget.mainImage,
        buffers: widget.buffers ?? [],
        iTime: iTime.elapsedMilliseconds / 1000.0,
        iFrame: iFrame,
        iMouse: IMouse(1, 1, 1, 1), //iMouse.iMouse,
        children: widgets,
      ),
    );
  }
}
