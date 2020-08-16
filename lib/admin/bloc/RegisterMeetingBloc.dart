import 'dart:io';

import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/meeting.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RegisterMeetingBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with Validators {
  //Focus node
  final FocusNode titleFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode videoIDFocus = FocusNode();

  //Subjects
  var meetingSubject = BehaviorSubject<Meeting>();
  var titleSubject = BehaviorSubject<String>();
  var descriptionSubject = BehaviorSubject<String>();
  var videoIDSubject = BehaviorSubject<String>();
  var meetingDateSubject = BehaviorSubject<int>();
  var isActiveSubject = BehaviorSubject<bool>.seeded(true);
  var sendNotificationSubject = BehaviorSubject<bool>.seeded(true);

// Changes
  Function(Meeting) get changeEvent => meetingSubject.sink.add;

  Function(String) get changeTitle => titleSubject.sink.add;

  Function(String) get changeDescription => descriptionSubject.sink.add;

  Function(String) get changeVideoID => videoIDSubject.sink.add;

  Function(int) get changeMeetingDate => meetingDateSubject.sink.add;

  Function(bool) get changeIsActive => isActiveSubject.sink.add;

  Function(bool) get changeSendNotification => sendNotificationSubject.sink.add;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  Stream<bool> get streamIsActive => isActiveSubject.stream;

  Stream<bool> get streamSendNotification => sendNotificationSubject.stream;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  RegisterMeetingBloc(Meeting meeting) {
    if (meeting != null) {
      changeEvent(meeting);
      changeTitle(meeting.title);
      changeDescription(meeting.description);
      changeMeetingDate(meeting.meetingDateInMillis);
      changeIsActive(meeting.isActive);
      changeSendNotification(meeting.sendNotification);
    }
  }

  @override
  Future<Function> close() {
    meetingSubject.close();
    titleSubject.close();
    descriptionSubject.close();
    videoIDSubject.close();
    meetingDateSubject.close();
    isActiveSubject.close();
    sendNotificationSubject.close();
    return super.close();
  }

  Future<String> saveMeeting() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          descriptionSubject.value == null ||
          descriptionSubject.value.isEmpty ||
          meetingDateSubject.value == null) {
        print("Error null values");
        return "ERROR";
      }

      Meeting meeting = Meeting(
          title: titleSubject.value,
          description: descriptionSubject.value,
          videoID: videoIDSubject.value,
          createdDateInMillis: DateTime.now().millisecondsSinceEpoch,
          meetingDateInMillis: meetingDateSubject.value,
          isActive: isActiveSubject.value,
          sendNotification: sendNotificationSubject.value);
      meetingSubject.add(meeting);

      Firestore.instance.collection('meetings').add(meeting.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error.code;
    }
  }

  Future<String> updateMeeting() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          descriptionSubject.value == null ||
          descriptionSubject.value.isEmpty ||
          meetingDateSubject.value == null) {
        print("Error null values");
        return "ERROR";
      }

      if (titleSubject.value == meetingSubject.value.title &&
          descriptionSubject.value == meetingSubject.value.description &&
          meetingDateSubject.value == meetingSubject.value.meetingDateInMillis &&
          videoIDSubject.value == meetingSubject.value.videoID &&
          isActiveSubject.value == meetingSubject.value.isActive) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      final snapShot = await Firestore.instance
          .collection('meetings')
          .document(meetingSubject.value.id)
          .get();

      if (snapShot == null || !snapShot.exists) {
        print("Event not found");
        return "ERROR_EVENT_NOT_FOUND";
      }

      Meeting meeting = Meeting.fromJson(snapShot.data);

      Meeting newMeeting = Meeting(
          title: titleSubject.value,
          description: descriptionSubject.value,
          videoID: videoIDSubject.value,
          createdDateInMillis: meeting.createdDateInMillis,
          meetingDateInMillis: meetingDateSubject.value,
          isActive: isActiveSubject.value,
          sendNotification: sendNotificationSubject.value);
      newMeeting.id = meetingSubject.value.id;
      meetingSubject.add(newMeeting);

      Firestore.instance
          .collection('meetings')
          .document(meetingSubject.value.id)
          .setData(meetingSubject.value.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error;
    }
  }
}
