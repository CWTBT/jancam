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
  List<String> openTileStrings = [];
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
            Divider(),
            SizedBox(
              height: 200,
              child: buildOpenHandDisplay(),
            )
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

  Widget buildOpenHandDisplay() {
    return Wrap(
        children: openTileWidgets
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
      child: renderTile(name),
      onTapDown: _storePosition,
      onTap: () {
        setState(() {
          tileStrings.add(strippedName);
          displayTile("closed", name);
        });
      },
      onLongPress: () {
        _showCustomMenu(context, name);
      },
    );
  }

  void displayTile(String meldType, String name) {
    String strippedName = name.substring(0, name.length-4);
    if (meldType == "closed") {
      Widget tileButton = GestureDetector (
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 50,
          child: renderTile(name),
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
    else {
      List<Widget> imageList;
      if (meldType == "chi") imageList = renderChi(name);
      else if (meldType == "pon") imageList = renderPon(name);
      else if (meldType == "kan") {
        imageList = renderPon(name);
        imageList.add(renderTile(name));
      }
      Widget tileButton = GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: SizedBox(
          height: 50,
          child: Row(
            children: imageList
          ),
        ),
        onTap: () {
          setState(() {
            openTileWidgets.removeAt(openTileStrings.indexOf(strippedName));
            openTileStrings.remove(strippedName);
          });
        }
      );
      openTileWidgets.add(tileButton);
    }
    if (tileStrings.length + (openTileStrings.length * 3) == 14) {
      completeHand();
    }
  }

  void completeHand() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HandInput()),
    );
  }

  List<Widget> renderChi(String name) {
    String tileSuit = name.substring(0, name.length-5);
    int tileRank = int.parse(name.substring(name.length-5, name.length-4));
    List<Widget> tileImages = [
      for(int i = 0; i < 3; i++) renderTile(tileSuit+(tileRank+i).toString()+".png")
    ];
    return tileImages;
  }

  List<Widget> renderPon(String name) {
    List<Widget> tileImages = [
      for(int i = 0; i < 3; i++) renderTile(name)
    ];
    return tileImages;
  }

  Widget renderTile(String name) {
    return Stack(
      children: [
        Image(image: AssetImage("assets/Tiles/Front.png")),
        Image(image: AssetImage("assets/Tiles/$name"))
      ]
    );
  }

  //https://stackoverflow.com/questions/54300081/flutter-popupmenu-on-long-press/54714628#54714628
  void _showCustomMenu(BuildContext context, String name) {
    List<String> noChi = ["Ton", "Nan", "Pei", "Shaa", "Haku", "Hatsu", "Chun"];
    String strippedName = name.substring(0, name.length-4);
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
      if (tileStrings.length + (openTileStrings.length * 3) + 3 > 14) return;
      print(delta);
      if (delta == 0) {
        setState(() {
          openTileStrings.add(strippedName);
          displayTile("pon", name);
        });
      }
      else if (delta == 1) {
        if (noChi.contains(strippedName)) return;
        else if (int.parse(name.substring(name.length-5, name.length-4)) > 7) return;
        setState(() {
          openTileStrings.add(strippedName);
          displayTile("chi", name);
        });
      }
      if (delta == 2) {
        setState(() {
          openTileStrings.add(strippedName);
          displayTile("kan", name);
        });
      }
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

