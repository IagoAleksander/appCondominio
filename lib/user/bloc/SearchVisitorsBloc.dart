import 'dart:async';
import 'dart:collection';

import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/utils/base_auth.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import '../../utils/globals.dart' as globals;

class SearchVisitorsBloc extends Bloc<GeneralBlocState, GeneralBlocState> {

  var isOpenSubject = BehaviorSubject<bool>.seeded(false);
  var searchSubject = BehaviorSubject<String>.seeded("");

  Function(bool) get changeIsOpen => isOpenSubject.sink.add;
  Function(String) get changeSearch => searchSubject.sink.add;

  Stream<bool> get streamIsOpen => isOpenSubject.stream;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  @override
  Future<Function> close() {
    isOpenSubject.close();
    searchSubject.close();
    return super.close();
  }
}