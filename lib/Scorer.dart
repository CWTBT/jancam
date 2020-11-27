import 'Mahjong.dart';
import 'package:trotter/trotter.dart';
import 'meldType.dart';

class Scorer {

  final RawTiles raw;
  final Tile winningTile;

  Scorer(this.raw, this.winningTile);

  List<Hand> getValidHands() {
    List<String> possiblePairTiles = getPossiblePairTiles();
    possiblePairTiles.forEach((pairTile) {
      List<Tile> withoutPair = _removePairFromHand(pairTile);
      List<RawTiles> splitList = splitBySuit(withoutPair);
      List<List<dynamic>> allValidMelds = [];
      for(RawTiles suitedTiles in splitList) {
        // This is guaranteed to be a List of List<Meld>
        // List<dynamic> is used to play nicely with trotter combinations
        if (suitedTiles.tiles.length < 3) continue;
        List<List<dynamic>> validMelds = getValidCompositions(suitedTiles.closedPortion);
        allValidMelds.addAll(validMelds);
      }
      print(allValidMelds);
    });
  }

  List<String> getPossiblePairTiles() {
    Map<String,int> duplicates = _findDuplicateTiles();
    List<String> possiblePairTiles = new List();
    duplicates.forEach((key, value) {
      possiblePairTiles.add(key);
    });
    return possiblePairTiles;
  }

  Map<String,int> _findDuplicateTiles() {
    Map<String,int> tileCount = _countTiles(closedOnly: true);
    tileCount.removeWhere((key, value) => tileCount[key] < 2);
    return tileCount;
  }

  Map<String,int> _countTiles({closedOnly = false}) {
    Map<String,int> tileCount = new Map();
    List<Tile> tileSelection;
    closedOnly ? tileSelection = raw.closedPortion : tileSelection = raw.tiles;
    for (Tile tile in tileSelection) {
      if(tileCount.containsKey(tile.toString())) tileCount[tile.toString()] += 1;
      else tileCount[tile.toString()] = 1;
    }
    return tileCount;
  }

  List<Tile> _removePairFromHand(String pairTile) {
    List<Tile> tempList = raw.tiles;
    int i = tempList.indexWhere((tile) => tile.toString() == pairTile.toString());
    tempList.removeRange(i, i+1);
    return tempList;
  }

  List<RawTiles> splitBySuit(List<Tile> noPairList) {
    List<RawTiles> suitList = new List();
    String currentSuit = noPairList[0].suit;
    List<Tile> currentSubset = new List();

    noPairList.forEach((tile) {
      if (tile.suit != currentSuit) {
        RawTiles completedSubset = new RawTiles(currentSubset);
        suitList.add(completedSubset);
        currentSubset = [];
        currentSuit = tile.suit;
      }
      currentSubset.add(tile);
    });

    RawTiles completedSubset = new RawTiles(currentSubset);
    suitList.add(completedSubset);
    return suitList;
  }

  List<List<dynamic>> getValidCompositions(List<Tile> suitedTiles) {
    RawTiles rawSuited = new RawTiles(suitedTiles);
    List<Meld> possibleMelds = [];
    Combinations all_combos = Combinations(3, suitedTiles);

    for (var combo in all_combos()) {
      Meld newMeld = Meld(combo);
      if (newMeld.type != meldType.INVALID) possibleMelds.add(newMeld);
    }

    List<List<dynamic>> validComp = [];

    // Will always be some multiple of 3 if the hand is valid
    int neededMelds = (suitedTiles.length/ 3).toInt();

    // If our subset is only 3 tiles, there will only be one valid meld
    if (neededMelds == 1) validComp.add(possibleMelds);

    // Otherwise, we have to find what combinations of the possible melds
    // produce a valid composition.
    else {
      String target = rawSuited.toString();
      Combinations all_meld_combos = Combinations(neededMelds, possibleMelds);
      List usedComps = [];
      for (var combo in all_meld_combos()) {
        RawTiles tilesInSection = RawTiles.fromMelds(combo);
        if (tilesInSection.toString() == target) {
          if (!usedComps.contains(combo.toString())) {
            validComp.add(combo);
            usedComps.add(combo.toString());
          }
        }
      }
    }

    validComp.toSet().toList();
    return validComp;
  }
}