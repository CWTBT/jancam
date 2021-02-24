import 'YakuList.dart';
import 'Mahjong.dart';
import 'meldType.dart';

class Yaku {
  int han = 0;
  int fu = 20;
  bool tsumoWin;
  Hand hand;
  String round = "";
  String player = "";
  List<String> satisfiedYaku = [];

  Yaku(this.hand, this.round, this.player, this.tsumoWin);

  void calculateHan() {
    allSimples();
    mixedMelds(meldType.SEQUENCE);
    mixedMelds(meldType.TRIPLET);
    valueHonor();
    twinSequences();
    concealedTriplets();
  }

  void calculateFu() {
    waitShape();
    meldFu();
    if (tsumoWin) fu += 2;
    print("FU: $fu");
    if(fu % 10 > 0) fu += (10 - (fu % 10));
    print("NEW FU: $fu");
  }

  void waitShape() {
    Tile winner = hand.winningTile;
    for (Meld m in hand.melds) {
      String s = m.toString();
      // Middle wait
      if (m.meldedTiles[2] == winner) fu += 2;
      else {
        // Edge waits (12[3] or [7]89)
        if (s.contains("9") || m.meldedTiles[0] == winner) fu += 2;
        else if (s.contains("1") || m.meldedTiles[2] == winner) fu += 2;
      }
    }
  }

  void meldFu() {
    for (Meld m in hand.melds) {
      String s = m.toString();
      meldType mtype = m.type;
      int fuToAdd = 0;
      bool isSimple = !s.contains("z") || !s.contains("1") || !s.contains("9");
      if (m.type == meldType.QUADRUPLET) {
        fuToAdd = 32;
        if (m.isOpen) fuToAdd = (fuToAdd / 2).round();
        if (isSimple) fuToAdd = (fuToAdd / 2).round();
      }
      else if (m.type == meldType.TRIPLET) {
        fuToAdd = 8;
        if (m.isOpen) fuToAdd = (fuToAdd / 2).round();
        if (isSimple) fuToAdd = (fuToAdd / 2).round();
        print("Adding $fuToAdd for a triplet");
      }
      fu += fuToAdd;
    }
  }

  void allSimples() {
    for (Meld m in hand.melds) {
      String s = m.toString();
      if (s.contains("z") || s.contains("1") || s.contains("9")) return;
    }
    han += 1;
    satisfiedYaku.add("All Simples");
  }

  void mixedMelds(meldType type) {
    List<String> manzu = [];
    List<String> pinzu = [];
    List<String> souzu = [];
    for (Meld m in hand.melds) {
      if (m.type != meldType) continue;
      String s = m.toString();
      if (s.endsWith("m")) manzu.add(s.substring(0, s.length - 1));
      else if (s.endsWith("p")) pinzu.add(s.substring(0, s.length - 1));
      else if (s.endsWith("s")) souzu.add(s.substring(0, s.length - 1));
    }

    for (String meldString in manzu) {
      if (pinzu.contains(meldString) && souzu.contains(meldString)) {
        han += 2;
        if(type == meldType.SEQUENCE) {
          satisfiedYaku.add("Mixed Sequences");
          if (hand.isOpen) han -=1;
        }
        else satisfiedYaku.add("Mixed Triplets");
      }
    }
  }

  void valueHonor() {
    List<String> value_tiles = ["5z", "6z", "7z"];
    if (round == "east" || player == "east") value_tiles.add("1z");
    else if (round == "south" || player == "south") value_tiles.add("2z");
    else if (round == "west" || player == "west") value_tiles.add("3z");
    else if (round == "north" || player == "north") value_tiles.add("4z");

    for (Meld m in hand.melds) {
      String tileName = m.meldedTiles[0].toString();
      if (value_tiles.contains(tileName)) {
        satisfiedYaku.add("Value Honor");
        han += 1;
        // Handling double yakuhai case:
        if (int.parse(tileName.substring(0,1)) < 5) {
          if (player == round) {
            satisfiedYaku.add("Value Honor");
            han += 1;
          }
        }
      }
    }
  }

  void twinSequences() {
    bool foundDbl = false;
    if (hand.isOpen) return;
    Map<String, int> meldCounts = {};
    for (Meld m in hand.melds) {
      if (m.type != meldType.SEQUENCE) continue;
      if (meldCounts.containsKey(m.toString())) meldCounts[m.toString()] += 1;
      else meldCounts[m.toString()] = 1;
    }

    for(String meld in meldCounts.keys) {
      if (meldCounts[meld] > 2) {
        if (foundDbl) {
          han+=2;
          satisfiedYaku.remove("Twin Sequences");
          satisfiedYaku.add("Double Twin Sequences");
        }
        else {
          foundDbl = true;
          han+=1;
          satisfiedYaku.add("Twin Sequences");
        }
      }
    }
  }

  void concealedTriplets() {
    int count = 0;
    for (Meld m in hand.melds) {
      if (m.type == meldType.TRIPLET && !m.isOpen) count += 1;
    }

    if (count == 4) {
    han = 13;
    satisfiedYaku.add("Four Concealed Triplets");
    }
    else if (count == 3) {
      han+=2;
      satisfiedYaku.add("Three Concealed Triplets");
    }
  }
}