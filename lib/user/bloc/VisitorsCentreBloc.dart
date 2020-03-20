import 'dart:async';
import 'dart:collection';

import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/base_auth.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class VisitorsCentreBloc extends Bloc<GeneralBlocState, GeneralBlocState> {
  var timer, entries, historyEntries;
  HashMap visitors = new HashMap<String, Visitor>();
  List<Visitor> visitorsList = new List<Visitor>();

  //Focus node
  final FocusNode searchFocus = FocusNode();

  //Subjects
  var searchSubject = BehaviorSubject<String>();

  final BaseAuth auth = new Auth();

  //Changes
  Function(String) get changeSearch => searchSubject.sink.add;

  // init StreamController
  final _visitorStreamController = BehaviorSubject<List<Visitor>>();
  final _historyStreamController = BehaviorSubject<List<Visitor>>();

  StreamSink<List<Visitor>> get visitorSink => _visitorStreamController.sink;

  StreamSink<List<Visitor>> get historySink => _historyStreamController.sink;

  // expose data from stream
  Stream<List<Visitor>> get streamVisitor => _visitorStreamController.stream;

  Stream<List<Visitor>> get streamHistory => _historyStreamController.stream;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  VisitorsCentreBloc() {
    entries = Firestore.instance.collection('visitors').getDocuments();

    searchSubject.listen((searchText) {
      if (timer != null) {
        timer.cancel();
      }
      if (searchText.length >= 3) {
        timer = Timer(Duration(milliseconds: 1500), () {
          search(searchText);
        });
      } else {
        visitorSink.add(new List<Visitor>());
      }
    });

    updateHistoryList();
  }

  @override
  Future<Function> close() {
    searchSubject.close();
    _visitorStreamController.close();
    _historyStreamController.close();
    return super.close();
  }

  search(String searchText) async {
    if (visitors == null || visitors.isEmpty) {
      entries = await entries;
      entries.documents.forEach((element) {
        Visitor visitor = Visitor.fromJson(element.data);
        visitors[visitor.rg] = visitor;
      });
    }

    List<Visitor> searchResult = new List<Visitor>();

    if (searchText.length >= 3 && visitors != null && visitors.isNotEmpty) {
      for (Visitor visitor in visitors.values) {
        if (visitor.name.contains(searchText)) {
          searchResult.add(visitor);
        }
      }

      visitorSink.add(searchResult);
    } else if (searchText.isEmpty) {
      visitorSink.add(searchResult);
    }
  }

  updateHistoryList() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    historyEntries = await Firestore.instance
        .collection('accessCodes')
        .where("createdBy", isEqualTo: currentUser.uid)
        .where("isActive", isEqualTo: true)
        .getDocuments();

    List<String> visitorsIdList = new List<String>();
    visitorsList.clear();

    historyEntries.documents.forEach((element) {
      AccessCode accessCode = AccessCode.fromJson(element.data);
      if (!visitorsIdList.contains(accessCode.createdTo) && accessCode.isActive) {
        visitorsIdList.add(accessCode.createdTo);
      }
      Firestore.instance.collection('visitors').document(accessCode.createdBy);
    });

    await Future.forEach(visitorsIdList, (String visitorId) async {
      var snapshot = await Firestore.instance
          .collection('visitors')
          .document(visitorId)
          .get();

      if (snapshot != null && snapshot.exists) {
        Visitor visitor = Visitor.fromJson(snapshot.data);
        if (visitor.isLiberated) {
          visitorsList.add(visitor);
        }
      }
    });

    historySink.add(visitorsList);
  }
}
