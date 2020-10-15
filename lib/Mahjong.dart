class Tile {
  final int rank;
  final String suit;

  Tile(this.rank, this.suit);

  String toString() {
    return "$suit + $rank";
  }

  @override
  int compareTo(Tile other) {
    int mySuitNum = suit.codeUnitAt(0);
    int otherSuitNum = other.suit.codeUnitAt(0);
    int suitDiff = mySuitNum - otherSuitNum;
    return suitDiff == 0 ? rank - other.rank : suitDiff;
  }
}

class Hand {
  List<Tile> tiles;

  Hand(this.tiles) {
    tiles.sort((a,b) => a.compareTo(b));
  }

  String toString() {
    String handAsString = "";
    String currentSuit = tiles[0].suit;

    for (Tile tile in tiles) {
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