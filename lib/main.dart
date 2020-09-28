import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'CameraManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: CameraManager(
          camera: firstCamera,
        ),
      ),
  );
}
