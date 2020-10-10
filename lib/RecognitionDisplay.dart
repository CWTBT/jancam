import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

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
  int _imageHeight = 0;
  int _imageWidth = 0;

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold (
        body: Stack (
          children: [
            CameraManager(widget.camera, setRecognitions),
            BoundingBox(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
            ),
          ]
        ),
    );
  }
}