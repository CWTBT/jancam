import 'meldType.dart';

class Tile {
  final int rank;
  final String suit;
  bool isOpen;

  Tile(this.rank, this.suit, [isOpen = false]) {
    this.isOpen = isOpen;
  }

  String toString() {
    return "$suit$rank";
  }

  @override
  int compareTo(Tile other) {
    // Whether a tile is open or closed should affect ordering before rank/suit.
    // 100 is an arbitrary large number to ensure this
    int openModifier = 0;
    if (isOpen) openModifier += 100;
    if (other.isOpen) openModifier -=100;

    // Suits are sorted alphabetically based on their notation abbreviations:
    // M(anzu) < P(inzu) < S(ouzu) < Z (honor)
    int mySuitNum = suit.codeUnitAt(0);
    int otherSuitNum = other.suit.codeUnitAt(0);
    int suitDiff = mySuitNum - otherSuitNum;
    return suitDiff == 0 ? rank - other.rank + openModifier : suitDiff + openModifier;
  }
}

class RawTiles {
  List<Tile> tiles = [];
  List<Tile> closedPortion = new List();

  RawTiles(this.tiles) {
    tiles.sort((a,b) => a.compareTo(b));
    tiles.forEach((tile) {
      if (!tile.isOpen) closedPortion.add(tile);
    });
  }

  RawTiles.fromMelds(List<dynamic> melds) {
    for (Meld m in melds) {
      for (Tile t in m.meldedTiles) {
        if (!t.isOpen) closedPortion.add(t);
        tiles.add(t);
      }
    }
    tiles.sort((a,b) => a.compareTo(b));
  }

  RawTiles.fromString(String tileString) {
    List<int> currentTiles = [];
    tiles = [];
    bool isOpen = false;
    for (int i = 0; i < tileString.length; i++) {
      if (tileString[i] == "|") isOpen = true;
      else if (int.tryParse(tileString[i]) == null) { //char is not numeric
        String suit = tileString[i];
        for(int rank in currentTiles) tiles.add(new Tile(rank, suit, isOpen));
        currentTiles = [];
      }
      else currentTiles.add(int.parse(tileString[i]));
    }
    tiles.sort((a,b) => a.compareTo(b));
  }

  String toString() {
    String handAsString = "";
    String currentSuit = tiles[0].suit;
    bool checkingOpenTiles = false;

    for (Tile tile in tiles) {
      // Demarcate when we hit the first open tile, but not on later open tiles
      if(tile.isOpen != checkingOpenTiles) {
        checkingOpenTiles = tile.isOpen;
        handAsString = handAsString + currentSuit+"|";
        currentSuit = tile.suit;
      }

      if(tile.suit != currentSuit) {
          handAsString = handAsString + currentSuit;
          currentSuit = tile.suit;
        }
        handAsString = handAsString + tile.rank.toString();
      }
    handAsString = handAsString + currentSuit;

    return handAsString;
  }
}

class Hand {
  final List<Meld> melds;
  final Tile winningTile;

  Hand(this.melds, this.winningTile);

  List<Tile> toTiles() {
    List<Tile> tiles = [];
    for (Meld m in melds) {
      for (Tile t in m.meldedTiles) {
        tiles.add(t);
      }
    }
    return tiles;
  }
}

class Meld {
  final List<dynamic> meldedTiles;
  meldType type;

  Meld(this.meldedTiles) {
    if (meldedTiles.length == 2) type = meldType.PAIR;
    else if (meldedTiles.length == 4) type = meldType.QUADRUPLET;
    else if (meldedTiles[1].rank == meldedTiles[0].rank + 1
        && meldedTiles[2].rank == meldedTiles[1].rank + 1) type = meldType.SEQUENCE;
    else if (meldedTiles[0].rank == meldedTiles[1].rank
        && meldedTiles[1].rank == meldedTiles[2].rank) type = meldType.TRIPLET;
    else type = meldType.INVALID;
  }

  String toString() {
    String s = "";
    for (Tile t in meldedTiles) {
      s += t.rank.toString();
    }
    s+= meldedTiles[0].suit;
    return s;
  }
}