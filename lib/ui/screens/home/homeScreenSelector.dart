import 'package:app_condominio/utils/colors_res.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

import 'HomeScreen2.dart';
import 'HomeScreen3.dart';
import 'HomeScreen4.dart';
import 'homeScreen.dart';

class HomeScreenSelector extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenSelector> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: returnPage(currentPage),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.home, title: "Home"),
          TabData(iconData: Icons.attach_money, title: "Finanças"),
          TabData(iconData: Icons.content_paste, title: "Notificações"),
          TabData(iconData: Icons.settings, title: "Configurações")
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
        barBackgroundColor: ColorsRes.primaryColorLight,
        circleColor: ColorsRes.primaryColor,
        inactiveIconColor: Colors.white,
        textColor: Colors.white,
      ),
    );
  }

  Widget returnPage(int page) {
    switch (page) {
      case 0:
        return HomeScreen();
      case 1:
        return HomeScreen2();
      case 2:
        return HomeScreen3();
      case 3:
        return HomeScreen4();
    }
    return HomeScreen();
  }
}
