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