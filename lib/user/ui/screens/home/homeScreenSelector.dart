import 'package:app_condominio/admin/homeScreenAdmin.dart';
import 'package:app_condominio/common/ui/screens/loadingScreen.dart';
import 'package:app_condominio/common/ui/screens/waitingApprovalScreen.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FirebaseUser mCurrentUser;
  bool isUserAdmin = false;
  bool isClientApproved = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.currentUser().asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingScreen();
          mCurrentUser = snapshot.data;

          return StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(mCurrentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingScreen();
                }

                if (!snapshot.data.exists) {
                  isUserAdmin = true;
                } else {
                  User user = User.fromJson(snapshot.data.data);
                  if (user.status == Status.active)
                    isClientApproved = true;
                  else {
                    isClientApproved = false;
                  }
                }

                return Scaffold(
                  backgroundColor: ColorsRes.primaryColor,
                  body: isUserAdmin
                      ? returnPage(currentPage)
                      : !isClientApproved
                          ? WaitingApprovalScreen()
                          : returnPage(currentPage),
                  bottomNavigationBar: !isClientApproved
                      ? null
                      : FancyBottomNavigation(
                          tabs: [
                            TabData(iconData: Icons.home, title: "Home"),
                            TabData(
                                iconData: Icons.attach_money,
                                title: "Finanças"),
                            TabData(
                                iconData: Icons.content_paste,
                                title: "Notificações"),
                            TabData(
                                iconData: Icons.settings,
                                title: "Configurações")
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
              });
        });
  }

  Widget returnPage(int page) {
    if (isUserAdmin) {
      switch (page) {
        case 0:
          return HomeScreenAdmin();
        case 1:
          return HomeScreen2();
        case 2:
          return HomeScreen3();
        case 3:
          return HomeScreen4();
      }
    } else {
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
    }
    return HomeScreen();
  }
}
