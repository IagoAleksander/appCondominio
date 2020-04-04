import 'package:app_condominio/admin/ui/homeScreenAdmin.dart';
import 'package:app_condominio/common/ui/screens/loadingScreen.dart';
import 'package:app_condominio/common/ui/screens/waitingApprovalScreen.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../../user/ui/screens/home/HomeScreen2.dart';
import '../../../../user/ui/screens/home/HomeScreen3.dart';
import '../../../../user/ui/screens/home/HomeScreen4.dart';
import '../../../../user/ui/screens/home/homeScreen.dart';
import '../../../../utils/globals.dart' as globals;

class HomeScreenSelector extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenSelector> {
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  User mCurrentUser;
  bool isClientApproved = false;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    bool _isDialogShowing = false;

    void _showDialog(Map<String, dynamic> message) async {
      _isDialogShowing = true;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(message['notification']['title']),
          content: Text(message['notification']['body']),
          actions: <Widget>[
            FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _isDialogShowing = false;
                }),
          ],
        ),
      ).then((val) {
        _isDialogShowing = false;
      });
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        if (!_isDialogShowing) {
          _showDialog(message);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.currentUser().asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LoadingScreen();
          globals.firebaseCurrentUser = snapshot.data;

          return StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(globals.firebaseCurrentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingScreen();
                }

                if (snapshot.data.exists) {
                  mCurrentUser = User.fromJson(snapshot.data.data);
                  if (mCurrentUser.isAdmin) {
                    globals.isUserAdmin = true;
                  } else {
                    if (mCurrentUser.status == Status.active)
                      isClientApproved = true;
                    else {
                      isClientApproved = false;
                    }
                  }
                  _setUserNotificationToken();
                } else {
                  //TODO
                }

                return Scaffold(
                  backgroundColor: ColorsRes.primaryColor,
                  body: globals.isUserAdmin
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
    if (globals.isUserAdmin) {
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

  _setUserNotificationToken() async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      print(fcmToken);
      mCurrentUser.notificationToken = fcmToken;

      _db
          .collection('users')
          .document(globals.firebaseCurrentUser.uid)
          .setData(mCurrentUser.toJson());
    }
  }
}
