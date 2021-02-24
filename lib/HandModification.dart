import 'package:flutter/material.dart';
import 'Mahjong.dart';
import 'Scorer.dart';
import 'TileRendering.dart';
import 'TileMap.dart';

class HandModification extends StatefulWidget {
  RawTiles tiles;
  Tile winner;

  HandModification(this.tiles, this.winner);

  @override
  HandModificationState createState() => HandModificationState();
}

class HandModificationState extends State<HandModification> {
  @override
  Widget build(BuildContext context) {
    Scorer s = Scorer(widget.tiles, widget.winner);
    List<Hand> validHands = s.getValidHands();
    ScoredHand bestHand = s.score(validHands, "south", "east", true);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              children: [for(Tile t in bestHand.tiles) SizedBox(
                height: 70,
                child: renderTile(TileMap[t.toString()])
                ),
              ],
            ),
            Text(bestHand.score),
            Text("Han "+bestHand.han.toString()),
            Text("Fu "+bestHand.fu.toString()),
          ]
      ),
    );
  }

  void Score() {
    Scorer s = Scorer(widget.tiles, widget.winner);
  }
}