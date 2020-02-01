import 'package:app_condominio/user/ui/screens/home/widgets/option_home_item.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
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
                          labelText: "Enviar Localização",
                          iconData: Icons.location_on,
                          onTapFunction: () {},
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
                          labelText: "Eventos",
                          iconData: Icons.event,
                          onTapFunction: () {},
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        OptionHomeItem(
                          labelText: "Salão de Festas",
                          iconData: Icons.music_note,
                          onTapFunction: () {},
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
}
