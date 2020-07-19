import 'package:flutter/material.dart';

class ColorsRes{

  ///Base Colors
  static const Color background = Color(0xFF122235);

  ///Primary Colors
  static const Color primaryColor = Color(0xFF122235);
  static const Color primaryColorLight = Color(0xFF3b495f);
  static const Color primaryColorDark = Color(0xFF00000f);


  static const Color cardBackgroundColor = Color.fromRGBO(64, 75, 96, .9);

  ///Secondary Colors
//  static const Color secondaryColor = Color(0xFF1DE9B6);

  ///Accent Colors
  static const Color accentColor = Color(0xFF5AB9B6);

  ///Font Colors
  static const Color primaryTextColor = Color(0xDE000000);
  static const Color secondaryTextColor = Color(0x99000000);
  static const Color disableTextColor = Color(0x61000000);

  ///Others colors
  static const Color disable = Color(0xFFD3D3D3);
  static const Color greenSuccess = Color(0xFF27AE60);
  static const Color dividerColor = Color(0xFFE0E0E0);

  //Circular progress indicator color
  static const Color circularProgressIndicatorColor = const Color(0xff6d6e71);

  static Map<int, Color> color =
  {
    50:Color.fromRGBO(136,14,79, .1),
    100:Color.fromRGBO(136,14,79, .2),
    200:Color.fromRGBO(136,14,79, .3),
    300:Color.fromRGBO(136,14,79, .4),
    400:Color.fromRGBO(136,14,79, .5),
    500:Color.fromRGBO(136,14,79, .6),
    600:Color.fromRGBO(136,14,79, .7),
    700:Color.fromRGBO(136,14,79, .8),
    800:Color.fromRGBO(136,14,79, .9),
    900:Color.fromRGBO(136,14,79, 1),
  };
}