import 'package:flutter/material.dart';

import 'Button.dart';
import 'InputField.dart';

class LoginScreenForm extends StatelessWidget {
  final _loginBloc;

  LoginScreenForm(this._loginBloc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 96.0, 32.0, 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "Faça o seu login para entrar.",
                style: TextStyle(
                    fontSize: 28, fontFamily: 'Poppins', color: Colors.black87),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: InputField(
                  obscure: false,
                  labelText: "Informe o seu e-mail",
                  stream: _loginBloc.outEmail,
                  onChanged: _loginBloc.changeEmail,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: InputField(
                  obscure: true,
                  labelText: "Código funcional",
                  stream: _loginBloc.outPassword,
                  onChanged: _loginBloc.changePassword,
                ),
              ),
            ],
          ),
          StreamBuilder<bool>(
            stream: _loginBloc.outSubmitValid,
            builder: (context, snapshot) {
              return SizedBox(
                  height: 56,
                  child: Button("Entrar", snapshot, _loginBloc.submit, null));
            },
          ),
        ],
      ),
    );
  }
}
