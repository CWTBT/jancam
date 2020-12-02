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
        labels: "assets/tflite/ssd_mobilenet.txt",
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
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return _getCameraPreview();
  }

  Widget _getCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildRotatedPreview();
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  //https://stackoverflow.com/questions/62299947/consistent-camera-preview-rotation-behavior-on-phones-and-tablets-in-flutter
  //https://stackoverflow.com/questions/51284589/flutter-how-to-know-the-device-is-deviceorientation-is-up-or-down
  Widget buildRotatedPreview() {
    return OrientationBuilder (
      builder: (context, orientation) {
        return RotatedBox(
          quarterTurns: orientation == Orientation.portrait ? 0 : 3,
          //child: sizedCameraPreview(orientation),
          child: CameraPreview(_controller),
        );
      }
    );
  }

  Widget sizedCameraPreview(Orientation orientation) {
    final size = MediaQuery.of(context).size;
    var deviceRatio;
    if (orientation == Orientation.landscape) deviceRatio = size.height / size.width;
    else deviceRatio = size.width / size.height;
    return Transform.scale(
      scale: _controller.value.aspectRatio / deviceRatio,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: CameraPreview(_controller)
        ),
      ),
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
      rotation: 90,

    ).then((recognitions) {
      widget.setRecognitions(recognitions, img.height, img.width);
      isDetecting = false;
    });
  }
}