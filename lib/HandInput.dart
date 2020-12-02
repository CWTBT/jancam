import 'package:flutter/material.dart';
import 'TileMap.dart';
import 'Mahjong.dart';
import 'Entries.dart';

class HandInput extends StatefulWidget{
  HandInput();

  @override
  HandInputState createState() => HandInputState();
}

class HandInputState extends State<HandInput> {
  List<String> tileStrings = [];
  List<Widget> closedTileWidgets = [];
  List<Widget> openTileWidgets = [];
  var _tapPosition;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Center(
        child: Column (
          children: [
            SizedBox(
              height: 275,
              child: buildGrid()
            ),
            SizedBox(
              height: 100,
              child: buildHandDisplay(),
            ),
            //buildHandDisplay(),
          ]
        ),
      ),
    );
  }

  Widget buildGrid() {
    return GridView.extent(
      primary: false,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 1,
      mainAxisSpacing: 5,
      maxCrossAxisExtent: 50,
      children: buildTiles(),
    );
  }

  Widget buildHandDisplay() {
    return Wrap(
      children: closedTileWidgets
    );
  }

  List<Widget> buildTiles(){
    List<String> filenames = _buildFilenameList();
    List<Widget> imageList = [];
    for (String name in filenames) {
      if (name == "Front.png") continue;
      imageList.add(
        buildTileButton(name)
      );
    }
    return imageList;
  }

  Widget buildTileButton(String name) {
    String strippedName = name.substring(0, name.length-4);
    return GestureDetector (
      behavior: HitTestBehavior.translucent,
      child: Stack (
          children: [
            Image(image: AssetImage("assets/Tiles/Front.png")),
            Image(image: AssetImage("assets/Tiles/$name"))
          ]
      ),
      onTapDown: _storePosition,
      onTap: () {
        setState(() {
          tileStrings.add(strippedName);
          displayTile(false, name);
        });
      },
      onLongPress: () {
        _showCustomMenu(context, name);
      },
    );
  }

  void displayTile(bool isOpened, String name) {
    String strippedName = name.substring(0, name.length-4);
    if (!isOpened) {
      Widget tileButton = GestureDetector (
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 50,
          child:Stack (
              children: [
                Image(image: AssetImage("assets/Tiles/Front.png")),
                Image(image: AssetImage("assets/Tiles/$name"))
              ]
          ),
        ),
        onTap: () {
          setState(() {
            closedTileWidgets.removeAt(tileStrings.indexOf(strippedName));
            tileStrings.remove(strippedName);
          });
        }
      );
      closedTileWidgets.add(tileButton);
    }
  }

  //https://stackoverflow.com/questions/54300081/flutter-popupmenu-on-long-press/54714628#54714628
  void _showCustomMenu(BuildContext context, String name) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    showMenu(
        context: context,
        items: <PopupMenuEntry<int>>[MeldEntry()],
        position: RelativeRect.fromRect(
            _tapPosition & const Size(40, 40), // smaller rect, the touch area
            Offset.zero & overlay.size   // Bigger rect, the entire screen
        ),
    ).then<void>((int delta) {
      // delta would be null if user taps on outside the popup menu
      // (causing it to close without making selection)
      if (delta == null) return;
      setState(() {
        print(delta);
      });
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition =  details.globalPosition;
  }

  List<String> _buildFilenameList() {
    List<String> man = [for(int i = 1; i < 10; i ++) "Man$i.png"];
    List<String> sou = [for(int i = 1; i < 10; i ++) "Sou$i.png"];
    List<String> pin = [for(int i = 1; i < 10; i ++) "Pin$i.png"];
    List<String> honors = ["Ton.png", "Nan.png", "Shaa.png", "Pei.png", "Hatsu.png", "Chun.png", "Haku.png", "Front.png"];
    return man + sou + pin + honors;
  }
}

