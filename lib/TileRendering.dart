import 'package:flutter/material.dart';

Widget renderTile(String name) {
  return Stack(
      children: [
        Image(image: AssetImage("assets/Tiles/Front.png")),
        Image(image: AssetImage("assets/Tiles/$name"))
      ]
  );
}