import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class StandardButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final Function onTapFunction;
  final bool isMin;

  StandardButton(
      {@required this.label,
      this.backgroundColor = ColorsRes.primaryColorLight,
      this.prefixIcon,
      this.suffixIcon,
      this.onTapFunction,
      this.isMin = true});

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
              mainAxisSize: isMin ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                prefixIcon != null
                    ? Icon(prefixIcon, color: Colors.white, size: 18.0)
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(
                      top: 8.0, bottom: 8.0, left: 10.0, right: 10.0),
                  child: Text(
                    label,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                suffixIcon != null
                    ? Icon(suffixIcon, color: Colors.white, size: 30.0)
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
