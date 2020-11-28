import 'package:flutter_test/flutter_test.dart';
import 'package:jancam/Mahjong.dart';
import 'package:jancam/Scorer.dart';

void main() {
  RawTiles closed = new RawTiles.fromString("234m11234p234s111z");
  RawTiles open = new RawTiles.fromString("11234p234s111z|222m");

  Scorer closedS = Scorer(closed, Tile(2, "p"));
  Scorer openS = Scorer(open, Tile(2, "p"));

  test("RawTiles creation from String", () {
    RawTiles testHand = new RawTiles.fromString("222333444p22z|111z");
    expect(testHand.toString(), equals("222333444p22z|111z"));
  });

  test("Sorting Fully Closed Hand", () {
    RawTiles unsortedClosed = new RawTiles.fromString("1z2m1z3m1z4m4s1p3s1p2s2p4p3p");
    String asString = unsortedClosed.toString();
    expect(asString, equals("234m11234p234s111z"));
  });

  // TODO: Use default constructor for sorting test since this is redundant.
  /*test("Sorting Opened Hand", () {
    String asString = open.toString();
    expect(asString, equals("11234p234s111z|222m"));
  });*/

  test("Splitting hand into suits", () {
    List<RawTiles> splitLists = closedS.splitBySuit(closed.tiles);

    List<String> splitListsResults = new List();

    // Getting string representations to make comparison possible
    splitLists.forEach((rawTiles) {
      splitListsResults.add(rawTiles.toString());
    });

    // Expected results
    var manzu = "234m";
    var pinzu = "11234p";
    var souzu = "234s";
    var honors = "111z";

    expect(splitListsResults, equals([manzu,pinzu,souzu,honors]));
  });

  test("Finding valid compositions in one suit", () {
    RawTiles manzu = new RawTiles.fromString("222333444m");
    Scorer s = new Scorer(manzu, manzu.tiles[0]);

    List<List<Meld>> expected = [];

    List<Meld> pons = [];
    // 222m, 333m, 444m
    for (int i = 2; i < 5; i++) {
      List<Tile> meldedTiles = [];
      for (int j = 0; j < 3; j++) {
        meldedTiles.add(Tile(i,"m"));
      }
      pons.add(Meld(meldedTiles));
    }

    List<Meld> chis = [];
    for (int i = 0; i < 3; i++) {
      chis.add(Meld([Tile(2,"m"), Tile(3,"m"), Tile(4,"m")])); // 234m;
    }

    expected.add(pons);
    expected.add(chis);

    // Expected should now be a List of List<Melds> as follows:
    // [222m, 333m, 444m], [234m, 234m, 234m]
    expect(s.getValidCompositions(manzu.tiles).toString(), equals(expected.toString()));
  });

  test("Melds combined properly, compositions for closed hand", () {
    RawTiles fullHand = new RawTiles.fromString("223344m11p234m567s");
    Scorer s = new Scorer(fullHand, fullHand.tiles[0]);
    Meld souzu = new Meld([Tile(5, "s"), Tile(6, "s"), Tile(7, "s")]);
    Meld pair = new Meld([Tile(1, "p"), Tile(1, "p")]);
    Meld manzu_seq = new Meld([Tile(2, "m"), Tile(3, "m"), Tile(4, "m")]);

    List<Meld> manzu_tri = [];
    for (int i = 2; i < 5; i++) {
      manzu_tri.add(new Meld([Tile(i, "m"), Tile(i, "m"), Tile(i, "m")]));
    }
    manzu_tri.add(souzu);

    Hand hand1 = Hand([manzu_seq, manzu_seq, manzu_seq, souzu], pair, fullHand.tiles[0]);
    Hand hand2 = Hand(manzu_tri, pair, fullHand.tiles[0]);
    expect(s.getValidHands().toString(), equals([hand2, hand1].toString()));
  });

  test("Melds combined properly, compositions for open hand", () {
    RawTiles fullHand = new RawTiles.fromString("223344m11p234m|567s");
    Scorer s = new Scorer(fullHand, fullHand.tiles[0]);
    // Open souzu sequence
    Meld souzu = new Meld([Tile(5, "s", true), Tile(6, "s", true), Tile(7, "s", true)]);
    Meld pair = new Meld([Tile(1, "p"), Tile(1, "p")]);
    Meld manzu_seq = new Meld([Tile(2, "m"), Tile(3, "m"), Tile(4, "m")]);

    List<Meld> manzu_tri = [];
    for (int i = 2; i < 5; i++) {
      manzu_tri.add(new Meld([Tile(i, "m"), Tile(i, "m"), Tile(i, "m")]));
    }
    manzu_tri.add(souzu);

    Hand hand1 = Hand([manzu_seq, manzu_seq, manzu_seq, souzu], pair, fullHand.tiles[0]);
    Hand hand2 = Hand(manzu_tri, pair, fullHand.tiles[0]);
    expect(s.getValidHands().toString(), equals([hand2, hand1].toString()));
  });
}
