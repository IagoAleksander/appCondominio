import 'dart:async';

import 'package:app_condominio/admin/bloc/RegisterReportBloc.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class CreateEventReportScreen extends StatefulWidget {
  final String eventID;
  final EventReport report;

  CreateEventReportScreen(this.eventID, this.report);

  @override
  _CreateEventReportScreenState createState() =>
      _CreateEventReportScreenState();
}

class _CreateEventReportScreenState extends State<CreateEventReportScreen> {
  RegisterReportBloc registerReportBloc;
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  var _titleFieldController;
  var _subtitleFieldController;

  @override
  void initState() {
    registerReportBloc = RegisterReportBloc(widget.report);

    _titleFieldController = TextEditingController(
        text: widget.report != null ? widget.report.title : "");
    _subtitleFieldController = TextEditingController(
        text: widget.report != null ? widget.report.description : "");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainGlobalKey,
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          widget.report == null
              ? "Criação de Relatório"
              : "Edição de Relatório",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  color: ColorsRes.primaryColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Form(
                              key: _formKey,
                              autovalidate: _autoValidate,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        'Adicione as informações do relatório\ndo evento',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, bottom: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _titleFieldController,
                                        labelText: "Título",
                                        focusNode:
                                            registerReportBloc.titleFocus,
                                        nextFocusNode:
                                            registerReportBloc.descriptionFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            registerReportBloc.changeTitle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        maxLines: 8,
                                        minLines: 3,
                                        textInputType: TextInputType.multiline,
                                        textInputAction: TextInputAction.done,
                                        controller: _subtitleFieldController,
                                        labelText: "Descrição",
                                        focusNode:
                                            registerReportBloc.descriptionFocus,
                                        onChanged: registerReportBloc
                                            .changeDescription,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 6.0, bottom: 24.0),
                                          child: ProgressButton(
                                            color: ColorsRes.primaryColor,
                                            borderRadius: 90.0,
                                            defaultWidget: Text(
                                              widget.report == null
                                                  ? "REGISTRAR"
                                                  : "ATUALIZAR",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            progressWidget:
                                                const CircularProgressIndicator(
                                              strokeWidth: 4,
                                              backgroundColor:
                                                  ColorsRes.accentColor,
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Colors.white),
                                            ),
                                            width: 160,
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                String result;
                                                if (widget.report == null) {
                                                  Dialogs.showLoadingDialog(
                                                    context,
                                                    'Registrando relatório...',
                                                  );
                                                  result =
                                                      await registerReportBloc
                                                          .saveReport(
                                                              widget.eventID);
                                                } else {
                                                  Dialogs.showLoadingDialog(
                                                    context,
                                                    'Atualizando relatório...',
                                                  );
                                                  result =
                                                      await registerReportBloc
                                                          .updateEvent();
                                                }

                                                switch (result) {
                                                  case "SUCCESS":
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      Dialogs.showToast(
                                                          context,
                                                          widget.report == null
                                                              ? 'Relatório registrado com sucesso'
                                                              : 'Relatório atualizado com sucesso');

                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    });
                                                    break;
                                                  case "ERROR_NOTHING_CHANGE":
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      Dialogs.showToast(context,
                                                          'Nada a atualizar');
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    });
                                                    break;
                                                  default:
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      Dialogs.showToast(context,
                                                          'Erro no registro do relatório');
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    });
                                                    break;
                                                }
                                              } else {
                                                setState(() {
                                                  _autoValidate = true;
                                                });
                                              }
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
