library two_letter_icon;

import 'dart:math';

import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/profile_rule_option_radio.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/two_letter_icon.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/profile_rule.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/globals.dart' as globals;
import '../../../widgets/border_button.dart';

class VisitorDetailsDialog extends StatelessWidget {
  final Visitor visitor;

  VisitorDetailsDialog(this.visitor);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Container(
            decoration: new BoxDecoration(
              color: ColorsRes.accentColor,
              borderRadius: new BorderRadius.circular(55.0),
            ),
            padding: new EdgeInsets.all(4.0),
            height: 55.0,
            width: 55.0,
            child: Center(
              child: TwoLetterIcon(visitor.name),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            visitor.name,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            visitor.rg,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          Spacer(
            flex: 3,
          ),
          new InkWell(
            onTap: () {
              Navigator.pushNamed(context, Constants.registerVisitorRoute,
                  arguments: visitor);
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "Editar informações",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(Icons.edit, color: Colors.white, size: 16.0),
                ],
              ),
            ),
          ),
          Divider(
            color: Colors.white,
          ),
          !visitor.isLiberated
              ? Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Sem acesso",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: <Widget>[
                    visitor.accessCode.createdBy ==
                            globals.firebaseCurrentUser.uid
                        ? InkWell(
                            onTap: visitor.phoneNumber != null
                                ? () async {
                                    await launch(visitor.phoneNumber
                                            .startsWith("55")
                                        ? "https://wa.me/${visitor.phoneNumber}"
                                            "?text=Código de liberação: "
                                            "${visitor.accessCode.accessCodeNumber}"
                                        : "https://wa.me/55${visitor.phoneNumber}"
                                            "?text=Código de liberação: "
                                            "${visitor.accessCode.accessCodeNumber}");
                                  }
                                : null,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(
                                      top: 10, left: 10, right: 10),
                                  child: Text(
                                    "Código de acesso:",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(top: 6, bottom: 10),
                                  child: Text(
                                    visitor.accessCode.accessCodeNumber,
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          )
                        : Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  "Acesso liberado por:",
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              StreamBuilder(
                                stream: Firestore.instance
                                    .collection('users')
                                    .document(visitor.accessCode.createdBy)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Container(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        "(Carregando...)",
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  User user = User.fromJson(snapshot.data.data);

                                  return Container(
                                    padding:
                                        EdgeInsets.only(top: 6, bottom: 10),
                                    child: Text(
                                      user.name,
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('profileRules')
                          .document(visitor.accessCode.profileRuleId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              "(Carregando...)",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        ProfileRule rule =
                            ProfileRule.fromJson(snapshot.data.data);

                        return Container(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            rule.title,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                  ],
                ),
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }

  static Future<String> showVisitorDetails(
      BuildContext context, Visitor visitor) async {
    Dialogs.showLoadingDialog(
      context,
      "Obtendo informações",
    );

    Future<String> status;
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    bool isResponsableUser;

    if (visitor.isLiberated != null && visitor.isLiberated) {
      QuerySnapshot snapshot = await Firestore.instance
          .collection('accessCodes')
          .where("createdTo", isEqualTo: visitor.rg)
          .getDocuments();

      if (snapshot != null && snapshot.documents.isNotEmpty) {
        visitor.accessCode = AccessCode.fromJson(snapshot.documents[0].data);
        isResponsableUser = visitor.accessCode.createdBy == currentUser.uid;
      } else {
        Navigator.pop(context);
        return Future.value("ERROR");
      }
    }

    Navigator.pop(context);

    Widget continueButton = visitor.isLiberated
        ? BorderButton(
            "Remover acesso",
            Colors.redAccent,
            () {
              if ((globals.isUserAdmin || isResponsableUser) &&
                  visitor.accessCode != null) {
                status = showRemovalAlertDialog(context, visitor);
              } else {
                Dialogs.showAlertDialog(context,
                    "Você não tem permissão para remover o acesso desse visitante");
              }
            },
          )
        : BorderButton(
            "Liberar acesso",
            ColorsRes.accentColor,
            () async {
              status =
                  showChooseProfileDialog(context, visitor, currentUser.uid);
            },
          );

// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: VisitorDetailsDialog(visitor),
      actions: [
        continueButton,
      ],
    );

// show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return status;
  }

  static Future<String> showChooseProfileDialog(
      BuildContext context, Visitor visitor, String currentUserId) async {
    Future<String> status;
    int _radioValue = -1;
    bool errorNoRadioSelected = false;
    ProfileRule profileRule;
// set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = Future.value("CANCEL");
      },
    );

// show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ColorsRes.primaryColorLight,
            content: Theme(
              data: ThemeData(
                  brightness: Brightness.dark,
                  unselectedWidgetColor: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Escolha um perfil para o acesso do visitante",
                    style: TextStyle(
                      color: errorNoRadioSelected ? Colors.redAccent : Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection('profileRules')
                        .where("isActive", isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data.documents.length == 0) {
                        return Container(
                            child: Center(
                                child: Text(
                          "Não há regras de\nperfis cadastradas",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          textAlign: TextAlign.center,
                        )));
                      }

                      return Container(
                        width: 300,
                        height: 300,
                        child: ListView.builder(
                          reverse: false,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, int index) {
                            ProfileRule rule = ProfileRule.fromJson(
                                snapshot.data.documents[index].data);
                            rule.id = snapshot.data.documents[index].documentID;
                            return Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                ProfileRuleOptionRadio(
                                    text: rule.title +
                                        "\n" +
                                        rule.value.toString() +
                                        " " +
                                        rule.unit +
                                        " de acesso",
                                    onChangeFunction: (value) {
                                      setState(() {
                                        profileRule = rule;
                                        _radioValue = value;
                                      });
                                    },
                                    onTapFunction: () {
                                      setState(() {
                                        profileRule = rule;
                                        _radioValue = index;
                                      });
                                    },
                                    radioValue: index,
                                    groupValue: _radioValue),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              cancelButton,
              FlatButton(
                child: Text(
                  "Continuar",
                  style: TextStyle(color: Colors.white),
                ),
// ignore: missing_return
                onPressed: () async {
                  if (_radioValue == -1) {
                    setState(() {
                      errorNoRadioSelected = true;
                    });
                  } else {
                    status = showReleaseAlertDialog(
                        context, visitor, currentUserId, profileRule);
                  }
                },
              ),
            ],
          );
        });
      },
    );

    return status;
  }

  static Future<String> showReleaseAlertDialog(BuildContext context,
      Visitor visitor, String currentUserId, ProfileRule profileRule) async {
    String status;
// set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = "CANCEL";
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        Dialogs.showLoadingDialog(
          context,
          "Liberando acesso",
        );

        FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
        var rng = new Random();
        var snapShot;
        String code;

        do {
          code = rng.nextInt(1000000).toString();

          snapShot = await Firestore.instance
              .collection('accessCodes')
              .document(code)
              .get();
        } while (snapShot != null && snapShot.exists);

        AccessCode accessCode = new AccessCode();
        accessCode.accessCodeNumber = code;
        accessCode.profileRuleId = profileRule.id;
        accessCode.createdBy = currentUser.uid;
        accessCode.createdTo = visitor.rg;
        accessCode.isActive = true;
        accessCode.creationDateInMillis = DateTime.now().millisecondsSinceEpoch;

        await Firestore.instance
            .collection('accessCodes')
            .document(accessCode.accessCodeNumber)
            .setData(accessCode.toJson());

        visitor.isLiberated = true;

        await Firestore.instance
            .collection('visitors')
            .document(visitor.rg)
            .setData(visitor.toJson());

        status = "SUCCESS";
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja liberar o acesso de tipo ${profileRule.title} para ${visitor.name} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

// show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(status);
  }

  static Future<String> showRemovalAlertDialog(
      BuildContext context, Visitor visitor) async {
    String status;
// set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = "CANCEL";
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        Dialogs.showLoadingDialog(
          context,
          "Removendo acesso",
        );

        await Firestore.instance
            .collection('accessCodes')
            .document(visitor.accessCode.accessCodeNumber)
            .updateData({"isActive": false});

        visitor.isLiberated = false;

        await Firestore.instance
            .collection('visitors')
            .document(visitor.rg)
            .setData(visitor.toJson());

        status = "SUCCESS";

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que remover o acesso de ${visitor.name} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

// show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(status);
  }
}
