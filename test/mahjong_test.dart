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

  test("Valid comps for entire hand", () {
    RawTiles fullHand = new RawTiles.fromString("223344m11p234567s");
    Scorer s = new Scorer(fullHand, fullHand.tiles[0]);
    s.getValidHands();
  });
}
