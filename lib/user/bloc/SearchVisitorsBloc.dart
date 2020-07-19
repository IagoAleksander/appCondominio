import 'dart:async';

import 'package:app_condominio/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

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