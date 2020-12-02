import 'package:flutter/material.dart';

class MeldEntry extends PopupMenuEntry<int> {
  @override
  double height = 100;

  // height doesn't matter, as long as we are not giving
  // initialValue to showMenu().

  @override
  bool represents(int n) => n == 0 || n == 1 || n == 2;

  @override
  MeldEntryState createState() => MeldEntryState();
}

class MeldEntryState extends State<MeldEntry> {
  void _pon() {
    // This is how you close the popup menu and return user selection.
    Navigator.pop<int>(context, 0);
  }

  void _chi() {
    Navigator.pop<int>(context, 1);
  }

  void _kan() {
    Navigator.pop<int>(context, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: FlatButton(onPressed: _pon, child: Text('Pon'))),
        Expanded(child: FlatButton(onPressed: _chi, child: Text('Chi'))),
        Expanded(child: FlatButton(onPressed: _kan, child: Text('Kan'))),
      ],
    );
  }
}