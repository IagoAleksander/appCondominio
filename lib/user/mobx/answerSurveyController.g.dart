// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answerSurveyController.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AnswerSurveyController on _AnswerSurveyControllerBase, Store {
  final _$stateAtom = Atom(name: '_AnswerSurveyControllerBase.state');

  @override
  EnumState get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(EnumState value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  final _$radioValuesObservableAtom =
      Atom(name: '_AnswerSurveyControllerBase.radioValuesObservable');

  @override
  ObservableList<int> get radioValuesObservable {
    _$radioValuesObservableAtom.reportRead();
    return super.radioValuesObservable;
  }

  @override
  set radioValuesObservable(ObservableList<int> value) {
    _$radioValuesObservableAtom.reportWrite(value, super.radioValuesObservable,
        () {
      super.radioValuesObservable = value;
    });
  }

  final _$needToValidateAtom =
      Atom(name: '_AnswerSurveyControllerBase.needToValidate');

  @override
  bool get needToValidate {
    _$needToValidateAtom.reportRead();
    return super.needToValidate;
  }

  @override
  set needToValidate(bool value) {
    _$needToValidateAtom.reportWrite(value, super.needToValidate, () {
      super.needToValidate = value;
    });
  }

  final _$_AnswerSurveyControllerBaseActionController =
      ActionController(name: '_AnswerSurveyControllerBase');

  @override
  dynamic changeState(EnumState state) {
    final _$actionInfo = _$_AnswerSurveyControllerBaseActionController
        .startAction(name: '_AnswerSurveyControllerBase.changeState');
    try {
      return super.changeState(state);
    } finally {
      _$_AnswerSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateRadioValue(int index, int value) {
    final _$actionInfo = _$_AnswerSurveyControllerBaseActionController
        .startAction(name: '_AnswerSurveyControllerBase.updateRadioValue');
    try {
      return super.updateRadioValue(index, value);
    } finally {
      _$_AnswerSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setNeedToValidate(bool needToValidate) {
    final _$actionInfo = _$_AnswerSurveyControllerBaseActionController
        .startAction(name: '_AnswerSurveyControllerBase.setNeedToValidate');
    try {
      return super.setNeedToValidate(needToValidate);
    } finally {
      _$_AnswerSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state},
radioValuesObservable: ${radioValuesObservable},
needToValidate: ${needToValidate}
    ''';
  }
}
