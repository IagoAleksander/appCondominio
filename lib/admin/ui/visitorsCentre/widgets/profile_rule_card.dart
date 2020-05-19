import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProfileRuleCard extends StatelessWidget {
  final String profileTitle;
  final int value;
  final String unit;
  final Function onEditFunction;
  final Function onDeleteFunction;

  ProfileRuleCard(
      {@required this.profileTitle,
      @required this.value,
      @required this.unit,
      this.onEditFunction,
      this.onDeleteFunction});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: ColorsRes.cardBackgroundColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileTitle,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: <Widget>[
                            Text("Acesso por",
                                style: TextStyle(color: Colors.white)),
                            Text(" " + value.toString(),
                                style: TextStyle(color: Colors.white)),
                            Text(" " + unit,
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: 60,
                      color: ColorsRes.primaryColorLight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.edit, color: Colors.white, size: 20.0),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              "Editar",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onEditFunction,
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    Container(
                      height: 80,
                      width: 60,
                      color: Colors.redAccent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.delete_forever,
                              color: Colors.white, size: 20.0),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Excluir",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onDeleteFunction,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
