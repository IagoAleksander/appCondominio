import 'dart:async';

import 'package:app_condominio/common/ui/screens/visitorsCentre/visitorsLiberatedPage.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/admin/ui/visitorsCentre/widgets/waiting_approval_card.dart';
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

  VisitorsLiberatedPage visitorsLiberatedPage;
}

class _VisitorsCentreAdminScreenState extends State<VisitorsCentreAdminScreen> {
  int currentPage = 0;

  @override
  void initState() {
    widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.person, title: "Lista de Visitantes"),
          TabData(iconData: Icons.history, title: "Acessos Liberados"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
//            if (position == 0) {
//              visitorsCentreBloc.search(_searchFieldController.text);
//            }
//            if (position == 1) {
//              visitorsCentreBloc.updateHistoryList();
//            }
          });
        },
        barBackgroundColor: ColorsRes.primaryColorLight,
        circleColor: ColorsRes.primaryColor,
        inactiveIconColor: Colors.white,
        textColor: Colors.white,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: ColorsRes.primaryColorLight,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("Centro de Visitantes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                ),
              ),
            ),
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ],
        body: currentPage == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Flexible(
                      fit: FlexFit.loose,
                      child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .where("status",
                                  isEqualTo:
                                      (Status.pendingApproval.toString()))
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data.documents.length == 0) {
                              return Container(
                                  child: Center(
                                      child: Text(
                                "Não há cadastros\naguardando aprovação",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                                textAlign: TextAlign.center,
                              )));
                            }

                            return ListView.builder(
                                padding: EdgeInsets.all(8.0),
                                reverse: false,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (_, int index) {
                                  User user = User.fromJson(
                                      snapshot.data.documents[index].data);
                                  return WaitingApprovalCard(
                                    personName: user.name,
                                    rgNumber: user.rg,
                                    apartmentNumber: user.apartment,
                                    buildingNumber: user.building,
                                    onTapFunction: () {
                                      showAlertDialog(
                                          context,
                                          user,
                                          snapshot.data.documents[index]
                                              .documentID);
                                    },
                                  );
                                });
                          }),
                    )
                  ],
                ),
              )
            : widget.visitorsLiberatedPage,
      ),
    );
  }

  static showAlertDialog(BuildContext context, User user, String userID) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Dialogs.showLoadingDialog(
          context,
          "Liberando acesso",
        );

        user.status = Status.active;
        Firestore.instance
            .collection('users')
            .document(userID)
            .setData(user.toJson());

        Timer(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja liberar o acesso para ${user.name} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  refresh(Visitor visitor) {
    setState(() {
      widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    });
  }
}
