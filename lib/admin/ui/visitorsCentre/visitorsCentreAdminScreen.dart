import 'dart:async';

import 'package:app_condominio/admin/ui/visitorsCentre/widgets/accessHistoryPage.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/visitorsLiberatedPage.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/admin/ui/residentsCentre/widgets/waiting_approval_card.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class VisitorsCentreAdminScreen extends StatefulWidget {
  @override
  _VisitorsCentreAdminScreenState createState() =>
      _VisitorsCentreAdminScreenState();

  AccessHistoryPage accessHistoryPage;
  VisitorsLiberatedPage visitorsLiberatedPage;
}

class _VisitorsCentreAdminScreenState extends State<VisitorsCentreAdminScreen> {
  int currentPage = 0;

  @override
  void initState() {
    widget.accessHistoryPage = AccessHistoryPage();
    widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Centro de Visitantes",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      backgroundColor: ColorsRes.primaryColor,
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.history, title: "Histórico de acessos"),
          TabData(iconData: Icons.lock_open, title: "Acessos Liberados"),
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
      body: currentPage == 0
          ? widget.accessHistoryPage
          : widget.visitorsLiberatedPage,
//      ),
    );
  }

  refresh(Visitor visitor) {
    setState(() {
      widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    });
  }
}
