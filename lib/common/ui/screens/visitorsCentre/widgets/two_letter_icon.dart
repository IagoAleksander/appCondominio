import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class TwoLetterIcon extends StatelessWidget {
  String name;

  TwoLetterIcon(this.name);

  String getName() {
    if (name != null && name.length != 0) {
      name = name.trim();
      while (name.contains('  ')) {
        name = name.replaceAll('  ', ' ');
      }
      List<String> nameSections = name.split(' ');
      if (nameSections.length >= 2) {
        name = nameSections[0].substring(0, 1) +
            nameSections[nameSections.length - 1].substring(0, 1);
      } else if (nameSections.isNotEmpty) {
        name = nameSections[0].substring(0, 2);
      } else {
        return "?";
      }

      return name.toUpperCase();
    }
    return "?";
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        decoration: new BoxDecoration(
          color: ColorsRes.accentColor,
          borderRadius: new BorderRadius.circular(55.0),
        ),
        padding: new EdgeInsets.all(4.0),
        height: 55.0,
        width: 55.0,
        child: Center(
          child: Text(
            getName(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ));
  }
}
