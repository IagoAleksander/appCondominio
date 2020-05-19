import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class ProfileRuleOptionRadio extends StatelessWidget {
  final String text;
  final int radioValue;
  final int groupValue;
  final Function onChangeFunction;
  final Function onTapFunction;

  ProfileRuleOptionRadio({
    this.text,
    this.radioValue,
    this.groupValue,
    this.onChangeFunction,
    this.onTapFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Radio(
          value: radioValue,
          groupValue: groupValue,
          onChanged: onChangeFunction,
          activeColor: ColorsRes.accentColor,
          focusColor: ColorsRes.accentColor,
        ),
        new GestureDetector(
          onTap: onTapFunction,
          child: Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                text,
                style: new TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
