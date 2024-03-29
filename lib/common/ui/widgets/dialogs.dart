import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, String label) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  backgroundColor: ColorsRes.primaryColorLight,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        SizedBox(
                          height: 8,
                        ),
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          label,
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }

  static showAlertDialog(BuildContext context, String label,
      {Function onPressed}) {
    // set up the buttons
    Widget continueButton = FlatButton(
      child: Text(
        "Ok",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: onPressed != null
          ? onPressed
          : () {
              Navigator.pop(context);
            },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showToast(BuildContext context, String message) {
    Toast.show(
      message,
      context,
      duration: 4,
      gravity: Toast.BOTTOM,
      backgroundColor: Colors.grey[800],
    );
  }
}
