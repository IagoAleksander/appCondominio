import 'dart:async';

import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/bloc/RegisterVisitorBloc.dart';
import 'package:app_condominio/user/mobx/answerSurveyController.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:app_condominio/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:mobx/mobx.dart';

class AnswerSurveyScreen extends StatefulWidget {
  final String meetingID;
  final List<MeetingSurveyQuestion> questions;

  AnswerSurveyScreen(this.meetingID, this.questions);

  @override
  _AnswerSurveyScreenState createState() => _AnswerSurveyScreenState();
}

class _AnswerSurveyScreenState extends State<AnswerSurveyScreen> {
  AnswerSurveyController controller = AnswerSurveyController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    controller.initValues(widget.meetingID, widget.questions);
    autorun(
      (_) {
        switch (controller.state) {
          case EnumState.IDLE:
            // TODO: Handle this case.
            break;
          case EnumState.SUCCESS:
            Navigator.of(context).pop();
            Dialogs.showToast(_scaffoldKey.currentContext,
                "Questionário respondido com sucesso");
            controller.changeState(EnumState.IDLE);
            Navigator.of(context).pop();
            break;
          case EnumState.ERROR_GENERIC:
            Dialogs.showToast(
                _scaffoldKey.currentContext, "Erro ao responder questionário");
            controller.changeState(EnumState.IDLE);
            Navigator.of(context).pop();
            break;
          case EnumState.ERROR_ALREADY_ANSWERED:
            Dialogs.showToast(_scaffoldKey.currentContext,
                "Você já respondeu o questionário anteriormente");
            controller.changeState(EnumState.IDLE);
            Navigator.of(context).pop();
            break;
          case EnumState.LOADING:
            Dialogs.showLoadingDialog(
              _scaffoldKey.currentContext,
              'Enviando resposta...',
            );
            break;
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          "Questionário",
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
            child: Container(
              color: ColorsRes.primaryColor,
              padding: const EdgeInsets.all(24.0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Selecione a opção desejada para cada item e clique em Enviar para concluir o questionário",
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 14.0),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      itemCount: widget.questions.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        return questionWidget(widget.questions[index], index);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                      child: ProgressButton(
                        color: ColorsRes.primaryColor,
                        borderRadius: 90.0,
                        defaultWidget: Text(
                          "ENVIAR",
                          style: TextStyle(color: Colors.white),
                        ),
                        progressWidget: const CircularProgressIndicator(
                          strokeWidth: 4,
                          backgroundColor: ColorsRes.accentColor,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        width: 160,
                        // ignore: missing_return
                        onPressed: () async {
                          controller.sendAnswer();
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget questionWidget(MeetingSurveyQuestion question, int groupValue) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            question.title,
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),
          Observer(
            builder: (_) {
              return controller.radioValuesObservable[groupValue] == -1 &&
                      controller.needToValidate
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Por favor, selecione uma das opções abaixo",
                          style: new TextStyle(
                              fontSize: 12.0, color: Colors.deepOrange),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    )
                  : Container();
            },
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: question.choices.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return customRadioWidget(
                index,
                groupValue,
                question.choices[index],
              );
            },
          )
        ],
      ),
    );
  }

  Widget customRadioWidget(int radioValue, int groupValue, String optionText) {
    return Observer(
      builder: (_) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: radioValue,
              groupValue: controller.radioValuesObservable[groupValue],
              onChanged: (value) {
                controller.updateRadioValue(groupValue, radioValue);
              },
            ),
            Flexible(
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    optionText,
                    style: new TextStyle(fontSize: 14.0),
                  ),
                ),
                onTap: () {
                  controller.updateRadioValue(groupValue, radioValue);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
