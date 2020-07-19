import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/option_home_item.dart';
import 'package:app_condominio/models/contact_info.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomeScreenAdmin extends StatelessWidget {
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
                          labelText: "Centro de Moradores",
                          iconData: Icons.people,
                          onTapFunction: () {
                            Navigator.pushNamed(
                                context, Constants.residentsCentreRoute);
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        OptionHomeItem(
                          labelText: "Centro de Visitantes",
                          iconData: Icons.people,
                          onTapFunction: () {
                            Navigator.pushNamed(
                                context, Constants.visitorsCentreAdminRoute);
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
                          labelText: "Definir Localização",
                          iconData: Icons.location_on,
                          onTapFunction: () {
                            Navigator.pushNamed(
                                context, Constants.chooseLocationRoute);
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        OptionHomeItem(
                          labelText: "Configurar Contato",
                          iconData: Icons.contact_phone,
                          onTapFunction: () {
                            getContact(context);
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

  getContact(BuildContext context) async {
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
        Navigator.pushNamed(context, Constants.setContactInfoRoute,
            arguments: info);
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
}
