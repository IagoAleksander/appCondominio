import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/utils/base_auth.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with LoginValidators {
  //Focus node
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode rgFocus = FocusNode();
  final FocusNode buildingFocus = FocusNode();
  final FocusNode apartmentFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  //Subjects
  var nameSubject = BehaviorSubject<String>();
  var emailSubject = BehaviorSubject<String>();
  var rgSubject = BehaviorSubject<String>();
  var buildingSubject = BehaviorSubject<String>();
  var apartmentSubject = BehaviorSubject<String>();
  var passwordSubject = BehaviorSubject<String>();
  var confirmPasswordSubject = BehaviorSubject<String>();

  final BaseAuth auth = new Auth();

// Changes
  Function(String) get changeName => nameSubject.sink.add;

  Function(String) get changeEmail => emailSubject.sink.add;

  Function(String) get changeRg => rgSubject.sink.add;

  Function(String) get changeBuilding => buildingSubject.sink.add;

  Function(String) get changeApartment => apartmentSubject.sink.add;

  Function(String) get changePassword => passwordSubject.sink.add;

  Function(String) get changeConfirmPassword => confirmPasswordSubject.sink.add;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  @override
  Future<Function> close() {
    nameSubject.close();
    emailSubject.close();
    rgSubject.close();
    buildingSubject.close();
    apartmentSubject.close();
    passwordSubject.close();
    confirmPasswordSubject.close();
    return super.close();
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

  Future<String> saveUser() async {
    try {

      if (emailSubject.value == null || passwordSubject.value == null) {
        return "Error";
      }

      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailSubject.value, password: passwordSubject.value);

      User user = User(
          name: nameSubject.value,
          email: emailSubject.value,
          rg: rgSubject.value,
          building: buildingSubject.value,
          apartment: apartmentSubject.value,
          password: passwordSubject.value,
          status: Status.pendingApproval);

      Firestore.instance
          .collection('users')
          .document(result.user.uid)
          .setData(user.toJson());
      return "SUCCESS";
    } catch (error) {
      return error.code;
    }
  }
}
