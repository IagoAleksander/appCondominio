library two_letter_icon;

import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/two_letter_icon.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitorDetailsDialog extends StatelessWidget {
  final Visitor visitor;
  final String currentUserId;

  VisitorDetailsDialog(this.visitor, this.currentUserId);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
          Spacer(),
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
                    visitor.accessCode.createdBy == currentUserId
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
                                    padding: EdgeInsets.only(top: 6),
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
                  ],
                ),
        ],
      ),
    );
  }
}
