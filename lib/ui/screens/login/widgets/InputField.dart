import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final bool obscure;
  final Stream<String> stream;
  final Function onChanged;

  InputField(
      {@required this.labelText,
      @required this.obscure,
      @required this.stream,
      @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: onChanged,
            obscureText: obscure,
            style: TextStyle(),
            decoration: InputDecoration(
              hintStyle: TextStyle(fontSize: 16),
              labelText: labelText,
              labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12)),
              errorText: snapshot.hasError ? snapshot.error : null,
              contentPadding: EdgeInsets.only(top: 22, bottom: 8),
            ),
          );
        });
  }
}
