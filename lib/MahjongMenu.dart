import 'package:flutter/material.dart';
import 'HandInput.dart';

class MahjongMenu extends StatelessWidget {

  MahjongMenu();

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return Scaffold (
      appBar: AppBar(
        title: Text("JanCam"),
      ),
      body: Center (
        child: Column (
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "JanCam",
              style: TextStyle(fontSize: 24)
            ),
            _handSelectionButton(context),
          ],
        ),
      ),
    );
  }
}

Widget _handSelectionButton(BuildContext context) {
  return ElevatedButton(
    child: Text("Manual Hand Input"),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HandInput()),
      );
    },
  );
}
