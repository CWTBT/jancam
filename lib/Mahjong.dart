class Tile {
  final int rank;
  final String suit;
  bool isOpen;

  Tile(this.rank, this.suit, [isO = false]) {
    isOpen = isO;
  }

  String toString() {
    return "$suit + $rank";
  }

  @override
  int compareTo(Tile other) {
    // Whether a tile is open or closed should affect ordering before rank/suit
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

class Hand {
  List<Tile> tiles;
  List<Tile> closedPortion;

  Hand(this.tiles) {
    tiles.sort((a,b) => a.compareTo(b));
    for (Tile tile in tiles) {
      if (!tile.isOpen) break;
      closedPortion.add(tile);
    }
  }

  String toString() {
    String handAsString = "";
    String currentSuit = tiles[0].suit;
    bool checkingOpenTiles = false;

    for (Tile tile in tiles) {
        if(tile.suit != currentSuit) {
          handAsString = handAsString + currentSuit;
          currentSuit = tile.suit;
        }
        // Demarcate when we hit the first open tile, but not on later open tiles
        if(tile.isOpen != checkingOpenTiles) {
          checkingOpenTiles = tile.isOpen;
          handAsString = handAsString + "|";
        }

        handAsString = handAsString + tile.rank.toString();
      }
    handAsString = handAsString + currentSuit;

    return handAsString;
  }
}