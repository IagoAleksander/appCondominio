import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/access_history.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'access_card.dart';

class AccessHistoryPage extends StatefulWidget {
  @override
  _AccessHistoryPageState createState() => _AccessHistoryPageState();
}

class _AccessHistoryPageState extends State<AccessHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StandardButton(
              label: "Editar regras de acesso",
              backgroundColor: ColorsRes.primaryColorLight,
              onTapFunction: () {
                Navigator.pushNamed(context, Constants.profileRulesRoute);
              },
            ),
          ),
          Container(
            color: ColorsRes.primaryColorLight,
            height: 1,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('accessHistory')
                  .orderBy('accessAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingIndicator();
                }
                if (!snapshot.hasData || snapshot.data.documents.length == 0) {
                  return LayoutBuilder(
                    builder: (context, constraint) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraint.maxHeight),
                          child: Center(
                            child: Text(
                              "Não há acessos\na serem exibidos",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, int index) {
                    AccessHistory accessHistory = AccessHistory.fromJson(
                        snapshot.data.documents[index].data);
                    return AccessHistoryCard(
                      accessHistory: accessHistory,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
