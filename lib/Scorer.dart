import 'Mahjong.dart';
import 'package:trotter/trotter.dart';
import 'meldType.dart';

class Scorer {

  final RawTiles raw;
  final Tile winningTile;

  Scorer(this.raw, this.winningTile);

  List<Hand> getValidHands() {
    List<String> possiblePairTiles = getPossiblePairTiles();
    List<Hand> validHands = [];
    List<dynamic> openMelds = _getOpenMelds();
    possiblePairTiles.forEach((pairTile) {
      Tile pt = Tile.fromString(pairTile);
      Meld pair = new Meld([pt, pt]);
      List<Tile> withoutPair = _removePairFromHand(pairTile);
      List<RawTiles> splitList = splitBySuit(withoutPair);
      List<List<dynamic>> allValidMelds = [];

      for(RawTiles suitedTiles in splitList) {
        if (suitedTiles.tiles.length < 3) continue;
        String suit = suitedTiles.tiles[0].suit;
        List<List<dynamic>> validMelds = getValidCompositions(suitedTiles.closedPortion);
        if (validMelds.length == 0) break;
        allValidMelds.addAll(validMelds);
      }
      if(allValidMelds.length > 0) {
        List<List<dynamic>> handCompositions = combineMelds(allValidMelds);
        for (List<dynamic> comp in handCompositions) {
          comp.addAll(openMelds);
          Hand h = new Hand(comp, pair, winningTile);
          validHands.add(h);
        }
      }
    });
    print(validHands);
    return validHands;
  }

  List<dynamic> _getOpenMelds() {
    List<Tile> currentTiles = [];
    List<dynamic> melds = [];
    for (Tile t in raw.tiles) {
      if (t.isOpen) currentTiles.add(t);
      if (currentTiles.length > 2) {
        melds.add(new Meld(currentTiles));
        currentTiles = [];
      }
    }
    return melds;
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
    List<Tile> tempList = new List.from(raw.closedPortion);
    int i = tempList.indexWhere((tile) => tile.toString() == pairTile.toString());
    tempList.removeRange(i, i+2);
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
    if (possibleMelds.length == 0 ) return [];

    List<List<dynamic>> validComp = [];

    // suitedTiles will always be some multiple of 3 if the hand is valid
    // Since even closed quads must be declared, they will be considered "open"
    // and thus this function doesn't have to worry about them.
    int neededMelds = (suitedTiles.length/ 3).toInt();
    int neededTiles = neededMelds * 3;

    // we have to find what combinations of the possible melds
    // produce a valid composition.
    String target = rawSuited.toString();
    Combinations all_meld_combos = Combinations(neededMelds, possibleMelds);
    List usedComps = [];
    for (var combo in all_meld_combos()) {
      RawTiles tilesInSection = RawTiles.fromMelds(combo);
      if (tilesInSection.toString() == target && combo.length == neededMelds) {
        if (!usedComps.contains(combo.toString())) {
          validComp.add(combo);
          usedComps.add(combo.toString());
        }
      }
    }
    return validComp;
  }

  List<List<dynamic>> combineMelds(List<List<dynamic>> allMelds) {
    List<List<dynamic>> possibleHands = new List();
    // Subtracting the two pair tiles, this is the number of melds we need
    double closedMelds = (raw.closedPortion.length - 2) / 3;

    if (allMelds.length == 1) {
      possibleHands.add(allMelds[0]);
      return possibleHands;
    }

    String suit = allMelds[0][0].getSuit();
    for (int j = 0; j < allMelds.length; j++) {
      if (allMelds[j][0].getSuit() != suit) break;
      List<dynamic> root = allMelds[j];
      int meldCount = root.length;
      List<dynamic> currentMelds = root;
      if (meldCount == closedMelds) {
        possibleHands.add(currentMelds);
        continue;
      }
      for (int i = 1; i < allMelds.length; i++) {
        print("$root <-> ${allMelds[i]}");
        int newCount = meldCount + allMelds[i].length;
        if (newCount > closedMelds) continue;
        currentMelds.addAll(allMelds[i]);
        if (newCount == closedMelds) {
          possibleHands.add(currentMelds);
          currentMelds = root;
          meldCount = root.length;
        }
        else {
          meldCount = newCount;
        }
      }
    }
    return possibleHands;
  }
}