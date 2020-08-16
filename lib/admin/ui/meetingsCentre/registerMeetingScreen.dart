import 'dart:async';

import 'package:app_condominio/admin/bloc/RegisterEventBloc.dart';
import 'package:app_condominio/admin/bloc/RegisterMeetingBloc.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/date_picker_custom.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/meeting.dart';
import 'package:app_condominio/models/time_picker_custom.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';

class RegisterMeetingScreen extends StatefulWidget {
  Meeting meeting;

  RegisterMeetingScreen(this.meeting);

  @override
  _RegisterMeetingScreenState createState() => _RegisterMeetingScreenState();
}

class _RegisterMeetingScreenState extends State<RegisterMeetingScreen> {
  RegisterMeetingBloc registerMeetingBloc;
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool _timeClicked = false;

  var _titleFieldController;
  var _subtitleFieldController;
  var _videoIDFieldController;

  @override
  void initState() {
    registerMeetingBloc = RegisterMeetingBloc(widget.meeting);

    _titleFieldController = TextEditingController(
        text: widget.meeting != null ? widget.meeting.title : "");
    _subtitleFieldController = TextEditingController(
        text: widget.meeting != null ? widget.meeting.description : "");
    _videoIDFieldController = TextEditingController(
        text: widget.meeting != null ? widget.meeting.videoID : "");

    if (widget.meeting == null) widget.meeting = Meeting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainGlobalKey,
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          widget.meeting.id == null
              ? "Cadastro de Reunião"
              : "Edição de Reunião",
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
                  padding: const EdgeInsets.all(12.0),
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
                                        'Adicione as informações da reunião\na ser cadastrada',
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
                                            registerMeetingBloc.titleFocus,
                                        nextFocusNode: registerMeetingBloc
                                            .descriptionFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            registerMeetingBloc.changeTitle,
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        maxLines: 8,
                                        minLines: 3,
                                        textInputType: TextInputType.multiline,
                                        textInputAction: TextInputAction.next,
                                        controller: _subtitleFieldController,
                                        labelText: "Descrição",
                                        focusNode: registerMeetingBloc
                                            .descriptionFocus,
                                        nextFocusNode:
                                            registerMeetingBloc.videoIDFocus,
                                        onChanged: registerMeetingBloc
                                            .changeDescription,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _videoIDFieldController,
                                        labelText: "Identificador do vídeo",
                                        focusNode:
                                            registerMeetingBloc.videoIDFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            registerMeetingBloc.changeVideoID,
                                        isOptional: true,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 160,
                                          child: DatePickerCustom(
                                            labelText: "Data",
                                            darkMode: false,
                                            selectDate: (DateTime value) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              setState(
                                                () => registerMeetingBloc
                                                    .changeMeetingDate(
                                                  value.millisecondsSinceEpoch,
                                                ),
                                              );
                                            },
                                            selectedDate: registerMeetingBloc
                                                        .meetingDateSubject
                                                        .value ==
                                                    null
                                                ? null
                                                : DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        registerMeetingBloc
                                                            .meetingDateSubject
                                                            .value),
                                            isError: _autoValidate &&
                                                registerMeetingBloc
                                                        .meetingDateSubject
                                                        .value ==
                                                    null,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        registerMeetingBloc
                                                    .meetingDateSubject.value !=
                                                null
                                            ? Container(
                                                width: 160,
                                                child: TimePickerCustom(
                                                  labelText: "Hora",
                                                  selectTime:
                                                      (TimeOfDay value) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            new FocusNode());
                                                    setState(() {
                                                      _timeClicked = true;
                                                      registerMeetingBloc.changeMeetingDate(DateUtils
                                                              .getDayFirstMinute(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                      registerMeetingBloc
                                                                          .meetingDateSubject
                                                                          .value))
                                                          .add(Duration(
                                                              hours: value.hour,
                                                              minutes:
                                                                  value.minute))
                                                          .millisecondsSinceEpoch);
                                                    });
                                                  },
                                                  selectedTime:
                                                      widget.meeting.id !=
                                                                  null ||
                                                              _timeClicked
                                                          ? TimeOfDay(
                                                              hour: DateTime.fromMillisecondsSinceEpoch(
                                                                      registerMeetingBloc
                                                                          .meetingDateSubject
                                                                          .value)
                                                                  .hour,
                                                              minute: DateTime.fromMillisecondsSinceEpoch(
                                                                      registerMeetingBloc
                                                                          .meetingDateSubject
                                                                          .value)
                                                                  .minute,
                                                            )
                                                          : null,
                                                  isError: _autoValidate &&
                                                      widget.meeting.id ==
                                                          null &&
                                                      _timeClicked == false,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    _autoValidate &&
                                            (widget.meeting.id == null &&
                                                _timeClicked == false)
                                        ? registerMeetingBloc
                                                    .meetingDateSubject.value ==
                                                null
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Text(
                                                  'Preencha corretamente a data',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Colors.deepOrange,
                                                      fontSize: 12),
                                                ),
                                              )
                                            : Text(
                                                'Preencha corretamente o horário',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    color: Colors.deepOrange,
                                                    fontSize: 12),
                                              )
                                        : Container(),
                                    SizedBox(
                                      height: 18,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 18.0, right: 18),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  StreamBuilder(
                                                      stream:
                                                          registerMeetingBloc
                                                              .streamIsActive,
                                                      builder:
                                                          (context, snapshot) {
                                                        return SizedBox(
                                                          height: 24,
                                                          width: 24,
                                                          child: Checkbox(
                                                            value: registerMeetingBloc
                                                                .isActiveSubject
                                                                .value,
                                                            onChanged:
                                                                registerMeetingBloc
                                                                    .changeIsActive,
                                                          ),
                                                        );
                                                      }),
                                                  GestureDetector(
                                                    onTap: () {
                                                      registerMeetingBloc
                                                          .changeIsActive(
                                                              !registerMeetingBloc
                                                                  .isActiveSubject
                                                                  .value);
                                                    },
                                                    child: Text(
                                                      " Reunião ativa",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 18.0, bottom: 24.0),
                                          child: ProgressButton(
                                            color: ColorsRes.primaryColor,
                                            borderRadius: 90.0,
                                            defaultWidget: Text(
                                              widget.meeting.id == null
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
                                            // ignore: missing_return
                                            onPressed: () async {
                                              if (_formKey.currentState
                                                      .validate() &&
                                                  (widget.meeting.id != null ||
                                                      _timeClicked)) {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                String result;
                                                if (widget.meeting.id == null) {
                                                  Dialogs.showLoadingDialog(
                                                    context,
                                                    'Registrando reunião...',
                                                  );
                                                  result =
                                                      await registerMeetingBloc
                                                          .saveMeeting();
                                                } else {
                                                  Dialogs.showLoadingDialog(
                                                    context,
                                                    'Atualizando reunião...',
                                                  );
                                                  result =
                                                      await registerMeetingBloc
                                                          .updateMeeting();
                                                }

                                                switch (result) {
                                                  case "SUCCESS":
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      Dialogs.showToast(
                                                          context,
                                                          widget.meeting.id ==
                                                                  null
                                                              ? 'Reunião registrada com sucesso'
                                                              : 'Reunião atualizada com sucesso');

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
                                                          'Erro no registro de reunião');
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
