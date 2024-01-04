import 'package:flutter/material.dart';
import 'package:shader_buffers/shader_buffers.dart';
import 'package:shader_buffers/src/i_channel.dart';

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
  ValueNotifier<bool> operations = ValueNotifier<bool>(false);
  ShaderController controller = ShaderController();
  ValueNotifier<List<Uniform>> uniform = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    shader = shader6();
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
            alignment: Alignment.center,
            children: [
              ShaderBuffers(
                key: UniqueKey(),
                controller: controller,
                // width: 250,
                // height: 300,
                mainImage: shader.mainImage,
                buffers: shader.buffers,
                startPaused: false,
                onPointerDown: (controller, position) {
                  print(position);
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...List.generate(uniform.value.length, (index) {
                      return ValueListenableBuilder(
                        valueListenable: uniform,
                        builder: (_, v, __) {
                          return Slider(
                            value: v[index].value,
                            min: uniform.value[index].range.start,
                            max: uniform.value[index].range.end,
                            onChanged: (value) {
                              uniform.value[index].value = value;
                              uniform.value = uniform.value.toList();
                            },
                          );
                        },
                      );
                    }),
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
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              shader = shader4();
                            });
                          },
                          child: const Text('4'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              shader = shader5();
                            });
                          },
                          child: const Text('5'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              shader = shader6();
                            });
                          },
                          child: const Text('6'),
                        ),
                      ],
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
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
            ],
          ),
        ),
      ),
    );
  }

  Layers shader1() {
    uniform.value = [];
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/page_curl.frag',
      // floatUniforms: [1.0],
    )..setChannels(
        [
          // IChannel(assetsTexturePath: 'assets/flutter.png'),
          // IChannel(assetsTexturePath: 'assets/bricks.jpg'),
          IChannel(child: const Widget1()),
          IChannel(child: const Widget2()),
        ],
      );

    /// add checks to see when the pointer is in the upper left quadrand
    controller = ShaderController();
    controller.addConditionalOperation(
      (
        layerBuffer: mainLayer,
        param: Param.iMouseXNormalized,
        checkType: CheckOperator.minor,
        checkValue: 0.2,
        operation: (ctrl, result) {
          if (result) {
            ctrl
              ..swapChannels(mainLayer, 0, 1)
              ..pause()
              ..rewind();
          }
        },
      ),
    );
    return (mainImage: mainLayer, buffers: []);
  }

  Layers shader2() {
    uniform.value = [
      Uniform(
        name: 'a',
        range: const RangeValues(0, 10),
        defaultValue: 1,
        value: 1,
      ),
      Uniform(
        name: 'b',
        range: const RangeValues(0, 10),
        defaultValue: 1,
        value: 1,
      ),
      Uniform(
        name: 'c',
        range: const RangeValues(0, 10),
        defaultValue: 1,
        value: 1,
      ),
    ];

    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/water.frag',
      uniforms: Uniforms(uniform.value),
    )..setChannels(
        [
          IChannel(assetsTexturePath: 'assets/flutter.png'),
          // IChannel(child: const Widget1()),
        ],
      );

    return (mainImage: mainLayer, buffers: []);
  }

  Layers shader3() {
    uniform.value = [];
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

  Layers shader4() {
    uniform.value = [
      Uniform(
        name: 'R',
        range: const RangeValues(0, 1),
        defaultValue: 0.9,
        value: 0.9,
      ),
      Uniform(
        name: 'G',
        range: const RangeValues(0, 1),
        defaultValue: 0.9,
        value: 0.9,
      ),
      Uniform(
        name: 'B',
        range: const RangeValues(0, 1),
        defaultValue: 0.2,
        value: 0.2,
      ),
    ];

    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/test_isself_buffer_a.frag',
      uniforms: Uniforms(uniform.value),
    );

    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/test_isself_main.frag',
    );

    // bufferA.setChannels([IChannel(isSelf: true)]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader5() {
    uniform.value = [];
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_bufferA.frag',
    );

    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_main.frag',
    );

    bufferA.setChannels([IChannel(buffer: bufferA)]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader6() {
    uniform.value = [];

    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/mouse2.frag',
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
