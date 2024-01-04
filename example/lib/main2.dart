import 'package:flutter/material.dart';
import 'package:shader_buffers/shader_buffers.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ShaderController();
    final mainLayer = LayerBuffer(
      shaderAssetsName: 'assets/shaders/mouse2.frag',
    );
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ShaderBuffers(
            controller: controller,
            // width: 250,
            // height: 300,
            mainImage: mainLayer,
            startPaused: false,
          ),
        ),
      ),
    );
  }
}
