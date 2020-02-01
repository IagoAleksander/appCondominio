import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final _text;
  final _snapshot;
  final _function;
  final _fallbackFunction;

  Button(this._text, this._snapshot, this._function, this._fallbackFunction);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        height: 56,
        color: Theme
            .of(context)
            .primaryColor,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(_text),
        disabledColor: Theme
            .of(context)
            .disabledColor,
        onPressed: _snapshot.hasData ? _function : _fallbackFunction);
  }
}


