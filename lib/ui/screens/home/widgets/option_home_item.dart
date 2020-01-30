import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class OptionHomeItem extends StatelessWidget {
  final String labelText;
  final IconData iconData;
  final Function onTapFunction;

  OptionHomeItem({
    @required this.labelText,
    @required this.iconData,
    this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      InkWell(
        onTap: onTapFunction,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        child: Ink(
          width: 90,
          height: 90,
          decoration: new BoxDecoration(
              color: ColorsRes.primaryColorLight,
              borderRadius: new BorderRadius.all(const Radius.circular(10.0))),
//                    color: Colors.blue,
          padding: EdgeInsets.all(12.0),
          child: Icon(
            iconData,
            color: Colors.white,
            size: 40.0,
          ),
        ),
      ),
      SizedBox(height: 8),
      Center(
        child: Container(
            width: 100,
            height: 60,
            child: Text(
              labelText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
//              maxLines: 2,
            )),
      )
    ]);
  }
}
