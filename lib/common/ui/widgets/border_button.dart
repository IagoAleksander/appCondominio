import 'package:flutter/material.dart';

class BorderButton extends StatelessWidget {
  final String label;
  final Color borderColor;
  final Function onTapFunction;

  BorderButton(this.label, this.borderColor, this.onTapFunction);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
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
                  padding:
                  const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 10.0),
                  child: Text(
                    label,
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
    );
  }
}
