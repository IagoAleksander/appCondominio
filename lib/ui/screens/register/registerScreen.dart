import 'package:app_condominio/bloc/RegisterBloc.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterBloc registerBloc = RegisterBloc();
  final _formKey = GlobalKey<FormState>();

  bool _autoValidate = false;
  bool emailAlreadyInUse = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Image(image: AssetImage('assets/logo.png'))),
                    Container(
                      padding: EdgeInsets.only(top: 12.0),
                      child: Text("Registro",
                          style:
                              TextStyle(fontSize: 35.0, color: Colors.white)),
                    ),
//                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
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
                                        labelText: "Nome",
                                        iconData: Icons.account_circle,
                                        focusNode: registerBloc.nameFocus,
                                        nextFocusNode: registerBloc.emailFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged: registerBloc.changeName,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                          labelText: "Email",
                                          labelError: emailAlreadyInUse
                                              ? "Email não disponível"
                                              : "Email inválido",
                                          iconData: Icons.email,
                                          focusNode: registerBloc.emailFocus,
                                          nextFocusNode: registerBloc.rgFocus,
                                          textInputAction: TextInputAction.next,
                                          onChanged: registerBloc.changeEmail,
                                          validator:
                                              LoginValidators.validateEmail,
                                          isError: emailAlreadyInUse),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        labelText: "RG",
                                        labelError: "RG não pode ser vazio",
                                        iconData: Icons.assignment_ind,
                                        focusNode: registerBloc.rgFocus,
                                        nextFocusNode:
                                            registerBloc.apartmentFocus,
                                        textInputAction: TextInputAction.next,
                                        maskedTextInputFormatter: [
                                          MaskedTextInputFormatter(
                                            mask: 'XX.XXX.XXX-X',
                                            separator: '.',
                                          ),
                                          MaskedTextInputFormatter(
                                            mask: 'XX.XXX.XXX-X',
                                            separator: '-',
                                          )
                                        ],
                                        onChanged: registerBloc.changeRg,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        labelText: "Apartamento",
                                        labelError:
                                            "Por favor, informe o seu apartamento",
                                        iconData: Icons.store,
                                        focusNode: registerBloc.apartmentFocus,
                                        nextFocusNode:
                                            registerBloc.passwordFocus,
                                        textInputAction: TextInputAction.next,
                                        textInputType: TextInputType.number,
                                        onChanged: registerBloc.changeApartment,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        labelText: "Senha",
                                        labelError:
                                            "Senha precisa conter ao menos 6 dígitos",
                                        iconData: Icons.lock,
                                        focusNode: registerBloc.passwordFocus,
                                        nextFocusNode:
                                            registerBloc.confirmPasswordFocus,
                                        textInputAction: TextInputAction.next,
                                        onChanged: registerBloc.changePassword,
                                        obscureText: true,
                                        validator:
                                            LoginValidators.validatePassword,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, bottom: 12.0),
                                      alignment: Alignment.center,
                                      child: TextFormFieldCustom(
                                        labelText: "Confirmar senha",
                                        labelError:
                                            "Confirmação de senha incorreta",
                                        iconData: Icons.lock,
                                        focusNode:
                                            registerBloc.confirmPasswordFocus,
                                        textInputAction: TextInputAction.done,
                                        onChanged:
                                            registerBloc.changeConfirmPassword,
                                        obscureText: true,
                                        validator:
                                            LoginValidators.validatePassword,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: ProgressButton(
                                color: ColorsRes.primaryColor,
                                borderRadius: 90.0,
                                defaultWidget: Text(
                                  "CRIAR CONTA",
                                  style: TextStyle(color: Colors.white),
                                ),
                                progressWidget: const CircularProgressIndicator(
                                  strokeWidth: 4,
                                  backgroundColor: ColorsRes.accentColor,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
//                        height: 58,
                                width: 160,
                                // ignore: missing_return
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    // If the form is valid, display a Snackbar.
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text('Criando conta')));

                                    emailAlreadyInUse = false;
                                    String result =
                                        await registerBloc.saveUser();

                                    switch (result) {
                                      case "SUCCESS":
                                        return () {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              Constants.registerRoute,
                                              ModalRoute.withName(
                                                  Constants.registerRoute));
                                        };
                                        break;
                                      case "ERROR_EMAIL_ALREADY_IN_USE":
                                        setState(() {
                                          emailAlreadyInUse = true;
                                        });
                                        break;
                                      default:
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Erro na criação de conta')));
                                        Navigator.pop(context);
                                        break;
                                    }

//                                    int score = await Future.delayed(
//                                        const Duration(milliseconds: 3000),
//                                            () => 42);
                                    // After [onPressed], it will trigger animation running backwards, from end to beginning
//                                    return () {
//                                      // Optional returns is returning a VoidCallback that will be called
//                                      // after the animation is stopped at the beginning.
//                                      // A best practice would be to do time-consuming task in [onPressed],
//                                      // and do page navigation in the returned VoidCallback.
//                                      // So that user won't missed out the reverse animation.
//                                    };

                                  } else {
                                    setState(() {
                                      _autoValidate = true;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          );
        },
      ),
    );
  }
}
