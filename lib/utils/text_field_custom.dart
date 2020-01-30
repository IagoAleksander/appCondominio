
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'colors_res.dart';

class TextFieldCustom extends StatelessWidget {
  final String title, initialValue;
  final bool obscureText, readOnly;
  final Function(String) onChanged, onFieldSubmitted;
  final Stream<String> stream;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  final IconData prefixIcon;

  TextFieldCustom(
      {@required this.title,
      this.obscureText = false,
      this.onChanged,
      this.prefixIcon,
      @required this.onFieldSubmitted,
      @required this.stream,
      @required this.focusNode,
      this.textInputType = TextInputType.text,
      this.textInputAction = TextInputAction.next,
      this.readOnly = false,
      this.textCapitalization = TextCapitalization.sentences,
      this.initialValue});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: stream,
        builder: (context, snapshot) {
          return Column(
            children: <Widget>[
              TextFormField(
                initialValue: initialValue != "" ? initialValue : null,
                onChanged: onChanged,
                focusNode: focusNode,
                textInputAction: textInputAction,
                keyboardType: textInputType,
                autocorrect: true,
                decoration: InputDecoration(
                  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: ColorsRes.disable)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: ColorsRes.primaryColor)),
                  labelText: title,
                  errorText: snapshot.hasError ? snapshot.error : null,
                  isDense: true,
                ),
                onSaved: onChanged,
                obscureText: obscureText,
                onFieldSubmitted: onFieldSubmitted,
                readOnly: readOnly,
                maxLines: 1,
                textCapitalization: textCapitalization,
                style: TextStyle(fontSize: 18),
              ),
            ],
          );
        });
  }
}
