import 'package:app_condominio/models/contact_info.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SetContactInfoBloc extends Bloc<GeneralBlocState, GeneralBlocState> {
  //Focus node
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();

  //Subjects
  var contactInfoSubject = BehaviorSubject<ContactInfo>();
  var emailSubject = BehaviorSubject<String>();
  var phoneSubject = BehaviorSubject<String>();

// Changes
  Function(ContactInfo) get changeContactInfo => contactInfoSubject.sink.add;

  Function(String) get changeEmail => emailSubject.sink.add;

  changePhone(String phone) {
    phoneSubject.sink.add(phone.replaceAll(RegExp(r'\D'), '').trim());
  }

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  SetContactInfoBloc(ContactInfo info) {
    if (info != null) {
      changeContactInfo(info);
      changeEmail(info.email);
      changePhone(info.phoneNumber);
    }
  }

  @override
  Future<Function> close() {
    contactInfoSubject.close();
    emailSubject.close();
    phoneSubject.close();
    return super.close();
  }

  Future<String> updateContactInfo() async {
    try {
      if (emailSubject.value == null ||
          emailSubject.value.isEmpty ||
          phoneSubject.value == null ||
          phoneSubject.value.isEmpty) {
        print("Error null values");
        return "ERROR";
      }

      if (emailSubject.value == contactInfoSubject.value.email &&
          phoneSubject.value == contactInfoSubject.value.phoneNumber) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      ContactInfo newContactInfo = ContactInfo(
        email: emailSubject.value,
        phoneNumber: phoneSubject.value.replaceAll(RegExp(r'\D'), '').trim(),
      );
      contactInfoSubject.add(newContactInfo);

      Firestore.instance
          .collection('parameters')
          .document('contactInfo')
          .setData(newContactInfo.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error;
    }
  }
}
