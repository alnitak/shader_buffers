import 'package:flutter/material.dart';
import 'package:shader_buffers/shader_buffers.dart';

typedef Layers = ({LayerBuffer mainImage, List<LayerBuffer> buffers});

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  late Layers shader;
  ValueNotifier<double> floatUniform = ValueNotifier<double>(1);
  ValueNotifier<bool> operations = ValueNotifier<bool>(false);
  final controller = ShaderBuffersController();
  final List<bool> ops = [false, false];

  @override
  void initState() {
    super.initState();
    shader = shader1();
    controller
      ..addConditionalOperation(
        (
          layerBuffer: shader.mainImage,
          param: Param.iMouseXNormalized,
          checkType: CheckOperator.minor,
          checkValue: 0.5,
          operation: (result) {
            ops[0] = result;
            print('******  ${ops[0]} ${ops[1]}    ${operations.value}');
          },
        ),
      )
      ..addConditionalOperation(
        (
          layerBuffer: shader.mainImage,
          param: Param.iMouseYNormalized,
          checkType: CheckOperator.minor,
          checkValue: 0.5,
          operation: (result) {
            ops[1] = result;
            operations.value = ops[0] && ops[1];
          },
        ),
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('******************* Main didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant MainApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('******************* Main didUpdateWidget');
  }

  @override
  void didChangeMetrics() {
    print(
        '******************* Main didChangeMetrics ${View.of(context).physicalSize}');
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.sizeOf(context);

    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ColoredBox(
            color: Colors.yellow,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ShaderBuffers(
                    controller: controller,
                    // width: 600,
                    // height: 400,
                    // width: size.width,
                    // height: size.height,
                    mainImage: shader.mainImage,
                    buffers: shader.buffers,
                    startPaused: true,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          shader = shader1();
                        });
                      },
                      child: const Text('1'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          shader = shader2();
                        });
                      },
                      child: const Text('2'),
                    ),
                    ValueListenableBuilder(
                      valueListenable: floatUniform,
                      builder: (_, uniform, __) {
                        return Slider(
                          value: uniform,
                          min: 0.1,
                          max: 10,
                          onChanged: (value) {
                            shader.mainImage.floatUniforms = [value];
                            floatUniform.value = value;
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.pause,
                      child: const Text('pause'),
                    ),
                    ElevatedButton(
                      onPressed: controller.play,
                      child: const Text('play'),
                    ),
                    ElevatedButton(
                      onPressed: controller.rewind,
                      child: const Text('rewind'),
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        final s = controller.getState();
                        return ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: Text(s.name),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Layers shader1() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/page_curl.frag',
      // floatUniforms: [1.0],
    );

    // ignore: cascade_invocations
    mainLayer.setChannels(
      [
        // IChannel(assetsTexturePath: 'assets/flutter.png'),
        // IChannel(assetsTexturePath: 'assets/bricks.jpg'),
        IChannel(child: const Widget1()),
        IChannel(child: const Widget2()),
      ],
    );
    return (mainImage: mainLayer, buffers: []);
  }

  Layers shader2() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/water.frag',
      floatUniforms: [3],
    )..setChannels(
        [
          IChannel(assetsTexturePath: 'assets/flutter.png'),
        ],
      );

    return (mainImage: mainLayer, buffers: []);
  }
}

class Widget1 extends StatelessWidget {
  const Widget1({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.account_circle, size: 42),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Widget 1',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w900),
                ),
                Text(
                  'shader_preset',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                print('Widget 1');
              },
              child: const Text('Widget 1'),
            ),
            const Icon(Icons.add_box_rounded, size: 42),
          ],
        ),
      ),
    );
  }
}

class Widget2 extends StatelessWidget {
  const Widget2({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.yellow[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.ac_unit, color: Colors.red, size: 42),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Widget 2',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w900),
                ),
                Text(
                  'shader_preset',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                print('Widget 2');
              },
              child: const Text('Widget 2'),
            ),
            const Spacer(),
            const Icon(Icons.delete_forever, color: Colors.red, size: 42),
          ],
        ),
      ),
    );
  }
}
