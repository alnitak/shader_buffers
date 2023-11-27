// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shader_buffers/shader_buffers.dart';
import 'package:shader_buffers/src/animated_sampler.dart';
import 'package:shader_buffers/src/imouse.dart';

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

///
class ShaderBuffersController {
  void Function(Operation)? _addConditionalOperation;
  VoidCallback? _pause;
  VoidCallback? _play;
  VoidCallback? _rewind;
  VoidCallback? _reset;
  IMouse Function()? _getIMouse;
  IMouse Function()? _getIMouseNormalized;

  /// list of all defined operations for this controller
  List<Operation> conditionalOperation = [];

  void _setController(
    void Function(Operation) addConditionalOperation,
    VoidCallback pause,
    VoidCallback play,
    VoidCallback rewind,
    VoidCallback reset,
    IMouse Function() getIMouse,
    IMouse Function() getIMouseNormalized,
  ) {
    _addConditionalOperation = addConditionalOperation;
    _pause = pause;
    _play = play;
    _rewind = rewind;
    _reset = reset;
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
    conditionalOperation.add(params);
    _addConditionalOperation?.call(params);
  }

  /// pause
  void pause() => _pause?.call();

  /// play
  void play() => _play?.call();

  /// reset time to zero
  void rewind() => _rewind?.call();

  /// reset time and shader forcing the latter to reload
  void reset() => _reset?.call();

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
  /// then [mainImage].
  ///
  /// This widget provides to the fragment shader the following uniforms:
  /// * `sampler2D iChannel[0-N] as many as defined in [LayerBuffer.channels]
  /// * `vec2 iResolution` the widget width and height
  /// * `float iTime` the current time in seconds from the start of rendering
  /// * `float iFrame` the currentrendering frame number
  /// * `vec4 iMouse` for the user interaction with pointer. See [IMouse]
  ///
  /// ```dart
  /// /// The main layer which uses `shader_main.frag` as fragment shader source
  /// final mainImage = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_main.glsl',
  /// );
  ///
  /// /// This [LayerBuffer] uses 'shader_bufferA.glsl' as the fragment shader
  /// /// and 2 channels: the 1st is the buffer with id=1 (`bufferB`),
  /// /// the 2nd uses an assets image.
  /// final bufferA = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
  /// );
  ///
  /// /// Then you can optionally assign to it the input textures the fragment needs
  /// bufferA.setChannels([
  ///   IChannel(buffer: bufferA),
  ///   IChannel(assetsTexturePath: 'assets/bricks.jpg'),
  /// ]);
  ///
  /// /// This [LayerBuffer] uses 'shader_bufferB.glsl' as the fragment shader
  /// /// and `bufferA` with id=0
  /// final bufferB = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
  /// ),
  ///
  /// bufferB.setChannels([
  ///   IChannel(buffer: bufferA),
  /// ]);
  ///
  /// ShaderBuffer(
  ///   width: 500,
  ///   height: 300,
  ///   mainImage: mainImage,
  ///   buffers: [ bufferA, bufferB ],
  /// )
  /// ```
  ShaderBuffers({
    required this.width,
    required this.height,
    required this.mainImage,
    this.buffers,
    ShaderBuffersController? controller,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onPointerDownNormalized,
    this.onPointerMoveNormalized,
    this.onPointerUpNormalized,
    super.key,
  }) : controller = controller ?? ShaderBuffersController();

  /// The width of this widget if there are no layers with
  /// an IChannel using a child widget
  final double width;

  /// The height of this widget if there are no layers with
  /// an IChannel using a child widget
  final double height;

  /// Main layer shader
  final LayerBuffer mainImage;

  /// Other optional channels
  final List<LayerBuffer>? buffers;

  /// controller for this widget
  final ShaderBuffersController? controller;

  /// pointer callbacks to get position in texture size range
  final void Function(Offset position)? onPointerDown;
  final void Function(Offset position)? onPointerMove;
  final void Function(Offset position)? onPointerUp;

  /// pointer callbacks to get normalized position 0~1 range
  final void Function(Offset position)? onPointerDownNormalized;
  final void Function(Offset position)? onPointerMoveNormalized;
  final void Function(Offset position)? onPointerUpNormalized;

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

  /// If mainImage has child widget(s), use that widget size instead
  /// overriding the given [widget.width] and [widget.height].
  /// The last child widget in [widget.mainImage.channels] list will
  /// be considered to change the size. If it has not child widget(s), those
  /// chhild widget from [widget.buffers] list will be considered if any.
  Size? mainImageSize;

  /// if a new [mainImageSize] is set, this value is true and not set again
  late bool mainImageSizeChanged;

  @override
  void initState() {
    super.initState();

    mainImageSize = Size(widget.width, widget.height);
    mainImageSizeChanged = false;
    iMouse = IMouseController(
      width: mainImageSize!.width,
      height: mainImageSize!.height,
    );
    iMouse.iMouse.x = mainImageSize!.width / 2;
    iMouse.iMouse.y = mainImageSize!.height / 2;
    iMouse.iMouse.z = -iMouse.iMouse.x;
    iMouse.iMouse.w = -iMouse.iMouse.y;
    iFrame = 0;
    iTime = Stopwatch();
    ticker = createTicker(tick);
    iTime.start();
    ticker?.start();

    /// setup the controller for this widget
    widget.controller!._setController(
      _addConditionalOperation,
      _pause,
      _play,
      _rewind,
      _reset,
      _getIMouse,
      _getIMouseNormalized,
    );

    /// add the operations added before putting this in the widgets tree
    for (final f in widget.controller!.conditionalOperation) {
      _addConditionalOperation(f);
    }

    init();
  }

