import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UserVisualizationCard extends StatelessWidget {
  final String personName;
  final String rgNumber;
  final String buildingNumber;
  final String apartmentNumber;

  UserVisualizationCard({
    @required this.personName,
    @required this.rgNumber,
    @required this.buildingNumber,
    @required this.apartmentNumber,
  });

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
              EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(
            personName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(rgNumber,
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white)),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.business, color: ColorsRes.accentColor),
              Text(" " + buildingNumber + "     ",
                  style: TextStyle(color: Colors.white)),
              Icon(Icons.home, color: ColorsRes.accentColor),
              Text(" " + apartmentNumber,
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
