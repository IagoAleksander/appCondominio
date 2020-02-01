import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/waiting_approval_card.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

class VisitorsCentreScreen extends StatefulWidget {
  @override
  _VisitorsCentreScreenState createState() => _VisitorsCentreScreenState();
}

class _VisitorsCentreScreenState extends State<VisitorsCentreScreen> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Flexible(
                fit: FlexFit.loose,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .where("status",
                            isEqualTo: (Status.pendingApproval.toString()))
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data.documents.length == 0) {
                        return Container(
                            child: Center(
                                child: Text(
                          "Não há cadastros\naguardando aprovação",
                          style: TextStyle(color: Colors.white, fontSize: 24),
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
                                showAlertDialog(context, user,
                                    snapshot.data.documents[index].documentID);
                              },
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  static showAlertDialog(BuildContext context, User user, String userID) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text("Continuar"),
      onPressed: () {
        user.status = Status.active;
        Firestore.instance
            .collection('users')
            .document(userID)
            .setData(user.toJson());
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
          "Você tem certeza de que deseja liberar o acesso para ${user.name} ?"),
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
}
