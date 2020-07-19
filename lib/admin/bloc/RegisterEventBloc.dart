import 'dart:io';

import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class RegisterEventBloc extends Bloc<GeneralBlocState, GeneralBlocState>
    with Validators {
  //Focus node
  final FocusNode titleFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();

  //Subjects
  var eventSubject = BehaviorSubject<FeedEvent>();
  var titleSubject = BehaviorSubject<String>();
  var descriptionSubject = BehaviorSubject<String>();
  var imageUrlSubject = BehaviorSubject<String>();
  var imageFileSubject = BehaviorSubject<File>();
  var eventDateSubject = BehaviorSubject<int>();
  var isActiveSubject = BehaviorSubject<bool>.seeded(true);
  var sendNotificationSubject = BehaviorSubject<bool>.seeded(true);

// Changes
  Function(FeedEvent) get changeEvent => eventSubject.sink.add;

  Function(String) get changeTitle => titleSubject.sink.add;

  Function(String) get changeDescription => descriptionSubject.sink.add;

  Function(String) get changeImageUrl => imageUrlSubject.sink.add;

  Function(File) get changeImageFile => imageFileSubject.sink.add;

  Function(int) get changeEventDate => eventDateSubject.sink.add;

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

  RegisterEventBloc(FeedEvent event) {
    if (event != null) {
      changeEvent(event);
      changeTitle(event.title);
      changeDescription(event.description);
      changeImageUrl(event.imageUrl);
      changeEventDate(event.eventDateInMillis);
      changeIsActive(event.isActive);
      changeSendNotification(event.sendNotification);
    }
  }

  @override
  Future<Function> close() {
    eventSubject.close();
    titleSubject.close();
    descriptionSubject.close();
    imageUrlSubject.close();
    imageFileSubject.close();
    eventDateSubject.close();
    isActiveSubject.close();
    sendNotificationSubject.close();
    return super.close();
  }

  Future uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('event/${DateTime.now().millisecondsSinceEpoch}');
    StorageUploadTask uploadTask =
        storageReference.putFile(imageFileSubject.value);

    await uploadTask.onComplete;
    print('File Uploaded');

    await storageReference.getDownloadURL().then((fileURL) {
      changeImageUrl(fileURL);
    });
  }

  Future<String> saveEvent() async {
    try {
      if (titleSubject.value == null ||
          titleSubject.value.isEmpty ||
          descriptionSubject.value == null ||
          descriptionSubject.value.isEmpty ||
          eventDateSubject.value == null) {
        print("Error null values");
        return "ERROR";
      }

      if (imageFileSubject.value != null) await uploadFile();

      FeedEvent event = FeedEvent(
          title: titleSubject.value,
          description: descriptionSubject.value,
          imageUrl: imageUrlSubject.value,
          createdDateInMillis: DateTime.now().millisecondsSinceEpoch,
          eventDateInMillis: eventDateSubject.value,
          isActive: isActiveSubject.value,
          sendNotification: sendNotificationSubject.value);
      eventSubject.add(event);

      Firestore.instance.collection('feedEvents').add(event.toJson());

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
          descriptionSubject.value.isEmpty ||
          eventDateSubject.value == null) {
        print("Error null values");
        return "ERROR";
      }

      if (titleSubject.value == eventSubject.value.title &&
          descriptionSubject.value == eventSubject.value.description &&
          imageFileSubject.value == null &&
          eventDateSubject.value == eventSubject.value.eventDateInMillis) {
        print("Error same values");
        return "ERROR_NOTHING_CHANGE";
      }

      final snapShot = await Firestore.instance
          .collection('feedEvents')
          .document(eventSubject.value.id)
          .get();

      if (snapShot == null || !snapShot.exists) {
        print("Event not found");
        return "ERROR_EVENT_NOT_FOUND";
      }

      FeedEvent event = FeedEvent.fromJson(snapShot.data);

      if (imageFileSubject.value != null) await uploadFile();

      FeedEvent newEvent = FeedEvent(
          title: titleSubject.value,
          description: descriptionSubject.value,
          imageUrl: imageUrlSubject.value,
          createdDateInMillis: event.createdDateInMillis,
          eventDateInMillis: eventDateSubject.value,
          isActive: isActiveSubject.value,
          sendNotification: sendNotificationSubject.value);
      newEvent.id = eventSubject.value.id;
      eventSubject.add(newEvent);

      Firestore.instance
          .collection('feedEvents')
          .document(eventSubject.value.id)
          .setData(eventSubject.value.toJson());

      print("SUCCESS");
      return "SUCCESS";
    } catch (error) {
      print(error.toString());
      return error;
    }
  }
}
