import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WaitingApprovalCard extends StatelessWidget {
  final String personName;
  final String rgNumber;
  final String buildingNumber;
  final String apartmentNumber;
  final Function onTapFunction;

  WaitingApprovalCard(
      {@required this.personName,
      @required this.rgNumber,
      @required this.buildingNumber,
      @required this.apartmentNumber,
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
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            personName,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 4,
              ),
              Text(rgNumber,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white)),
              SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.business, color: ColorsRes.accentColor),
                  Text(" " + buildingNumber + "     ",
                      style: TextStyle(color: Colors.white)),
                  Icon(Icons.home, color: ColorsRes.accentColor),
                  Text(" " + apartmentNumber,
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
          trailing: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: ColorsRes.accentColor,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 8.0, left: 10.0),
                        child: Text(
                          "Liberar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right,
                          color: Colors.white, size: 30.0),
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                      onTap: onTapFunction,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
