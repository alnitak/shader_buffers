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
  ValueNotifier<(double a, double b, double c)> floatUniform =
      ValueNotifier((0.6, 8.0, 1.0));
  ValueNotifier<bool> operations = ValueNotifier<bool>(false);
  final controller = ShaderController();
  final List<bool> ops = [false, false];

  @override
  void initState() {
    super.initState();
    shader = shader3();

    /// add checks to see when the pointer is in the upper left quadrand
    controller.addConditionalOperation(
      (
        layerBuffer: shader.mainImage,
        param: Param.iMouseXNormalized,
        checkType: CheckOperator.minor,
        checkValue: 0.2,
        operation: (ctrl, result) {
          if (result) {
            ctrl
              ..pause()
              ..rewind();
          }
          // ops[0] = result;
          // print('******  ${ops[0]} ${ops[1]}    ${operations.value}');
        },
      ),
    );
    // ..addConditionalOperation(
    //   (
    //     layerBuffer: shader.mainImage,
    //     param: Param.iMouseYNormalized,
    //     checkType: CheckOperator.minor,
    //     checkValue: 0.5,
    //     operation: (result) {
    //       ops[1] = result;
    //       operations.value = ops[0] && ops[1];
    //     },
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Center(
                child: ShaderBuffers(
                  controller: controller,
                  width: 200,
                  height: 200,
                  mainImage: shader.mainImage,
                  buffers: shader.buffers,
                  startPaused: false,
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
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        shader = shader3();
                      });
                    },
                    child: const Text('3'),
                  ),
                  ValueListenableBuilder(
                    valueListenable: floatUniform,
                    builder: (_, uniform, __) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: uniform.$1,
                            min: 0.1,
                            max: 10,
                            onChanged: (value) {
                              shader.mainImage.floatUniforms = [
                                value,
                                uniform.$2,
                                uniform.$3,
                              ];
                              floatUniform.value =
                                  (value, uniform.$2, uniform.$3);
                            },
                          ),
                          Slider(
                            value: uniform.$2,
                            min: 0.1,
                            max: 10,
                            onChanged: (value) {
                              shader.mainImage.floatUniforms = [
                                uniform.$1,
                                value,
                                uniform.$3,
                              ];
                              floatUniform.value =
                                  (uniform.$1, value, uniform.$3);
                            },
                          ),
                          Slider(
                            value: uniform.$3,
                            min: 0.1,
                            max: 10,
                            onChanged: (value) {
                              shader.mainImage.floatUniforms = [
                                uniform.$1,
                                uniform.$2,
                                value,
                              ];
                              floatUniform.value =
                                  (uniform.$1, uniform.$2, value);
                            },
                          ),
                        ],
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
      floatUniforms: [0.6, 8, 1],
    )..setChannels(
        [
          IChannel(assetsTexturePath: 'assets/flutter.png'),
          // IChannel(child: const Widget1()),
        ],
      );

    return (mainImage: mainLayer, buffers: []);
  }

  Layers shader3() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/page_curl.frag',
      // floatUniforms: [0.1],
    );

    // ignore: cascade_invocations
    mainLayer.setChannels(
      [
        IChannel(assetsTexturePath: 'assets/flutter.png'),
        IChannel(assetsTexturePath: 'assets/bricks.jpg'),
        // IChannel(child: const Widget1()),
        // IChannel(child: const Widget2()),
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
