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
  late ValueNotifier<int> updateLayerImages;

  late Layers shader;

  @override
  void initState() {
    super.initState();
    updateLayerImages = ValueNotifier<int>(0);
    shader = shader1();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ShaderBuffers(
                width: size.width,
                height: size.height * 0.5,
                mainImage: shader.mainImage,
                buffers: shader.buffers,
              ),
            ),

            /// row of images to show each layer buffers just for testing
            Container(
              width: size.width,
              height: size.height * 0.45,
              color: Colors.black26,
              child: ValueListenableBuilder(
                valueListenable: updateLayerImages,
                builder: (_, __, ___) {
                  final previewSize = Size(
                    size.width / (shader.buffers.length + 1) * 0.9,
                    size.height / (shader.buffers.length + 1) * 0.9,
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // draw all buffers
                      for (var i = 0; i < shader.buffers.length; i++)
                        if (shader.buffers[i].layerImage != null)
                          RawImage(
                            image: shader.buffers[i].layerImage,
                            width: previewSize.width,
                            height: previewSize.height,
                          ),
                      // draw the main image
                      RawImage(
                        image: shader.mainImage.layerImage,
                        width: previewSize.width,
                        height: previewSize.height,
                      ),
                    ],
                  );
                },
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
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
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      shader = (
                        mainImage: LayerBuffer(
                          shaderAssetsName: 'assets/shaders/mouse1.frag',
                        ),
                        buffers: [],
                      );
                    });
                  },
                  child: const Text('test mouse1'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      shader = (
                        mainImage: LayerBuffer(
                          shaderAssetsName: 'assets/shaders/mouse2.frag',
                        ),
                        buffers: [],
                      );
                    });
                  },
                  child: const Text('test mouse2'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      shader = (
                        mainImage: LayerBuffer(
                          shaderAssetsName: 'assets/shaders/arrows.frag',
                        ),
                        buffers: [],
                      );
                    });
                  },
                  child: const Text('arrows'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => updateLayerImages.value++,
                  child: const Text('show buffers'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Layers shader1() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_main.frag',
      channels: [IChannelSource(buffer: 0)],
    );
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_bufferA.frag',
      channels: [IChannelSource(buffer: 0)],
    );
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader2() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_main.frag',
      channels: [IChannelSource(buffer: 1)],
    );
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_bufferA.frag',
      channels: [IChannelSource(buffer: 1)],
    );
    final bufferB = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_bufferB.frag',
      channels: [
        IChannelSource(buffer: 1),
        IChannelSource(buffer: 0),
      ],
    );
    return (mainImage: mainLayer, buffers: [bufferA, bufferB]);
  }

  Layers shader3() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader3_main.frag',
      channels: [IChannelSource(buffer: 0)],
    );
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader3_bufferA.frag',
      channels: [
        IChannelSource(buffer: 0),
        IChannelSource(assetsImage: 'assets/bricks.jpg'),
      ],
    );
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader4() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader4_main.frag',
      channels: [
        IChannelSource(buffer: 0),
      ],
    );
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader4_bufferA.frag',
      channels: [
        IChannelSource(buffer: 0),
      ],
    );
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader5() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader5_main.frag',
      channels: [
        IChannelSource(buffer: 0),
      ],
    );
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader5_bufferA.frag',
      channels: [
        IChannelSource(buffer: 0),
      ],
    );
    return (mainImage: mainLayer, buffers: [bufferA]);
  }
}
