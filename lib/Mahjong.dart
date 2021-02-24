import 'meldType.dart';

class Tile {
  int rank;
  String suit;
  bool isOpen;

  Tile(this.rank, this.suit, [isOpen = false]) {
    this.isOpen = isOpen;
  }

  Tile.fromString(String s, [isOpen = false]) {
    this.isOpen = isOpen;
    this.rank = int.parse(s.substring(0, 1));
    this.suit = s.substring(1);
  }

  String toString() {
    return "$rank$suit";
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
        for(int rank in currentTiles) {
          tiles.add(new Tile(rank, suit, isOpen));
          if (!isOpen) closedPortion.add(new Tile(rank, suit, isOpen));
        }

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
  final List<dynamic> melds;
  final Meld pair;
  final Tile winningTile;
  bool isOpen = false;

  Hand(this.melds, this.pair, this.winningTile);

  List<Tile> toTiles() {
    List<Tile> tiles = [];
    for (Meld m in melds) {
      if (m.isOpen && !isOpen) isOpen = true;
      for (Tile t in m.meldedTiles) {
        tiles.add(t);
      }
    }
    return tiles;
  }

  String toString() {
    String s = "[";
    bool opened = false;
    for (Meld m in melds) {
      if(m.isOpen && !opened) s = s.substring(0, s.length) + pair.toString() + "|";
      s += m.toString() +", ";
    }
    if (opened) return s.substring(0, s.length - 2) + "]";
    else return s.substring(0, s.length)+ "]";
  }
}

class ScoredHand {
  List<Tile> tiles;
  int han;
  int fu;
  String score;

  ScoredHand(this.tiles, this.han, this.fu, this.score) {

  }

}

class Meld {
  final List<dynamic> meldedTiles;
  meldType type;
  bool isOpen;

  Meld(this.meldedTiles) {
    if (meldedTiles.length == 2) type = meldType.PAIR;
    else if (meldedTiles.length == 4) type = meldType.QUADRUPLET;
    else if (meldedTiles[1].rank == meldedTiles[0].rank + 1
        && meldedTiles[2].rank == meldedTiles[1].rank + 1) type = meldType.SEQUENCE;
    else if (meldedTiles[0].rank == meldedTiles[1].rank
        && meldedTiles[1].rank == meldedTiles[2].rank) type = meldType.TRIPLET;
    else type = meldType.INVALID;

    isOpen = meldedTiles[0].isOpen;
  }

  String getSuit() {
    return meldedTiles[0].suit;
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