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
    shader = shader6();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final controller = ShaderBuffersController();

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
                key: UniqueKey(),
                controller: controller,
                textureWidth: size.width,
                textureHeight: size.height * 0.5,
                mainImage: shader.mainImage,
                buffers: shader.buffers,
              ),
            ),

            /// row of images to show each layer buffers just for testing
            Container(
              width: size.width,
              height: size.height * 0.45,
              color: Colors.yellow.withOpacity(0.3),
              child: ValueListenableBuilder(
                valueListenable: updateLayerImages,
                builder: (_, __, ___) {
                  final previewSize = Size(
                    /// to show buffers
                    size.width / (shader.buffers.length + 1) * 0.9,
                    size.height / (shader.buffers.length + 1) * 0.9,

                    /// to show mainImage channels
                  //   size.width / (shader.mainImage.channels?.length ?? 0) * 0.9,
                  //   size.height /
                  //       (shader.mainImage.channels?.length ?? 0) *
                  //       0.9,
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

                      // draw assetsTextures of mainImage
                      for (var i = 0;
                          i < (shader.mainImage.channels?.length ?? 0);
                          i++)
                        if (shader.mainImage.channels?[i].assetsTexture != null)
                          RawImage(
                            image: shader.mainImage.channels?[i].assetsTexture,
                            width: previewSize.width,
                            height: previewSize.height,
                          ),

                      // draw childTexture of mainImage
                      for (var i = 0;
                          i < (shader.mainImage.channels?.length ?? 0);
                          i++)
                        if (shader.mainImage.channels?[i].childTexture != null)
                          RawImage(
                            image: shader.mainImage.channels?[i].childTexture,
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
              spacing: 4,
              runSpacing: 4,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      shader = shader0();
                    });
                  },
                  child: const Text('0'),
                ),
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
                ElevatedButton(
                  onPressed: () => updateLayerImages.value++,
                  child: const Text('show buffers'),
                ),
                ElevatedButton(
                  onPressed: controller.pause,
                  child: const Text('pause'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.play();
                    print(
                        'iMouse: ${controller.getIMouse()}   '
                        'norm: ${controller.getIMouseNormalized()}');
                  },
                  child: const Text('play'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.rewind();
                  },
                  child: const Text('rewind'),
                ),
                ElevatedButton(
                  onPressed: () {
                    controller.reset();
                  },
                  child: const Text('reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Layers shader0() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/test.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/water.frag',
    );

    bufferA.setChannels([IChannel(assetsTexturePath: 'assets/bricks.jpg')]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader1() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_bufferA.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader1_main.frag',
    );

    bufferA.setChannels([IChannel(isSelf: true)]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader2() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_bufferA.frag',
    );
    final bufferB = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_bufferB.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader2_main.frag',
    );

    bufferA.setChannels([IChannel(buffer: bufferB)]);
    bufferB.setChannels([
      IChannel(isSelf: true),
      IChannel(buffer: bufferA),
    ]);
    mainLayer.setChannels([IChannel(buffer: bufferB)]);
    return (mainImage: mainLayer, buffers: [bufferA, bufferB]);
  }

  Layers shader3() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader3_bufferA.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader3_main.frag',
    );

    bufferA.setChannels([
      IChannel(buffer: bufferA),
      IChannel(assetsTexturePath: 'assets/bricks.jpg'),
    ]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader4() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader4_bufferA.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader4_main.frag',
    );

    bufferA.setChannels([IChannel(buffer: bufferA)]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader5() {
    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader5_bufferA.frag',
    );
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/shader5_main.frag',
    );

    bufferA.setChannels([
      IChannel(buffer: bufferA),
    ]);
    mainLayer.setChannels([IChannel(buffer: bufferA)]);
    return (mainImage: mainLayer, buffers: [bufferA]);
  }

  Layers shader6() {
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/water.frag',
    );

    final bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/page_curl.frag',
    );

    // ignore: cascade_invocations
    bufferA.setChannels(
      [
        IChannel(
          child: Container(
            width: 300,
            height: 200,
            color: Colors.grey,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  print('ciao2');
                },
                child: const Text('ciao2'),
              ),
            ),
          ),
        ),
        IChannel(
          child: Container(
            width: 300,
            height: 200,
            color: Colors.blue,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  print('ciao1');
                },
                child: const Text('ciao1'),
              ),
            ),
          ),
        ),
      ],
    );

    mainLayer.setChannels([IChannel(buffer: bufferA)]);

    return (mainImage: mainLayer, buffers: [bufferA]);
  }
}
