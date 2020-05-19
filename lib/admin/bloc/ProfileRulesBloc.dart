import 'dart:io';

import 'package:app_condominio/models/profile_rule.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ProfileRulesBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with LoginValidators {
  //Focus node
  final FocusNode titleFocus = FocusNode();
  final FocusNode valueFocus = FocusNode();
  final FocusNode unitFocus = FocusNode();

  //Subjects
  var ruleSubject = BehaviorSubject<ProfileRule>();
  var titleSubject = BehaviorSubject<String>();
  var valueSubject = BehaviorSubject<String>();
  var unitSubject = BehaviorSubject<String>();

// Changes
  Function(ProfileRule) get changeRule => ruleSubject.sink.add;

  Function(String) get changeTitle => titleSubject.sink.add;

  Function(String) get changeValue => valueSubject.sink.add;

  Function(String) get changeUnit => unitSubject.sink.add;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  ProfileRulesBloc() {
    changeUnit("horas");
  }

  void setRuleData(ProfileRule rule) {
    changeRule(rule);
    if (rule != null) {
      changeTitle(rule.title);
      changeValue(rule.value.toString());
      changeUnit(rule.unit);
    }
    else {
      changeTitle("");
      changeValue("");
      changeUnit("horas");
    }
  }

  @override
  Future<Function> close() {
    ruleSubject.close();
    titleSubject.close();
    valueSubject.close();
    unitSubject.close();
    return super.close();
  }

  Future<String> saveRule() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          valueSubject.value == null ||
          int.parse(valueSubject.value) == 0) {
        print("Error null values");
        return "ERROR";
      }

      ProfileRule rule = ProfileRule(
          title: titleSubject.value,
          value: int.parse(valueSubject.value),
          unit: unitSubject.value);
      ruleSubject.add(rule);

      Firestore.instance.collection('profileRules').add(rule.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return "ERROR";
    }
  }

  Future<String> updateRule() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          valueSubject.value == null ||
          int.parse(valueSubject.value) == 0 ||
          unitSubject.value == null ||
          unitSubject.value.isEmpty) {
        print("Error null values");
        return "ERROR";
      }
      if (titleSubject.value == ruleSubject.value.title &&
          int.parse(valueSubject.value) == ruleSubject.value.value &&
          unitSubject.value == ruleSubject.value.unit) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      final snapShot = await Firestore.instance
          .collection('profileRules')
          .document(ruleSubject.value.id)
          .get();

      if (snapShot == null || !snapShot.exists) {
        print("Rule not found");
        return "ERROR_RULE_NOT_FOUND";
      }

      ProfileRule rule = ProfileRule(
          title: titleSubject.value,
          value: int.parse(valueSubject.value),
          unit: unitSubject.value);

      Firestore.instance
          .collection('profileRules')
          .document(ruleSubject.value.id)
          .setData(rule.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return "ERROR";
    }
  }
}
