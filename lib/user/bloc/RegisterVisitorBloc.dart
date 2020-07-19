import 'dart:io';

import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RegisterVisitorBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with Validators {
  //Focus node
  final FocusNode nameFocus = FocusNode();
  final FocusNode rgFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();

  //Subjects
  var visitorSubject = BehaviorSubject<Visitor>();
  var nameSubject = BehaviorSubject<String>();
  var rgSubject = BehaviorSubject<String>();
  var phoneSubject = BehaviorSubject<String>();
  var rgUrlSubject = BehaviorSubject<String>();
  var rgFileSubject = BehaviorSubject<File>();

// Changes
  Function(Visitor) get changeVisitor => visitorSubject.sink.add;

  Function(String) get changeName => nameSubject.sink.add;

  Function(String) get changeRg => rgSubject.sink.add;

  changePhone(String phone) {
    if (phone != null) {
      phoneSubject.sink.add(phone.replaceAll(RegExp(r'\D'), '').trim());
    }
    else {
      phoneSubject.sink.add(null);
    }
  }

  Function(String) get changeRgUrl => rgUrlSubject.sink.add;

  Function(File) get changeRgFile => rgFileSubject.sink.add;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  RegisterVisitorBloc(Visitor visitor) {
    if (visitor != null) {
      changeVisitor(visitor);
      changeName(visitor.name);
      changeRg(visitor.rg);
      changePhone(visitor.phoneNumber);
      changeRgUrl(visitor.rgUrl);
    }
  }

  @override
  Future<Function> close() {
    visitorSubject.close();
    nameSubject.close();
    rgSubject.close();
    phoneSubject.close();
    rgUrlSubject.close();
    rgFileSubject.close();
    return super.close();
  }

  Future uploadFile() async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('visitor/${rgSubject.value}');
    StorageUploadTask uploadTask =
        storageReference.putFile(rgFileSubject.value);

    await uploadTask.onComplete;
    print('File Uploaded');

    await storageReference.getDownloadURL().then((fileURL) {
      changeRgUrl(fileURL);
    });
  }

  Future<String> saveVisitor() async {
    try {
      if (nameSubject.value == null ||
          nameSubject.value.isEmpty ||
          rgSubject.value == null ||
          rgSubject.value.isEmpty ||
          rgFileSubject.value == null) {
        print("Error null values");
        return "ERROR";
      }

      final snapShot = await Firestore.instance
          .collection('visitors')
          .document(rgSubject.value)
          .get();

      if (snapShot != null && snapShot.exists) {
        print("Visitor already registered");
        return "ERROR_DOC_ALREADY_IN_USE";
      }

      await uploadFile();
      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

      Visitor visitor = Visitor(
        id: rgSubject.value,
        name: nameSubject.value,
        rg: rgSubject.value,
        phoneNumber: phoneSubject.value.replaceAll(RegExp(r'\D'), '').trim(),
        rgUrl: rgUrlSubject.value,
        registeredBy: currentUser.uid,
        isLiberated: false,
      );
      visitorSubject.add(visitor);

      Firestore.instance
          .collection('visitors')
          .document(visitor.id)
          .setData(visitor.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error.code;
    }
  }

  Future<String> updateVisitor() async {
    try {
      if (nameSubject.value == null ||
          nameSubject.value.isEmpty ||
          rgSubject.value == null ||
          rgSubject.value.isEmpty ||
          rgUrlSubject.value == null ||
          rgUrlSubject.value.isEmpty) {
        print("Error null values");
        return "ERROR";
      }

      if (nameSubject.value == visitorSubject.value.name &&
          rgSubject.value == visitorSubject.value.rg &&
          rgFileSubject.value == null &&
          phoneSubject.value != null &&
          phoneSubject.value == visitorSubject.value.phoneNumber) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      final snapShot = await Firestore.instance
          .collection('visitors')
          .document(rgSubject.value)
          .get();

      if (snapShot == null || !snapShot.exists) {
        print("Visitor not found");
        return "ERROR_VISITOR_NOT_FOUND";
      }

      Visitor visitor = Visitor.fromJson(snapShot.data);

      if (rgFileSubject.value != null) await uploadFile();

      FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

      Visitor newVisitor = Visitor(
        id: rgSubject.value,
        name: nameSubject.value,
        rg: rgSubject.value,
        phoneNumber: phoneSubject.value.replaceAll(RegExp(r'\D'), '').trim(),
        rgUrl: rgUrlSubject.value,
        registeredBy: currentUser.uid,
        isLiberated: visitor.isLiberated == null ? false : visitor.isLiberated,
      );
      visitorSubject.add(newVisitor);

      Firestore.instance
          .collection('visitors')
          .document(newVisitor.id)
          .setData(newVisitor.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error;
    }
  }
}
