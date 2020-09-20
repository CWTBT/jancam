import 'dart:async';
import 'dart:io';

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
    _initializeControllerFuture = _controller.initialize();
    loadModel();
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
          _controller.startImageStream((CameraImage image) => {_onNewFrame(image)});
          return CameraPreview(_controller);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }



  void _onNewFrame(CameraImage img) async {
    Tflite.detectObjectOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "SSDMobileNet",
      imageHeight: img.height,
      imageWidth: img.width,
      numResultsPerClass: 1,
    ).then((recognitions) {
      print(recognitions);
    });
  }


}
