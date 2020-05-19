import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final IconData icon;
  final Function onTapFunction;

  StandardButton(
      {@required this.label,
      this.backgroundColor = ColorsRes.primaryColorLight,
      this.icon,
      this.onTapFunction});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0,
                      left: 10.0,
                      right: 10.0),
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                icon != null
                    ? Icon(icon, color: Colors.white, size: 30.0)
                    : Container(),
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
    );
  }
}
