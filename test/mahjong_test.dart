import 'package:flutter_test/flutter_test.dart';
import 'package:jancam/Mahjong.dart';

void main() {
  test("Sorting Fully Closed Hand", () {
    List<Tile> tileList = [
      Tile(4,"s"),
      Tile(1,"p"),
      Tile(3,"m"),
      Tile(2,"p"),
      Tile(1,"z"),
      Tile(4,"m"),
      Tile(3,"p"),
      Tile(2,"m"),
      Tile(3,"s"),
      Tile(2,"s"),
      Tile(1,"z"),
      Tile(1,"p"),
      Tile(1,"z"),
      Tile(4,"p"),
    ];

    Hand myHand = new Hand(tileList);
    String asString = myHand.toString();
    expect(asString, equals("234m11234p234s111z"));
  });

  test("Sorting Opened Hand", () {
    List<Tile> tileList = [
      Tile(4,"s"),
      Tile(1,"p"),
      Tile(2,"m", true),
      Tile(2,"p"),
      Tile(1,"z"),
      Tile(2,"m", true),
      Tile(3,"p"),
      Tile(2,"m", true),
      Tile(3,"s"),
      Tile(2,"s"),
      Tile(1,"z"),
      Tile(1,"p"),
      Tile(1,"z"),
      Tile(4,"p"),
    ];

    Hand myHand = new Hand(tileList);
    String asString = myHand.toString();
    expect(asString, equals("11234p234s111z222m"));
  });
}
