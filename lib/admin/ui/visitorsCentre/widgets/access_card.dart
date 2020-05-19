import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/access_history.dart';
import 'package:app_condominio/models/profile_rule.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AccessHistoryCard extends StatelessWidget {
  final formatterDate = new DateFormat('dd/MM/yyyy');
  final formatterTime = new DateFormat('H:m');
  final AccessHistory accessHistory;
  final Function onTapFunction;

  AccessHistoryCard({@required this.accessHistory, this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: ColorsRes.cardBackgroundColor),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Row(
            children: <Widget>[
              Icon(Icons.today, color: ColorsRes.accentColor),
              Text(
                  " " +
                      formatterDate.format(DateTime.fromMillisecondsSinceEpoch(
                          accessHistory.accessAt)) +
                      "     ",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              Icon(Icons.access_time, color: ColorsRes.accentColor),
              Text(
                  " " +
                      formatterTime.format(DateTime.fromMillisecondsSinceEpoch(
                          accessHistory.accessAt)) +
                      "     ",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          subtitle: StreamBuilder(
            stream: Firestore.instance
                .collection('accessCodes')
                .document(accessHistory.accessCodeNumber)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "(Carregando...)",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                );
              }

              AccessCode accessCode = AccessCode.fromJson(snapshot.data.data);

              return StreamBuilder(
                stream: Firestore.instance
                    .collection('visitors')
                    .document(accessCode.createdTo)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "(Carregando...)",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  Visitor visitor = Visitor.fromJson(snapshot.data.data);

                  return Container(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          " " + visitor.name,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        StreamBuilder(
                            stream: Firestore.instance
                                .collection('profileRules')
                                .document(accessCode.profileRuleId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Text(
                                    " Perfil de acesso: (Carregando...)",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                );
                              }
                              ProfileRule rule =
                                  ProfileRule.fromJson(snapshot.data.data);
                              return Text(
                                " Perfil de acesso: " + rule.title,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              );
                            }),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
