import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

// Callback for _setRecognitions in RecognitionDisplay
typedef void Callback(List<dynamic> list, int h, int w);

class CameraManager extends StatefulWidget {
  final CameraDescription camera;
  final Callback setRecognitions;

  CameraManager(this.camera, this.setRecognitions);

  @override
  CameraManagerState createState() => CameraManagerState();
}

class CameraManagerState extends State<CameraManager>{
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isDetecting = false;

  Future<void> loadDetectionModel() async {
    await Tflite.loadModel(
        model: "assets/tflite/ssd_mobilenet.tflite",
        labels: "assets/tflite/ssd_mobilenet.txt"
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    loadDetectionModel();

    // This is from the example code and I still need to figure out
    // what it does.
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});

      _controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          _detectObjects(img);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _getCameraPreview();
  }

  Widget _getCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _detectObjects(CameraImage img) async {
    isDetecting = true;
    Tflite.detectObjectOnFrame(

      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),

      model: "SSDMobileNet",
      imageHeight: img.height,
      imageWidth: img.width,
      numResultsPerClass: 1,

    ).then((recognitions) {
      widget.setRecognitions(recognitions, img.height, img.width);
      isDetecting = false;
    });
  }
}