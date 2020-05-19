import 'package:app_condominio/user/ui/screens/home/widgets/option_home_item.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class WaitingApprovalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
          child: Image(image: AssetImage('assets/logo.png'))),
      Spacer(
        flex: 4,
      ),
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              elevation: 8.0,
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(color: ColorsRes.cardBackgroundColor),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: <Widget>[
                    Text(
                      "Aguardando aprovação de cadastro",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Caso necessário procure o síndico",
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.white)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
      Spacer(
        flex: 5,
      ),
    ]);
  }
}
