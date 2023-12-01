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

class _MainAppState extends State<MainApp> {
  late Layers shader;
  ValueNotifier<double> floatUniform = ValueNotifier<double>(1);
  ValueNotifier<bool> operations = ValueNotifier<bool>(false);
  final controller = ShaderBuffersController();
  final List<bool> ops = [false, false];

  @override
  void initState() {
    super.initState();
    shader = shader2();
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
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.bottomCenter,
            fit: StackFit.expand,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ShaderBuffers(
                  // key: UniqueKey(),
                  controller: controller,
                  // textureWidth: 600,
                  // textureHeight: 350,
                  // width: size.width,
                  // height: size.height,
                  mainImage: shader.mainImage,
                  buffers: shader.buffers,
                  startPaused: true,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Wrap(
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
                    ElevatedButton(
                      onPressed: controller.reset,
                      child: const Text('reset'),
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
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/page_curl.frag',
      // floatUniforms: [1.0],
    );

    // ignore: cascade_invocations
    mainLayer.setChannels(
      [
        IChannel(assetsTexturePath: 'assets/flutter.png'),
        IChannel(assetsTexturePath: 'assets/bricks.jpg'),
      ],
    );
    return (mainImage: mainLayer, buffers: []);
  }

  Layers shader2() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/water.frag',
      floatUniforms: [3],
    )
    ..setChannels(
      [
        IChannel(assetsTexturePath: 'assets/flutter.png'),
      ],
    );

    return (mainImage: mainLayer, buffers: []);
  }
}
