import 'dart:async';
import 'dart:collection';

import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/base_auth.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class VisitorsCentreBloc extends Bloc<GeneralBlocState, GeneralBlocState> {
  var timer, entries;
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

  StreamSink<List<Visitor>> get visitorSink => _visitorStreamController.sink;

  // expose data from stream
  Stream<List<Visitor>> get streamVisitor => _visitorStreamController.stream;

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
  }

  @override
  Future<Function> close() {
    searchSubject.close();
    _visitorStreamController.close();
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
}
