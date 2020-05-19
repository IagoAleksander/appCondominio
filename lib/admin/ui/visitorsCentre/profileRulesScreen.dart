import 'dart:async';

import 'package:app_condominio/admin/bloc/ProfileRulesBloc.dart';
import 'package:app_condominio/admin/ui/visitorsCentre/widgets/profile_rule_card.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/profile_rule.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileRulesScreen extends StatefulWidget {
  @override
  _ProfileRulesScreenState createState() => _ProfileRulesScreenState();
}

class _ProfileRulesScreenState extends State<ProfileRulesScreen> {
  final ProfileRulesBloc profileRulesBloc = ProfileRulesBloc();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: ColorsRes.primaryColorLight,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("Perfis de Acesso",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                ),
              ),
            ),
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ],
        body: Center(
          child: Column(
            children: <Widget>[
              new Flexible(
                fit: FlexFit.loose,
                child: StreamBuilder(
                    stream: Firestore.instance
                        .collection('profileRules')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingIndicator();
                      }
                      if (!snapshot.hasData ||
                          snapshot.data.documents.length == 0) {
                        return Container(
                            child: Center(
                                child: Text(
                          "Não há regras de\nperfis cadastradas",
                          style: TextStyle(color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        )));
                      }

                      return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          reverse: false,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, int index) {
                            ProfileRule rule = ProfileRule.fromJson(
                                snapshot.data.documents[index].data);
                            return ProfileRuleCard(
                              profileTitle: rule.title,
                              value: rule.value,
                              unit: rule.unit,
                              onEditFunction: () async {
                                rule.id =
                                    snapshot.data.documents[index].documentID;
                                String result = await showCreateRuleDialog(
                                    context, profileRulesBloc, rule);

                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(result == "SUCCESS"
                                        ? 'Regra de perfil atualizada com sucesso'
                                        : result == "ERROR_NOTHING_CHANGE"
                                            ? 'Nada a atualizar'
                                            : 'Erro na atualização da regra')));
                              },
                              onDeleteFunction: () {
                                rule.id =
                                    snapshot.data.documents[index].documentID;
                                showDeleteRuleDialog(context, rule);
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Regra de perfil removida com sucesso')));
                              },
                            );
                          });
                    }),
              ),
              Container(
                color: ColorsRes.primaryColorLight,
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Builder(
                  builder: (context) => StandardButton(
                    label: "Criar nova regra",
                    backgroundColor: ColorsRes.primaryColorLight,
                    onTapFunction: () async {
                      String result = await showCreateRuleDialog(
                          context, profileRulesBloc, null);
                      Scaffold.of(context).hideCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(result == "SUCCESS"
                              ? 'Regra de perfil criada com sucesso'
                              : 'Erro na criação da regra')));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String> showCreateRuleDialog(BuildContext context,
      ProfileRulesBloc profileRulesBloc, ProfileRule rule) async {
    String result;

    profileRulesBloc.setRuleData(rule);

    TextEditingController _titleFieldController = TextEditingController(
        text: profileRulesBloc.titleSubject.value != null
            ? profileRulesBloc.titleSubject.value
            : null);

    TextEditingController _valueFieldController = TextEditingController(
        text: profileRulesBloc.valueSubject.value != null
            ? profileRulesBloc.valueSubject.value
            : null);

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        rule == null ? "Criar" : "Atualizar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        Dialogs.showLoadingDialog(
          context,
          rule == null ? "Criando regra" : "Atualizando regra",
        );
        rule == null
            ? result = await profileRulesBloc.saveRule()
            : result = await profileRulesBloc.updateRule();

        Timer(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rule == null
                ? "Escolha um título para a nova regra"
                : "Escolha um novo título para a regra",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 12,
          ),
          TextFormFieldCustom(
            controller: _titleFieldController,
            hintText: "Título",
            onChanged: profileRulesBloc.changeTitle,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            "E o período de acesso fornecido",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 120,
                child: TextFormFieldCustom(
                  controller: _valueFieldController,
                  hintText: "Número de",
                  onChanged: profileRulesBloc.changeValue,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(90.0),
                    )),
                padding: EdgeInsets.symmetric(horizontal: 26.0),
                child: StreamBuilder<String>(
                    stream: profileRulesBloc.unitSubject,
                    builder: (context, snapshot) {
                      return new DropdownButton<String>(
                        value: snapshot.data,
                        items: <String>['horas', 'dias'].map((String value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontFamily: "WorkSansLight",
                          fontSize: 14.0,
                        ),
                        onChanged: profileRulesBloc.changeUnit,
                      );
                    }),
              )
            ],
          ),
        ],
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

    return Future.value(result);
  }

  static showDeleteRuleDialog(BuildContext context, ProfileRule rule) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Remover",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Dialogs.showLoadingDialog(
          context,
          "Removendo perfil",
        );

        Firestore.instance
            .collection('profileRules')
            .document(rule.id)
            .delete();

        Timer(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja remover o perfil ${rule.title} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
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
