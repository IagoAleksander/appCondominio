import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ToastCustom extends StatelessWidget {
  final BuildContext context;
  final String message;

  ToastCustom(this.context, this.message,);

  @override
  Widget build(BuildContext context) {
    Toast.show(
      "Email não configurado pelo síndico",
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
      backgroundColor: Colors.grey[900],
    );
  }
}
