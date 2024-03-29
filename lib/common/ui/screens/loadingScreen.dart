import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final bool showHeader;

  LoadingScreen({this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: Column(children: <Widget>[
        showHeader
            ? Container(
                padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                child: Image(image: AssetImage('assets/logo.png')))
            : Container(),
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
                margin:
                    new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                child: Container(
                  decoration:
                      BoxDecoration(color: ColorsRes.cardBackgroundColor),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: <Widget>[
                      Text(
                        "Carregando dados.",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Por favor, aguarde!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
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
      ]),
    );
  }
}
