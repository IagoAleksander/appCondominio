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

class VisitorsLiberatedPageBloc
    extends Bloc<GeneralBlocState, GeneralBlocState> {
  var historyEntries;
  HashMap visitors = new HashMap<String, Visitor>();
  List<Visitor> visitorsList = new List<Visitor>();

  final BaseAuth auth = new Auth();

  // init StreamController
  final _historyStreamController = BehaviorSubject<List<Visitor>>();

  StreamSink<List<Visitor>> get historySink => _historyStreamController.sink;

  // expose data from stream
  Stream<List<Visitor>> get streamHistory => _historyStreamController.stream;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  VisitorsLiberatedPageBloc() {
    updateHistoryList();
  }

  @override
  Future<Function> close() {
    _historyStreamController.close();
    return super.close();
  }

  updateHistoryList() async {
    FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();

    CollectionReference col = Firestore.instance.collection('accessCodes');
    Query colFiltered = col.where("isActive", isEqualTo: true);

    if (!globals.isUserAdmin)
      colFiltered = colFiltered.where("createdBy", isEqualTo: currentUser.uid);

    historyEntries = await colFiltered.getDocuments();

    List<String> visitorsIdList = new List<String>();
    visitorsList.clear();

    historyEntries.documents.forEach((element) {
      AccessCode accessCode = AccessCode.fromJson(element.data);
      if (!visitorsIdList.contains(accessCode.createdTo) &&
          accessCode.isActive) {
        visitorsIdList.add(accessCode.createdTo);
      }
    });

    await Future.forEach(visitorsIdList, (String visitorId) async {
      var snapshot = await Firestore.instance
          .collection('visitors')
          .document(visitorId)
          .get();

      if (snapshot != null && snapshot.exists) {
        Visitor visitor = Visitor.fromJson(snapshot.data);
        visitor.id = snapshot.documentID;
        if (visitor.isLiberated) {
          visitorsList.add(visitor);
        }
      }
    });

    historySink.add(visitorsList);
  }
}
