import 'package:app_condominio/admin/visitorsCentre/visitorsCentreAdminScreen.dart';
import 'package:app_condominio/common/ui/screens/home/homeScreenSelector.dart';
import 'package:app_condominio/common/ui/screens/login/loginScreen.dart';
import 'package:app_condominio/common/ui/screens/register/registerScreen.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/ui/screens/registerVisitor/registerVisitorScreen.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/visitorsCentreScreen.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Constants.loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Constants.registerRoute:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case Constants.homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreenSelector());
      case Constants.visitorsCentreRoute:
        var visitor = settings.arguments as Visitor;
        return MaterialPageRoute(builder: (_) => VisitorsCentreScreen(visitor));
      case Constants.registerVisitorRoute:
        var visitor = settings.arguments as Visitor;
        return MaterialPageRoute(builder: (_) => RegisterVisitorScreen(visitor));
      case Constants.visitorsCentreAdminRoute:
        return MaterialPageRoute(builder: (_) => VisitorsCentreAdminScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}