import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextFormFieldAddress extends StatelessWidget {
  final String addressText;
  final String hintText;
  final bool isEditing;
  final bool isError;
  final FocusNode focusNode;
  final Function onChangeFunction;

  TextFormFieldAddress({
    @required this.addressText,
    @required this.hintText,
    @required this.isEditing,
    this.focusNode,
    this.isError = false,
    this.onChangeFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: isEditing
          ? TextFormField(
              focusNode: focusNode,
              initialValue: addressText,
              onChanged: onChangeFunction,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: hintText,
                hintStyle:
                    TextStyle(color: isError ? Colors.redAccent : Colors.white),
              ),
              style: TextStyle(
                color: Colors.white,
              ),
            )
          : Text(
              addressText == null ? "" : addressText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
    );
  }
}
