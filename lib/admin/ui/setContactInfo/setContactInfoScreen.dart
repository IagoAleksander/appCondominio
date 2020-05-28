import 'dart:async';

import 'package:app_condominio/admin/bloc/SetContactInfoBloc.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/contact_info.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';

class SetContactInfoScreen extends StatefulWidget {
  final ContactInfo info;

  SetContactInfoScreen(this.info);

  @override
  _SetContactInfoScreenState createState() => _SetContactInfoScreenState();
}

class _SetContactInfoScreenState extends State<SetContactInfoScreen> {
  SetContactInfoBloc setContactInfoBloc;
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;

  var _emailFieldController;
  var _phoneFieldController;

  @override
  void initState() {
    setContactInfoBloc = SetContactInfoBloc(widget.info);

    _emailFieldController = TextEditingController(
        text: widget.info != null ? widget.info.email : null);

    String phone = widget.info != null ? widget.info.phoneNumber : null;
    _phoneFieldController = TextEditingController(
        text: widget.info != null
            ? widget.info.phoneNumber != null &&
                    widget.info.phoneNumber.length > 7
                ? '(${phone.substring(0, 2)})${phone.substring(2, 7)}-${phone.substring(7)}'
                : null
            : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          "Configurar Contato",
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
                                      padding: const EdgeInsets.only(
                                          top: 16.0, bottom: 20.0),
                                      child: Text(
                                        'Adicione a informação dos meios de comunicação desejados para contato',
                                        style: TextStyle(
                                          color: ColorsRes.primaryColor,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 12.0, bottom: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _emailFieldController,
                                        labelText: "Email",
                                        validator: (email, _) =>
                                            Validators.validateEmail(email,
                                                "Insira um email válido"),
                                        iconData: Icons.account_circle,
                                        focusNode:
                                            setContactInfoBloc.emailFocus,
                                        nextFocusNode:
                                            setContactInfoBloc.phoneFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged:
                                            setContactInfoBloc.changeEmail,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        controller: _phoneFieldController,
                                        labelText: "Telefone",
                                        validator: (phone, _) =>
                                            Validators.validatePhone(phone,
                                                "Insira um número válido"),
                                        iconData: Icons.phone_android,
                                        focusNode:
                                            setContactInfoBloc.phoneFocus,
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
                                          LengthLimitingTextInputFormatter(14),
                                        ],
                                        textInputType: TextInputType.phone,
                                        onChanged: (value) => setContactInfoBloc
                                            .changePhone(value),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 26.0, bottom: 24.0),
                                      child: ProgressButton(
                                        color: ColorsRes.primaryColor,
                                        borderRadius: 90.0,
                                        defaultWidget: Text(
                                          "SALVAR",
                                          style: TextStyle(color: Colors.white),
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
                                            String result;
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Atualizando informações')));

                                            result = await setContactInfoBloc
                                                .updateContactInfo();

                                            Scaffold.of(context)
                                                .hideCurrentSnackBar();
                                            switch (result) {
                                              case "SUCCESS":
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Informações para contato atualizadas com sucesso')));

                                                Timer(
                                                    Duration(
                                                        milliseconds: 1500),
                                                    () {
                                                  Navigator
                                                      .pushNamedAndRemoveUntil(
                                                    context,
                                                    Constants.homeRoute,
                                                    ModalRoute.withName(
                                                        Constants.homeRoute),
                                                  );
                                                });
                                                break;
                                              case "ERROR_NOTHING_CHANGE":
                                                Scaffold.of(context)
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
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Erro na atualização das informações')));
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
