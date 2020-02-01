import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
//  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: ColorsRes.primaryColorLight,
      systemNavigationBarIconBrightness: Brightness.light,
      // navigation bar color
//    statusBarColor: Colors.pink, // status bar color
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: ColorsRes.primaryColorLight));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: ColorsRes.primaryColor,
      onGenerateRoute: Router.generateRoute,
      initialRoute: Constants.loginRoute,
      theme: ThemeData(
        // Define the default brightness and colors.
//        brightness: Brightness.dark,
        primaryColor: ColorsRes.primaryColor,
        accentColor: ColorsRes.accentColor,

        // Define the default font family.
//        fontFamily: 'Open Sans',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
//        textTheme: TextTheme(
//          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
//          title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
//          body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
//        ),
      ),
    );
  }
}
