import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VisitorCard extends StatelessWidget {
  final String personName;
  final String rgNumber;
  final bool isLiberated;
  final bool canLiberate;
  final Function onTapFunction;

  VisitorCard(
      {@required this.personName,
      @required this.rgNumber,
      this.isLiberated,
      this.canLiberate,
      this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: ColorsRes.cardBackgroundColor),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: Icon(
                  isLiberated? Icons.lock_open : Icons.lock_outline,
                  color: isLiberated? ColorsRes.accentColor : Colors.redAccent,
                  size: 30,
                ),
              ),
            ],
          ),
          title: Text(
            personName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Text(rgNumber,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: Colors.white,
            size: 30.0,
          ),
          onTap: onTapFunction,
        ),
      ),
    );
  }
}
