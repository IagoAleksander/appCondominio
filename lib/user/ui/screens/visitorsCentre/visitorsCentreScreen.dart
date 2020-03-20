import 'dart:async';
import 'dart:math';

import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/bloc/VisitorsCentreBloc.dart';
import 'package:app_condominio/user/ui/screens/home/widgets/option_home_item.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/border_button.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/dialogs.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/visitor_card.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/widgets/visitor_details_dialog.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VisitorsCentreScreen extends StatefulWidget {
  final Visitor visitor;

  VisitorsCentreScreen(this.visitor);

  @override
  _VisitorsCentreScreenState createState() => _VisitorsCentreScreenState();
}

class _VisitorsCentreScreenState extends State<VisitorsCentreScreen> {
  // ignore: close_sinks
  final VisitorsCentreBloc visitorsCentreBloc = VisitorsCentreBloc();
  int currentPage = 0;
  var _searchFieldController;

  @override
  void initState() {
    _searchFieldController = TextEditingController(
        text: widget.visitor != null ? widget.visitor.name : null);

    if (widget.visitor != null) {
      visitorsCentreBloc.search(widget.visitor.name);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.person, title: "Lista de Visitantes"),
          TabData(iconData: Icons.history, title: "Acessos Liberados"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
            if(position == 0) {
              visitorsCentreBloc.search(_searchFieldController.text);
            }
            if (position == 1) {
              visitorsCentreBloc.updateHistoryList();
            }
          });
        },
        barBackgroundColor: ColorsRes.primaryColorLight,
        circleColor: ColorsRes.primaryColor,
        inactiveIconColor: Colors.white,
        textColor: Colors.white,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: ColorsRes.primaryColorLight,
                expandedHeight: 160,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Centro de Visitantes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ],
        body: currentPage == 0
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: ColorsRes.primaryColorLight,
                      padding: const EdgeInsets.all(18.0),
                      child: Container(
                        alignment: Alignment.center,
                        child: TextFormField(
                          controller: _searchFieldController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "Buscar visitante",
                            hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: "WorkSansLight",
                                fontSize: 16.0),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              color: Colors.grey[600],
                              onPressed: () {
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _searchFieldController.clear());
                                visitorsCentreBloc.search("");
                              },
                            ),
                          ),
                          onChanged: visitorsCentreBloc.changeSearch,
                        ),
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: StreamBuilder(
                        stream: visitorsCentreBloc.streamVisitor,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data.length == 0) {
                            return LayoutBuilder(
                              builder: (context, constraint) {
                                return SingleChildScrollView(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: constraint.maxHeight),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Busque o visitante desejado",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "através de seu nome (a partir de 3 dígitos)",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "ou",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        OptionHomeItem(
                                          labelText: "Cadastre novo visitante",
                                          iconData: Icons.person_add,
                                          onTapFunction: () {
                                            Navigator.pushNamed(context,
                                                Constants.registerVisitorRoute);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return ListView.builder(
                              padding: EdgeInsets.all(8.0),
                              reverse: false,
                              itemCount: snapshot.data.length,
                              itemBuilder: (_, int index) {
                                Visitor visitor = snapshot.data[index];
                                return VisitorCard(
                                  personName: visitor.name,
                                  rgNumber: visitor.rg,
                                  isLiberated: visitor.isLiberated == null
                                      ? false
                                      : visitor.isLiberated,
                                  onTapFunction: () async {
                                    String status = await showVisitorDetails(
                                        context, visitor);

                                    switch (status) {
                                      case "SUCCESS":
                                        setState(() {
                                          visitorsCentreBloc
                                              .visitors[visitor.rg] = visitor;
                                        });
                                        break;
                                      case "ERROR":
                                        break;
                                      case "CANCEL":
                                        break;
                                    }
                                  },
                                );
                              });
                        },
                      ),
                    )
                  ],
                ),
              )
            : Column(
              children: <Widget>[
                Flexible(
                    fit: FlexFit.loose,
                    child: StreamBuilder(
                      stream: visitorsCentreBloc.streamHistory,
                      builder: (context, snapshot) {

                        if (!snapshot.hasData || snapshot.data.length == 0) {
                          return LayoutBuilder(
                            builder: (context, constraint) {
                              return SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: constraint.maxHeight),
                                  child: Center(
                                    child: Text(
                                      "Não há visitantes liberados",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        return ListView.builder(
                            padding: EdgeInsets.all(8.0),
                            reverse: false,
                            itemCount: snapshot.data.length,
                            itemBuilder: (_, int index) {
                              Visitor visitor = snapshot.data[index];
                              return VisitorCard(
                                personName: visitor.name,
                                rgNumber: visitor.rg,
                                isLiberated: visitor.isLiberated == null
                                    ? false
                                    : visitor.isLiberated,
                                onTapFunction: () async {
                                  String status =
                                      await showVisitorDetails(context, visitor);

                                  switch (status) {
                                    case "SUCCESS":
                                      setState(() {
                                        visitorsCentreBloc.visitors[visitor.rg] =
                                            visitor;
                                      });
                                      break;
                                    case "ERROR":
                                      break;
                                    case "CANCEL":
                                      break;
                                  }
                                },
                              );
                            });
                      },
                    ),
                  ),
              ],
            ),
      ),
    );
  }

  Future<String> showVisitorDetails(
      BuildContext context, Visitor visitor) async {
    Dialogs.showLoadingDialog(
      context,
      "Obtendo informações",
    );

    Future<String> status;
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
    bool isResponsableUser;

    if (visitor.isLiberated != null && visitor.isLiberated) {
      QuerySnapshot snapshot = await Firestore.instance
          .collection('accessCodes')
          .where("createdTo", isEqualTo: visitor.rg)
          .getDocuments();

      if (snapshot != null && snapshot.documents.isNotEmpty) {
        visitor.accessCode = AccessCode.fromJson(snapshot.documents[0].data);
        isResponsableUser = visitor.accessCode.createdBy == currentUser.uid;
      } else {
        return Future.value("ERROR");
      }
    }

    Navigator.pop(context);

    Widget continueButton = visitor.isLiberated
        ? BorderButton(
            "Remover acesso",
            Colors.red,
            () {
              if (isResponsableUser && visitor.accessCode != null) {
                status = showRemovalAlertDialog(context, visitor);
              } else {
                showAlertDialog(context);
              }
            },
          )
        : BorderButton(
            "Liberar acesso",
            ColorsRes.accentColor,
            () async {
              status =
                  showChooseProfileDialog(context, visitor, currentUser.uid);
            },
          );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: VisitorDetailsDialog(visitor, currentUser.uid),
      actions: [
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return status;
  }

  Future<String> showChooseProfileDialog(
      BuildContext context, Visitor visitor, String currentUserId) async {
    Future<String> status;
    int _radioValue = -1;
    bool errorNoRadioSelected = false;
    ProfileType profileType;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = Future.value("CANCEL");
      },
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: ColorsRes.primaryColorLight,
            content: Theme(
              data: ThemeData(
                  brightness: Brightness.dark,
                  unselectedWidgetColor: Colors.white),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Escolha um perfil para o acesso do visitante",
                    style: TextStyle(
                      color: errorNoRadioSelected ? Colors.red : Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: 0,
                        groupValue: _radioValue,
                        onChanged: (value) {
                          setState(() {
                            profileType = ProfileType.unique;
                            _radioValue = value;
                          });
                        },
                        activeColor: ColorsRes.accentColor,
                        focusColor: ColorsRes.accentColor,
                      ),
                      Flexible(
                        child: Text(
                          'Visita Única\n12 horas de acesso',
                          style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: 1,
                        groupValue: _radioValue,
                        onChanged: (value) {
                          setState(() {
                            profileType = ProfileType.serviceProvider;
                            _radioValue = value;
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          'Prestador de Serviços\n12 horas de acesso',
                          style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Radio(
                        value: 2,
                        groupValue: _radioValue,
                        onChanged: (value) {
                          setState(() {
                            profileType = ProfileType.family;
                            _radioValue = value;
                          });
                        },
                      ),
                      Flexible(
                        child: Text(
                          'Família\n7 dias de acesso',
                          style: new TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              cancelButton,
              FlatButton(
                child: Text(
                  "Continuar",
                  style: TextStyle(color: Colors.white),
                ),
                // ignore: missing_return
                onPressed: () async {
                  if (_radioValue == -1) {
                    setState(() {
                      errorNoRadioSelected = true;
                    });
                  } else {
                    status = showReleaseAlertDialog(
                        context, visitor, currentUserId, profileType);
                  }
                },
              ),
            ],
          );
          ;
        });
      },
    );

    return status;
  }

  Future<String> showReleaseAlertDialog(BuildContext context, Visitor visitor,
      String currentUserId, ProfileType profileType) async {
    String status;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = "CANCEL";
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        Dialogs.showLoadingDialog(
          context,
          "Liberando acesso",
        );

        FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
        var rng = new Random();
        var snapShot;
        String code;

        do {
          code = rng.nextInt(1000000).toString();

          snapShot = await Firestore.instance
              .collection('accessCodes')
              .document(code)
              .get();
        } while (snapShot != null && snapShot.exists);

        AccessCode accessCode = new AccessCode();
        accessCode.accessCodeNumber = code;
        accessCode.profileType = profileType;
        accessCode.createdBy = currentUser.uid;
        accessCode.createdTo = visitor.rg;
        accessCode.isActive = true;
        accessCode.creationDateInMillis = DateTime.now().millisecondsSinceEpoch;

        await Firestore.instance
            .collection('accessCodes')
            .document(accessCode.accessCodeNumber)
            .setData(accessCode.toJson());

        visitor.isLiberated = true;

        await Firestore.instance
            .collection('visitors')
            .document(visitor.rg)
            .setData(visitor.toJson());

        status = "SUCCESS";
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja liberar o acesso de tipo ${AccessCode.profileTypeToString(profileType)} para ${visitor.name} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(status);
  }

  Future<String> showRemovalAlertDialog(
      BuildContext context, Visitor visitor) async {
    String status;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = "CANCEL";
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        Dialogs.showLoadingDialog(
          context,
          "Removendo acesso",
        );

        await Firestore.instance
            .collection('accessCodes')
            .document(visitor.accessCode.accessCodeNumber)
            .delete();

        visitor.isLiberated = false;

        await Firestore.instance
            .collection('visitors')
            .document(visitor.rg)
            .setData(visitor.toJson());

        status = "SUCCESS";

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que remover o acesso de ${visitor.name} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(status);
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget continueButton = FlatButton(
      child: Text("Ok"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você não tem permissão para remover o acesso desse visitante",
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
}
