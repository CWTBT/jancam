import 'YakuList.dart';
import 'Mahjong.dart';

class Yaku {
  int han = 0;
  Hand hand;
  String round = "";
  String player = "";
  List<String> satisfiedYaku = [];

  Yaku(this.hand, this.round, this.player);

  void calculateHan() {
    allSimples();
    mixedSequences();
  }

  void allSimples() {
    for (Meld m in hand.melds) {
      String s = m.toString();
      if (s.contains("z") || s.contains("1") || s.contains("9")) return;
    }
    han += 1;
    satisfiedYaku.add("All Simples");
  }

  void mixedSequences() {
    List<String> manzu = [];
    List<String> pinzu = [];
    List<String> souzu = [];
    for (Meld m in hand.melds) {
      String s = m.toString();
      if (s.endsWith("m")) manzu.add(s.substring(0, s.length - 1));
      else if (s.endsWith("p")) pinzu.add(s.substring(0, s.length - 1));
      else if (s.endsWith("s")) souzu.add(s.substring(0, s.length - 1));
    }

    print(manzu);
    for (String meldString in manzu) {
      if (pinzu.contains(meldString) && souzu.contains(meldString)) {
        han += 2;
        satisfiedYaku.add("Mixed Sequences");
      }
    }
  }
}