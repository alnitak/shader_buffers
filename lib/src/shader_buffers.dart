import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shader_buffers/src/imouse.dart';
import 'package:shader_buffers/src/layer_buffer.dart';

// TODO controller play pause ecc

/// Widget to paint the shader with the given [LayerBuffer]s.
///
class ShaderBuffers extends StatefulWidget {
  /// [mainImage] shader must be given.
  /// The more [buffers] the more performaces will be affected.
  ///
  /// Think of [mainImage] as the `Image` layer fragment
  /// and [buffers] as `Buffer[A-D]` in ShaderToy.com
  ///
  /// Each frame buffers are computed from the 1st to the last, then
  /// main image.
  ///
  /// This widget provide to the fragment shader the following uniforms:
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
  ///   channels: [IChannelSource(buffer: 1)],
  /// );
  /// /// This [LayerBuffer] uses 'shader_bufferA.glsl' as the fragment shader
  /// /// and 2 channels: the 1st is the buffer with id=1 (`bufferB`),
  /// /// the 2nd uses an assets image.
  /// final bufferA = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferA.glsl',
  ///   channels: [
  ///     IChannelSource(buffer: 1),
  ///     IChannelSource(assetsImage: 'assets/noise_color.png'),
  ///   ],
  /// );
  /// /// This [LayerBuffer] uses 'shader_bufferB.glsl' as the fragment shader
  /// /// and `bufferA` with id=0
  /// final bufferB = LayerBuffer(
  ///   shaderAssetsName: 'assets/shaders/shader_bufferB.glsl',
  ///   channels: [
  ///     IChannelSource(buffer: 0),
  ///   ],
  /// ),
  ///
  /// ShaderBuffer(
  ///   width: 500,
  ///   height: 300,
  ///   mainImage: mainImage,
  ///   buffers: [ bufferA, bufferB ],
  /// )
  /// ```
  const ShaderBuffers({
    required this.width,
    required this.height,
    required this.mainImage,
    this.buffers,
    super.key,
  });

  /// The width of this widget
  final double width;

  /// The height of this widget
  final double height;

  /// Main layer shader
  final LayerBuffer mainImage;

  /// Other optional channels
  final List<LayerBuffer>? buffers;

  @override
  State<ShaderBuffers> createState() => _ShaderBuffersState();
}

class _ShaderBuffersState extends State<ShaderBuffers>
    with TickerProviderStateMixin {
  Ticker? ticker;
  late Stopwatch sw;
  late IMouseController iMouse;
  late double iFrame;

  late bool isInited;

  @override
  void initState() {
    super.initState();

    iMouse = IMouseController(width: widget.width, height: widget.height);
    iMouse.iMouse.x = widget.width / 2;
    iMouse.iMouse.y = widget.height / 2;
    isInited = false;
    iFrame = 0;
    sw = Stopwatch();
    ticker = createTicker(tick);
    sw.start();
    ticker?.start();

    init();
  }

  @override
  void didUpdateWidget(covariant ShaderBuffers oldWidget) {
    super.didUpdateWidget(oldWidget);
    isInited = false;
    init();
  }

  void init() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isInited = false;
      var shaderInited = true;
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
    super.dispose();
  }

  void tick(Duration elapsed) {
    if (!isInited) return;

    // At each frame they are evaluated in A..D order, then main image.
    for (var i = 0; i < (widget.buffers?.length ?? 0); i++) {
      widget.buffers![i].computeLayer(
        widget.buffers!,
        Size(widget.width, widget.height),
        sw.elapsedMilliseconds / 1000.0,
        iFrame,
        iMouse.iMouse,
      );
    }

    widget.mainImage.computeLayer(
      widget.buffers!,
      Size(widget.width, widget.height),
      sw.elapsedMilliseconds / 1000.0,
      iFrame,
      iMouse.iMouse,
    );

    iFrame++;
    if (context.mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isInited) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    return GestureDetector(
      onPanStart: (details) => iMouse.start(details.localPosition),
      onPanUpdate: (details) => iMouse.update(details.localPosition),
      onPanCancel: () => iMouse.end(),
      onPanEnd: (details) => iMouse.end(),
      child: RawImage(image: widget.mainImage.layerImage),
    );
  }
}
