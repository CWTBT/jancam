import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'BoundingBox.dart';
import 'CameraManager.dart';

class RecognitionDisplay extends StatefulWidget {
  final CameraDescription camera;

  RecognitionDisplay(this.camera);

  @override
  RecognitionDisplayState createState() => RecognitionDisplayState();
}

class RecognitionDisplayState extends State<RecognitionDisplay> {
  List<dynamic> _recognitions;

  void setRecognitions(recognitions) {
    setState(() {
      _recognitions = recognitions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold (
        body: Stack (
          children: [
            new CameraManager(widget.camera, setRecognitions),
            new BoundingBox(_recognitions == null ? [] : _recognitions),
          ]
        ),
    );
  }
}