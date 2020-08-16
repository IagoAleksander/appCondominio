import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class TextFormFieldCustom extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String labelError;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final IconData iconData;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter> textInputFormatter;
  final Function(String) onChanged;
  final Function validator;
  final bool obscureText;
  final bool isError;
  final TextEditingController controller;
  final bool isOptional;
  final bool enabled;
  final int minLines;
  final int maxLines;

  TextFormFieldCustom(
      {this.labelText,
      this.hintText,
      this.labelError = "Preencha corretamente o campo",
      this.iconData,
      this.focusNode,
      this.nextFocusNode,
      this.textInputType,
      this.textInputAction,
      this.textInputFormatter,
      this.onChanged,
      this.validator = Validators.validateNotEmpty,
      this.obscureText = false,
      this.isError = false,
      this.controller,
      this.isOptional = false,
      this.enabled = true,
      this.minLines = 1,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: (term) {
        if (focusNode != null && nextFocusNode != null) {
          _fieldFocusChange(context, focusNode, nextFocusNode);
        }
      },
      cursorColor: ColorsRes.accentColor,
      style: TextStyle(color: Colors.grey[700]),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Colors.grey[600],
            fontFamily: "WorkSansLight",
            fontSize: 14.0),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(maxLines > 1 ? 10.0 : 90.0)),
            borderSide: BorderSide(color: Colors.white, width: 0.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(maxLines > 1 ? 10.0 : 90.0)),
            borderSide: BorderSide(color: Colors.white, width: 0.5)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(maxLines > 1 ? 10.0 : 90.0)),
            borderSide: BorderSide(color: ColorsRes.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(maxLines > 1 ? 10.0 : 90.0)),
            borderSide: BorderSide(color: Colors.deepOrange, width: 1)),
        prefixIcon: iconData != null
            ? new Icon(
                iconData,
                color: Colors.grey[600],
              )
            : null,
        errorStyle: TextStyle(
          color: Colors.deepOrange,
        ),
        contentPadding: new EdgeInsets.symmetric(
            vertical: 15.0, horizontal: iconData != null ? 10.0 : 20.0),
        hintText: hintText,
      ),
      keyboardType: textInputType,
      validator: (value) {
        return !isOptional
            ? isError ? labelError : validator(value, labelError)
            : null;
      },
      inputFormatters: textInputFormatter != null ? textInputFormatter : [],
      onChanged: onChanged,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
