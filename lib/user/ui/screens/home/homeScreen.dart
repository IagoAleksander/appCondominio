import 'dart:async';

import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/option_home_item.dart';
import 'package:app_condominio/models/address.dart';
import 'package:app_condominio/models/contact_info.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: Stack(
        children: <Widget>[
          WaveWidget(
            config: CustomConfig(
              durations: [35000, 19440, 10800, 6000],
              heightPercentages: [0.79, 0.82, 0.84, 0.87],
              blur: MaskFilter.blur(BlurStyle.outer, 10),
              colors: [
                ColorsRes.primaryColorLight,
                ColorsRes.primaryColorLight,
                ColorsRes.primaryColorLight,
                ColorsRes.primaryColorLight,
              ],
            ),
            waveAmplitude: 0,
            backgroundColor: Colors.transparent,
            size: Size(
              double.infinity,
              double.infinity,
            ),
          ),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top: 100.0, bottom: 10.0),
                    child: Image(image: AssetImage('assets/logo.png'))),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OptionHomeItem(
                          labelText: "Centro de Visitantes",
                          iconData: Icons.people,
                          onTapFunction: () {
                            Navigator.pushNamed(
                                context, Constants.visitorsCentreRoute);
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        OptionHomeItem(
                          labelText: "Enviar\nLocalização",
                          iconData: Icons.location_on,
                          onTapFunction: () {
                            shareLocation(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OptionHomeItem(
                          labelText: "Salão de Festas",
                          iconData: Icons.music_note,
                          onTapFunction: () {
                            Navigator.pushNamed(
                                context, Constants.eventsCentreCalendarRoute);
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        OptionHomeItem(
                          labelText: "Contatar\nSíndico",
                          iconData: Icons.contact_phone,
                          onTapFunction: () {
                            showContactOptionsDialog(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  shareLocation(BuildContext context) async {
    Dialogs.showLoadingDialog(
      context,
      "Obtendo endereço",
    );

    DocumentReference documentReference =
        Firestore.instance.collection("parameters").document("address");

    await documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        LocationAddress address = LocationAddress.fromJson(snapshot.data);
        Share.share('Localização do condomínio:\n\n'
            '${address.addressLine}\n'
            '${address.subLocality}\n'
            '${address.city}\n'
            '${address.district}\n\n'
            'http://maps.google.com/maps?q=loc:${address.latitude},${address.longitude}');
        Timer(Duration(milliseconds: 1500), () => Navigator.pop(context));
      } else {
        Navigator.pop(context);
        Dialogs.showAlertDialog(
          context,
          "Erro ao obter endereço",
        );
      }
    }).catchError((e) {
      Navigator.pop(context);
      Dialogs.showAlertDialog(
        context,
        "Erro ao obter endereço",
      );
    });
  }

  showContactOptionsDialog(BuildContext context) async {
    Dialogs.showLoadingDialog(
      context,
      "Obtendo informações de contato",
    );

    DocumentReference documentReference =
        Firestore.instance.collection("parameters").document("contactInfo");

    await documentReference.get().then((snapshot) {
      if (snapshot.exists) {
        ContactInfo info = ContactInfo.fromJson(snapshot.data);
        Navigator.pop(context);
        showOptionsDialog(context, "Como deseja contatar o síndico?", info);
      } else {
        Navigator.pop(context);
        Dialogs.showAlertDialog(
          context,
          "Erro ao obter informações de contato",
        );
      }
    }).catchError((e) {
      Navigator.pop(context);
      Dialogs.showAlertDialog(
        context,
        "Erro ao obter informações de contato",
      );
    });
  }

  static showOptionsDialog(
      BuildContext context, String label, ContactInfo info) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 24,
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 130,
                    color: ColorsRes.accentColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.phone, color: Colors.white, size: 20.0),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            "Fazer ligação",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          info.phoneNumber != null &&
                                  info.phoneNumber.isNotEmpty
                              ? launch("tel:${info.phoneNumber}")
                              : Dialogs.showToast(context,
                                  "Telefone não configurado pelo síndico");
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Stack(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 130,
                    color: Colors.redAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.email, color: Colors.white, size: 20.0),
                        SizedBox(
                          width: 6,
                        ),
                        Text(
                          "Enviar email",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          info.email != null &&
                                  EmailValidator.validate(info.email)
                              ? launch("mailto:${info.email}")
                              : Dialogs.showToast(context,
                                  "Email não configurado pelo síndico");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
