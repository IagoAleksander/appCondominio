import 'dart:async';

import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/bloc/RegisterVisitorBloc.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:app_condominio/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:image_picker/image_picker.dart'; // For Image Picker
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';

class RegisterVisitorScreen extends StatefulWidget {
  final Visitor visitor;

  RegisterVisitorScreen(this.visitor);

  @override
  _RegisterVisitorScreenState createState() => _RegisterVisitorScreenState();
}

class _RegisterVisitorScreenState extends State<RegisterVisitorScreen> {
  RegisterVisitorBloc registerVisitorBloc;
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool docAlreadyInUse = false;

  bool _hasImage = false;
  bool _imageNotSelectedError = false;

  var _nameFieldController;
  var _rgFieldController;
  var _phoneFieldController;

  @override
  void initState() {
    registerVisitorBloc = RegisterVisitorBloc(widget.visitor);

    _nameFieldController = TextEditingController(text: widget.visitor.name);

    _rgFieldController = TextEditingController(text: widget.visitor.rg);

    String phone = widget.visitor.phoneNumber;
    _phoneFieldController = TextEditingController(
        text: phone != null && phone.length > 7
            ? '(${phone.substring(0, 2)})${phone.substring(2, 7)}-${phone.substring(7)}'
            : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.visitor.rgUrl != null) {
      _hasImage = true;
    }
    return Scaffold(
        key: _mainGlobalKey,
        backgroundColor: ColorsRes.primaryColor,
        appBar: AppBar(
          title: Text(
            widget.visitor.id == null
                ? "Cadastro de Visitantes"
                : "Edição de Visitante",
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
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, bottom: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _nameFieldController,
                                        labelText: "Nome",
                                        iconData: Icons.account_circle,
                                        focusNode:
                                            registerVisitorBloc.nameFocus,
                                        nextFocusNode:
                                            registerVisitorBloc.rgFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            registerVisitorBloc.changeName,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _rgFieldController,
                                        labelText: "RG",
                                        labelError: docAlreadyInUse
                                            ? "Visitante já registrado"
                                            : "RG não pode ser vazio",
                                        iconData: Icons.assignment_ind,
                                        focusNode: registerVisitorBloc.rgFocus,
                                        nextFocusNode:
                                            registerVisitorBloc.phoneFocus,
                                        textInputAction: TextInputAction.next,
                                        textInputFormatter: [
                                          MaskedTextInputFormatter(
                                            mask: 'XX.XXX.XXX-X',
                                            separator: '.',
                                          ),
                                          MaskedTextInputFormatter(
                                            mask: 'XX.XXX.XXX-X',
                                            separator: '-',
                                          )
                                        ],
                                        onChanged: registerVisitorBloc.changeRg,
                                        isError: docAlreadyInUse,
                                        enabled: false,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _phoneFieldController,
                                        labelText: "Celular (opcional)",
                                        validator: (phone, _) =>
                                            Validators.validatePhone(phone,
                                                "Insira um número válido"),
                                        iconData: Icons.phone_android,
                                        focusNode:
                                            registerVisitorBloc.phoneFocus,
                                        textInputAction: TextInputAction.done,
                                        textInputFormatter: [
                                          MaskedTextInputFormatter(
                                            mask: '(XX)XXXXX-XXXX',
                                            separator: '(',
                                          ),
                                          MaskedTextInputFormatter(
                                            mask: '(XX)XXXXX-XXXX',
                                            separator: ')',
                                          ),
                                          MaskedTextInputFormatter(
                                            mask: '(XX)XXXXX-XXXX',
                                            separator: '-',
                                          ),
                                        ],
                                        textInputType: TextInputType.phone,
                                        onChanged:
                                            registerVisitorBloc.changePhone,
                                        isOptional: true,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          'Adicione uma foto do RG ou da CNH do visitante',
                                          style: TextStyle(
                                            color: _imageNotSelectedError
                                                ? Colors.redAccent
                                                : ColorsRes.primaryColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        !_hasImage
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16.0),
                                                child: ProgressButton(
                                                    color:
                                                        ColorsRes.primaryColor,
                                                    borderRadius: 90.0,
                                                    defaultWidget: Text(
                                                      "BUSCAR FOTO",
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
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                    width: 160,
                                                    // ignore: missing_return
                                                    onPressed: () =>
                                                        chooseFile),
                                              )
                                            : Container(),
                                        registerVisitorBloc
                                                    .rgFileSubject.value !=
                                                null
                                            ? _hasImage
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10.0),
                                                    child: Image.file(
                                                      registerVisitorBloc
                                                          .rgFileSubject.value,
                                                      height: 250,
                                                    ),
                                                  )
                                                : Container()
                                            : widget.visitor.rgUrl != null
                                                ? Image.network(
                                                    widget.visitor.rgUrl,
                                                    height: 150,
                                                  )
                                                : Container(),
                                        _hasImage
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 20.0),
                                                child: Text(
                                                  '(Caso a foto escolhida não corresponda ao RG cadastrado ou não esteja '
                                                  'com as informações visíveis, consequente multa poderá ser aplicada)',
                                                  textAlign: TextAlign.center,
                                                ),
                                              )
                                            : Container(),
                                        _hasImage
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 24.0),
                                                child: ProgressButton(
                                                    color:
                                                        ColorsRes.primaryColor,
                                                    borderRadius: 90.0,
                                                    defaultWidget: Text(
                                                      "TROCAR FOTO",
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
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                    width: 160,
                                                    // ignore: missing_return
                                                    onPressed: () =>
                                                        chooseFile),
                                              )
                                            : Container(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16.0, bottom: 24.0),
                                          child: ProgressButton(
                                            color: ColorsRes.primaryColor,
                                            borderRadius: 90.0,
                                            defaultWidget: Text(
                                              widget.visitor.id == null
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
                                                  .validate()) {
                                                setState(() {
                                                  _imageNotSelectedError =
                                                      !_hasImage;
                                                });

                                                String result;
                                                if (widget.visitor.id == null) {
                                                  (_mainGlobalKey.currentState
                                                          as ScaffoldState)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Registrando visitante')));

                                                  result =
                                                      await registerVisitorBloc
                                                          .saveVisitor();
                                                } else {
                                                  (_mainGlobalKey.currentState
                                                          as ScaffoldState)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Atualizando visitante')));

                                                  result =
                                                      await registerVisitorBloc
                                                          .updateVisitor();
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
                                                          widget.visitor.id ==
                                                                  null
                                                              ? 'Visitante registrado com sucesso'
                                                              : 'Visitante atualizado com sucesso');

                                                      if (globals.isUserAdmin) {
                                                        Navigator.pushNamed(
                                                            context,
                                                            Constants
                                                                .visitorsCentreAdminRoute);
                                                      } else {
                                                        Navigator
                                                            .pushNamedAndRemoveUntil(
                                                          context,
                                                          Constants
                                                              .visitorsCentreRoute,
                                                          ModalRoute.withName(
                                                              Constants
                                                                  .visitorsCentreRoute),
                                                          arguments:
                                                              registerVisitorBloc
                                                                  .visitorSubject
                                                                  .value,
                                                        );
                                                      }
                                                    });
                                                    break;
                                                  case "ERROR_DOC_ALREADY_IN_USE":
                                                    (_mainGlobalKey.currentState
                                                            as ScaffoldState)
                                                        .hideCurrentSnackBar();
                                                    setState(() {
                                                      docAlreadyInUse = true;
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
                                                                'Erro no registro de visitante')));
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
          _imageNotSelectedError = false;
          registerVisitorBloc.changeRgFile(image);
        });
      }
    });
  }
}
