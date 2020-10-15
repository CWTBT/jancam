import 'package:flutter/material.dart';
import 'dart:math' as math;

class BoundingBox extends StatelessWidget {
  final List<dynamic> recognitions;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  BoundingBox(this.recognitions, this.previewH, this.previewW, this.screenH, this.screenW);

  // Much of this is adapted from Sha Qian's implementation at
  // https://github.com/shaqian/flutter_realtime_detection/blob/master/lib/bndbox.dart
  List<Widget> _renderBoxes() {
    return recognitions.map((re) {
      var _x = re["rect"]["x"];
      var _w = re["rect"]["w"];
      var _y = re["rect"]["y"];
      var _h = re["rect"]["h"];
      var detClass = re["detectedClass"];
      var confidence = re["confidenceInClass"];
      var scaleW, scaleH, x, y, w, h;

      if (screenH / screenW > previewH / previewW) {
        scaleW = screenH / previewH * previewW;
        scaleH = screenH;
        var difW = (scaleW - screenW) / scaleW;
        x = (_x - difW / 2) * scaleW;
        w = _w * scaleW;
        if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
        y = _y * scaleH;
        h = _h * scaleH;
      } else {
        scaleH = screenW / previewW * previewH;
        scaleW = screenW;
        var difH = (scaleH - screenH) / scaleH;
        x = _x * scaleW;
        w = _w * scaleW;
        y = (_y - difH / 2) * scaleH;
        h = _h * scaleH;
        if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
      }

      return confidence < 0.2 ? Container(width: 0, height: 0): Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${detClass}",
              style: TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _renderBoxes(),
    );
  }
}