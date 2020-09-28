import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'CameraManager.dart';

class RecognitionDisplay extends StatefulWidget {
  final CameraDescription camera;

  RecognitionDisplay(this.camera);

  @override
  RecognitionDisplayState createState() => RecognitionDisplayState();
}

class RecognitionDisplayState extends State<RecognitionDisplay> {

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        appBar: AppBar(title: Text('JanCam')),
        body: new CameraManager(camera: widget.camera),
    );
  }
}