  void _pause() {
    if (ticker?.isActive ?? false) {
      ticker?.stop();
      iTime.stop();
    }
  }

  void _play() {
    if (!(ticker?.isActive ?? false)) {
      ticker?.start();
      iTime.start();
    }
  }

  void _rewind() {
    iTime.reset();
  }

  void _reset() {
    iTime.reset();
    init();
  }

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
    mainImageSize = Size(widget.width, widget.height);
    setIMouse();
    init();
  }

  @override
  void reassemble() {
    super.reassemble();
    mainImageSize = Size(widget.width, widget.height);
    setIMouse();
    init();
  }

  void init() {
    isInited = false;
    mainImageSizeChanged = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isInited = false;
      var shaderInited = true;
      disposeLayers();
      for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
        shaderInited &= await widget.buffers![i].init();
      }
      shaderInited &= await widget.mainImage.init();
      iFrame = 0;
      isInited = shaderInited;
    });
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
    if (!isInited) return;

    for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
      widget.buffers![i].computeLayer(
        mainImageSize!,
        iTime.elapsedMilliseconds / 1000.0,
        iFrame,
        iMouse.iMouse,
      );
    }

    widget.mainImage.computeLayer(
      mainImageSize!,
      iTime.elapsedMilliseconds / 1000.0,
      iFrame,
      iMouse.iMouse,
    );

    iFrame++;
    if (context.mounted) setState(() {});
  }

  /// set the new size of this widget if not already.
  /// Gotten from the topmost IChannel wich holds a child widget.
  /// Taken from [widget.mainImage] and [widget.buffers]
  void setNewSize(Size newSize) {
    if (!mainImageSizeChanged) {
      mainImageSize = newSize;
      setIMouse();
      mainImageSizeChanged = true;
    }
  }

  void setIMouse() {
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
    if (!isInited) {
      return SizedBox(
        width: mainImageSize!.width,
        height: mainImageSize!.height,
      );
    }

    final widgets = <Widget>[];

    /// If [mainImage] uses widgets, put them into the
    /// three widgets using [AnimatedSampler]
    for (var i = 0; i < (widget.mainImage.channels?.length ?? 0); i++) {
      if (widget.mainImage.channels?[i].child != null) {
        widgets.add(
          AnimatedSampler(
            (image, size, canvas) {
              widget.mainImage.channels![i].childTexture = image.clone();
              setNewSize(size);
            },
            child: widget.mainImage.channels![i].child!,
          ),
        );
      }
    }

    /// If some buffers uses widgets, put them into the
    /// three widgets using [AnimatedSampler]
    for (var n = 0; n < (widget.buffers?.length ?? 0); n++) {
      for (var i = (widget.buffers?[n].channels?.length ?? 1) - 1;
          i >= 0;
          i--) {
        if (widget.buffers?[n].channels?[i].child != null) {
          widgets.add(
            AnimatedSampler(
              (image, size, canvas) {
                widget.buffers?[n].channels![i].childTexture = image.clone();
                setNewSize(size);
              },
              child: widget.buffers![n].channels![i].child!,
            ),
          );
        }
      }
    }

    return Listener(
      onPointerDown: (details) {
        iMouse.start(details.localPosition);
        widget.onPointerDown?.call(Offset(iMouse.iMouse.x, iMouse.iMouse.y));
        widget.onPointerDownNormalized?.call(
          () {
            final normalized = iMouse.getIMouseNormalized();
            return Offset(normalized.x, normalized.y);
          }.call(),
        );
      },
      onPointerMove: (details) {
        iMouse.update(details.localPosition);
        widget.onPointerMove?.call(Offset(iMouse.iMouse.x, iMouse.iMouse.y));
        widget.onPointerMoveNormalized?.call(
          () {
            final normalized = iMouse.getIMouseNormalized();
            return Offset(normalized.x, normalized.y);
          }.call(),
        );
      },
      onPointerCancel: (details) {
        iMouse.end();
        widget.onPointerUp?.call(Offset(iMouse.iMouse.x, iMouse.iMouse.y));
        widget.onPointerUpNormalized?.call(
          () {
            final normalized = iMouse.getIMouseNormalized();
            return Offset(normalized.x, normalized.y);
          }.call(),
        );
      },
      onPointerUp: (details) {
        iMouse.end();
        widget.onPointerUp?.call(Offset(iMouse.iMouse.x, iMouse.iMouse.y));
        widget.onPointerUpNormalized?.call(
          () {
            final normalized = iMouse.getIMouseNormalized();
            return Offset(normalized.x, normalized.y);
          }.call(),
        );
      },
      child: Stack(
        children: [
          RawImage(
            key: UniqueKey(),
            image: widget.mainImage.layerImage,
            width: mainImageSize!.width,
            height: mainImageSize!.height,
          ),
          ...widgets,
        ],
      ),
    );
  }
}
