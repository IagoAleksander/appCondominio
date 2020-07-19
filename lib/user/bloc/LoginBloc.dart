import 'package:app_condominio/utils/base_auth.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc extends Bloc<GeneralBlocState, GeneralBlocState> with Validators{

  //Focus node
  final loginFocus = FocusNode();
  final passwordFocus = FocusNode();

  //Subjects
  var loginSubject = BehaviorSubject<String>();
  var passwordSubject = BehaviorSubject<String>();

  final BaseAuth auth = new Auth();

//  //Streams
//  Stream<String> get outLogin => loginSubject.stream.transform(validateEmail());
//
//  Stream<String> get outPassword => passwordSubject.stream
//      .transform(validateNotEmpty("Insira uma senha válida"));

  //Changes
  Function(String) get changeLogin => loginSubject.sink.add;

  Function(String) get changePassword => passwordSubject.sink.add;

//  Stream<bool> get outSubmitValid =>
//      CombineLatestStream.combine2(outLogin, outPassword, (a, b) => true);

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  @override
  Future<Function> close() {
    loginSubject.close();
    passwordSubject.close();
    super.close();
  }

  Future<String> validateAndSubmit(String name, String password) async {
    String userId;
    bool isError = false;
    userId = await auth.signIn(name, password).catchError((error) {
      isError = true;
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          return 'Email inválido';
        case "ERROR_USER_NOT_FOUND":
          return 'Usuário não encontrado';
        case "ERROR_WRONG_PASSWORD":
          return 'Senha incorreta';
        default:
          return 'Ocorreu um erro';
      }
    });

    if (isError) {
      return userId;
    } else {
      print('Signed in: $userId');
      return null;
    }

  }

}
