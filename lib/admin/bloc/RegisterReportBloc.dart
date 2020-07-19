import 'dart:io';

import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RegisterReportBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with Validators {
  //Focus node
  final FocusNode titleFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  //Subjects
  var reportSubject = BehaviorSubject<EventReport>();
  var titleSubject = BehaviorSubject<String>();
  var descriptionSubject = BehaviorSubject<String>();

// Changes
  Function(EventReport) get changeReport => reportSubject.sink.add;

  Function(String) get changeTitle => titleSubject.sink.add;

  Function(String) get changeDescription => descriptionSubject.sink.add;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  RegisterReportBloc(EventReport report) {
    if (report != null) {
      changeReport(report);
      changeTitle(report.title);
      changeDescription(report.description);
    }
  }

  @override
  Future<Function> close() {
    reportSubject.close();
    titleSubject.close();
    descriptionSubject.close();
    return super.close();
  }

  Future<String> saveReport(String eventID) async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          descriptionSubject.value == null ||
          descriptionSubject.value.isEmpty) {
        print("Error null values");
        return "ERROR";
      }

      EventReport report = EventReport(
        title: titleSubject.value,
        description: descriptionSubject.value,
      );
      reportSubject.add(report);

      Firestore.instance
          .collection('eventReports')
          .document(eventID)
          .setData(reportSubject.value.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error.code;
    }
  }

  Future<String> updateEvent() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          descriptionSubject.value == null ||
          descriptionSubject.value.isEmpty) {
        print("Error null values");
        return "ERROR";
      }

      if (titleSubject.value == reportSubject.value.title &&
          descriptionSubject.value == reportSubject.value.description) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      final snapShot = await Firestore.instance
          .collection('eventReports')
          .document(reportSubject.value.id)
          .get();

      if (snapShot == null || !snapShot.exists) {
        print("Event not found");
        return "ERROR_EVENT_NOT_FOUND";
      }

      EventReport report = EventReport.fromJson(snapShot.data);

      EventReport newReport = EventReport(
        title: titleSubject.value,
        description: descriptionSubject.value,
      );
      newReport.id = reportSubject.value.id;
      reportSubject.add(newReport);

      Firestore.instance
          .collection('eventReports')
          .document(reportSubject.value.id)
          .setData(reportSubject.value.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error;
    }
  }
}
