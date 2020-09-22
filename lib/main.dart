import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        home: CameraFeed(
          camera: firstCamera,
        ),
      ),
  );
}

class CameraFeed extends StatefulWidget {
  final CameraDescription camera;
  const CameraFeed({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  CameraFeedState createState() => CameraFeedState();
}

class CameraFeedState extends State<CameraFeed>{
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  bool isDetecting = false;

  loadModel() async {
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
      ResolutionPreset.low,
    );

    loadModel();
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
    return Scaffold (
      appBar: AppBar(title: Text('JanCam')),
      body: _getCameraPreview()
    );
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
      isDetecting = false;
    });
  }


}
