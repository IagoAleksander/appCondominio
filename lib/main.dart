import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: ColorsRes.primaryColorLight,
    systemNavigationBarIconBrightness: Brightness.light,// navigation bar color
//    statusBarColor: Colors.pink, // status bar color
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: ColorsRes.primaryColorLight
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: ColorsRes.primaryColor,
      onGenerateRoute: Router.generateRoute,
      initialRoute: Constants.homeRoute,
    );
  }
}
