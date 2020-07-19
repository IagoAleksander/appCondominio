import 'dart:async';

import 'package:app_condominio/admin/bloc/RegisterEventBloc.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom_big.dart';
import 'package:app_condominio/models/date_picker_custom.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/time_picker_custom.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker

class RegisterEventScreen extends StatefulWidget {
  FeedEvent event;

  RegisterEventScreen(this.event);

  @override
  _RegisterEventScreenState createState() => _RegisterEventScreenState();
}

class _RegisterEventScreenState extends State<RegisterEventScreen> {
  RegisterEventBloc registerEventBloc;
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  bool _hasImage = false;
  bool _timeClicked = false;

  var _titleFieldController;
  var _subtitleFieldController;

  @override
  void initState() {
    registerEventBloc = RegisterEventBloc(widget.event);

    _titleFieldController = TextEditingController(
        text: widget.event != null ? widget.event.title : "");
    _subtitleFieldController = TextEditingController(
        text: widget.event != null ? widget.event.description : "");

    if (widget.event == null) widget.event = FeedEvent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event != null && widget.event.imageUrl != null) {
      _hasImage = true;
    }
    return Scaffold(
        key: _mainGlobalKey,
        backgroundColor: ColorsRes.primaryColor,
        appBar: AppBar(
          title: Text(
            widget.event.id == null ? "Cadastro de Evento" : "Edição de Evento",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          ),
          backgroundColor: ColorsRes.primaryColorLight,
        ),
        body: LayoutBuilder(builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  color: ColorsRes.primaryColor,
                  padding: const EdgeInsets.all(24.0),
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
                                        'Adicione as informações do evento\na ser cadastrado',
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
                                        focusNode: registerEventBloc.titleFocus,
                                        nextFocusNode:
                                            registerEventBloc.descriptionFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            registerEventBloc.changeTitle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustomBig(
                                        controller: _subtitleFieldController,
                                        labelText: "Descrição",
                                        focusNode:
                                            registerEventBloc.descriptionFocus,
                                        textInputAction: TextInputAction.done,
                                        onChanged:
                                            registerEventBloc.changeDescription,
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
                                            selectDate: (DateTime value) =>
                                                setState(
                                              () => registerEventBloc
                                                  .changeEventDate(
                                                value.millisecondsSinceEpoch,
                                              ),
                                            ),
                                            selectedDate: registerEventBloc
                                                        .eventDateSubject
                                                        .value ==
                                                    null
                                                ? null
                                                : DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        registerEventBloc
                                                            .eventDateSubject
                                                            .value),
                                            isError: _autoValidate &&
                                                registerEventBloc
                                                        .eventDateSubject
                                                        .value ==
                                                    null,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        registerEventBloc
                                                    .eventDateSubject.value !=
                                                null
                                            ? Container(
                                                width: 160,
                                                child: TimePickerCustom(
                                                  labelText: "Hora",
                                                  selectTime:
                                                      (TimeOfDay value) =>
                                                          setState(() {
                                                    _timeClicked = true;
                                                    registerEventBloc.changeEventDate(
                                                        DateUtils.getDayFirstMinute(
                                                                DateTime.fromMillisecondsSinceEpoch(
                                                                    registerEventBloc
                                                                        .eventDateSubject
                                                                        .value))
                                                            .add(Duration(
                                                                hours:
                                                                    value.hour,
                                                                minutes: value
                                                                    .minute))
                                                            .millisecondsSinceEpoch);
                                                  }),
                                                  selectedTime:
                                                      widget.event.id != null ||
                                                              _timeClicked
                                                          ? TimeOfDay(
                                                              hour: DateTime.fromMillisecondsSinceEpoch(
                                                                      registerEventBloc
                                                                          .eventDateSubject
                                                                          .value)
                                                                  .hour,
                                                              minute: DateTime.fromMillisecondsSinceEpoch(
                                                                      registerEventBloc
                                                                          .eventDateSubject
                                                                          .value)
                                                                  .minute,
                                                            )
                                                          : null,
                                                  isError: _autoValidate &&
                                                      widget.event.id == null &&
                                                      _timeClicked == false,
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    _autoValidate &&
                                            (widget.event.id == null &&
                                                _timeClicked == false)
                                        ? registerEventBloc
                                                    .eventDateSubject.value ==
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
                                        Text(
                                          _hasImage
                                              ? 'Imagem do evento:'
                                              : 'Adicione uma imagem para o evento:',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 12,
                                        ),
                                        !_hasImage
                                            ? ProgressButton(
                                                color: ColorsRes.primaryColor,
                                                borderRadius: 90.0,
                                                defaultWidget: Text(
                                                  "BUSCAR IMAGEM",
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
                                                onPressed: () => chooseFile)
                                            : Container(),
                                        registerEventBloc
                                                    .imageFileSubject.value !=
                                                null
                                            ? _hasImage
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Image.file(
                                                      registerEventBloc
                                                          .imageFileSubject
                                                          .value,
                                                      height: 250,
                                                    ),
                                                  )
                                                : Container()
                                            : widget.event.imageUrl != null
                                                ? Image.network(
                                                    widget.event.imageUrl,
                                                    height: 150,
                                                  )
                                                : Container(),
                                        _hasImage
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20.0),
                                                    child: ProgressButton(
                                                        color: Colors.redAccent,
                                                        borderRadius: 90.0,
                                                        defaultWidget: Text(
                                                          "REMOVER FOTO",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        progressWidget:
                                                            const CircularProgressIndicator(
                                                          strokeWidth: 4,
                                                          backgroundColor:
                                                              ColorsRes
                                                                  .accentColor,
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                        width: 146,
                                                        // ignore: missing_return
                                                        onPressed: () =>
                                                            removeFile),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 24.0),
                                                    child: ProgressButton(
                                                        color: ColorsRes
                                                            .primaryColor,
                                                        borderRadius: 90.0,
                                                        defaultWidget: Text(
                                                          "TROCAR FOTO",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        progressWidget:
                                                            const CircularProgressIndicator(
                                                          strokeWidth: 4,
                                                          backgroundColor:
                                                              ColorsRes
                                                                  .accentColor,
                                                          valueColor:
                                                              const AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Colors.white),
                                                        ),
                                                        width: 146,
                                                        // ignore: missing_return
                                                        onPressed: () =>
                                                            chooseFile),
                                                  ),
                                                ],
                                              )
                                            : Container(),
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
                                                      stream: registerEventBloc
                                                          .streamIsActive,
                                                      builder:
                                                          (context, snapshot) {
                                                        return SizedBox(
                                                          height: 24,
                                                          width: 24,
                                                          child: Checkbox(
                                                            value: registerEventBloc
                                                                .isActiveSubject
                                                                .value,
                                                            onChanged:
                                                                registerEventBloc
                                                                    .changeIsActive,
                                                          ),
                                                        );
                                                      }),
                                                  GestureDetector(
                                                    onTap: () {
                                                      registerEventBloc
                                                          .changeIsActive(
                                                              !registerEventBloc
                                                                  .isActiveSubject
                                                                  .value);
                                                    },
                                                    child: Text(
                                                      " Evento ativo",
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  StreamBuilder(
                                                      stream: registerEventBloc
                                                          .streamSendNotification,
                                                      builder:
                                                          (context, snapshot) {
                                                        return SizedBox(
                                                          height: 24,
                                                          width: 24,
                                                          child: Checkbox(
                                                            value: registerEventBloc
                                                                .sendNotificationSubject
                                                                .value,
                                                            onChanged:
                                                                registerEventBloc
                                                                    .changeSendNotification,
                                                          ),
                                                        );
                                                      }),
                                                  GestureDetector(
                                                    onTap: () {
                                                      registerEventBloc
                                                          .changeSendNotification(
                                                              !registerEventBloc
                                                                  .sendNotificationSubject
                                                                  .value);
                                                    },
                                                    child: Text(
                                                      " Enviar notificação",
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
                                              widget.event.id == null
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
                                                  (widget.event.id != null ||
                                                      _timeClicked)) {
                                                String result;
                                                if (widget.event.id == null) {
                                                  (_mainGlobalKey.currentState
                                                          as ScaffoldState)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Registrando evento')));

                                                  result =
                                                      await registerEventBloc
                                                          .saveEvent();
                                                } else {
                                                  (_mainGlobalKey.currentState
                                                          as ScaffoldState)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Atualizando evento')));

                                                  result =
                                                      await registerEventBloc
                                                          .updateEvent();
                                                }

                                                switch (result) {
                                                  case "SUCCESS":
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      (_mainGlobalKey
                                                                  .currentState
                                                              as ScaffoldState)
                                                          .hideCurrentSnackBar();
                                                      Dialogs.showToast(
                                                          context,
                                                          widget.event.id ==
                                                                  null
                                                              ? 'Evento registrado com sucesso'
                                                              : 'Evento atualizado com sucesso');

                                                      Navigator.pop(context);
                                                    });
                                                    break;
                                                  case "ERROR_NOTHING_CHANGE":
                                                    (_mainGlobalKey.currentState
                                                            as ScaffoldState)
                                                        .hideCurrentSnackBar();
                                                    (_mainGlobalKey.currentState
                                                            as ScaffoldState)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Nada a atualizar')));
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
                                                      Navigator.pop(context);
                                                    });
                                                    break;
                                                  default:
                                                    (_mainGlobalKey.currentState
                                                            as ScaffoldState)
                                                        .hideCurrentSnackBar();
                                                    (_mainGlobalKey.currentState
                                                            as ScaffoldState)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                'Erro no registro de evento')));
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 1500),
                                                        () {
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
        }));
  }

  Future chooseFile() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      if (image != null) {
        setState(() {
          _hasImage = true;
          registerEventBloc.changeImageFile(image);
        });
      }
    });
  }

  Future removeFile() async {
    setState(() {
      _hasImage = false;
      registerEventBloc.changeImageFile(null);
    });
  }
}
