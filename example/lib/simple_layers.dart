// ignore_for_file: avoid_multiple_declarations_per_line, public_member_api_docs

import 'package:flutter/material.dart';
import 'package:shader_buffers/shader_buffers.dart';

/// Code to demostrate the use of multiple image filter fragment shaders
/// to apply in sequence to a single image. Something like this:
/// https://github.com/alnitak/shader_buffers?tab=readme-ov-file#layering-shaders
///
/// Please, read the comments of fragment source code
/// located in `assets/shaders/filters` and the documentation
/// for writing a fragment shader
/// https://github.com/alnitak/shader_buffers?tab=readme-ov-file#writing-a-fragment-shader

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  /// the shader controller
  late ShaderController controller;

  /// the buffers used here
  late LayerBuffer mainImage, bufferA;

  /// the control sliders for uniforms
  late ValueNotifier<double> valueWhite, valueBlack;

  @override
  void initState() {
    super.initState();

    controller = ShaderController();
    valueWhite = ValueNotifier(0);
    valueBlack = ValueNotifier(0);

    /// initialize the mandatory [layerBuffer] and its uniforms
    mainImage = LayerBuffer(
      shaderAssetsName: 'assets/shaders/filters/black.frag',
      uniforms: Uniforms(
        [
          Uniform(
            value: 0,
            name: 'value',
            range: const RangeValues(0, 255),
            defaultValue: 0,
          ),
        ],
      ),
    );

    /// initialize the second buffer and its uniforms
    bufferA = LayerBuffer(
      shaderAssetsName: 'assets/shaders/filters/white.frag',
      uniforms: Uniforms(
        [
          Uniform(
            value: 0,
            name: 'value',
            range: const RangeValues(0, 255),
            defaultValue: 0,
          ),
        ],
      ),
    );

    /// tells the main layer to use the [bufferA] output as a texture uniform
    mainImage.setChannels([IChannel(buffer: bufferA)]);

    /// tells the first layer to use an image as a texture uniform
    bufferA.setChannels([IChannel(assetsTexturePath: 'assets/flutter.png')]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: valueWhite,
              builder: (_, v, __) {
                return Slider(
                  value: v,
                  max: 255,
                  onChanged: (sliderValue) {
                    mainImage.uniforms!.uniforms.first.value = sliderValue;
                    valueWhite.value = sliderValue;
                  },
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: valueBlack,
              builder: (_, v, __) {
                return Slider(
                  value: v,
                  max: 255,
                  onChanged: (sliderValue) {
                    bufferA.uniforms!.uniforms.first.value = sliderValue;
                    valueBlack.value = sliderValue;
                  },
                );
              },
            ),
            Expanded(
              child: ShaderBuffers(
                controller: controller,
                mainImage: mainImage,
                buffers: [bufferA],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
