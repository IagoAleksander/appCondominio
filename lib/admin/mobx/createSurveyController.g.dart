// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'createSurveyController.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CreateSurveyController on _CreateSurveyControllerBase, Store {
  final _$questionsAtom = Atom(name: '_CreateSurveyControllerBase.questions');

  @override
  ObservableList<MeetingSurveyQuestion> get questions {
    _$questionsAtom.reportRead();
    return super.questions;
  }

  @override
  set questions(ObservableList<MeetingSurveyQuestion> value) {
    _$questionsAtom.reportWrite(value, super.questions, () {
      super.questions = value;
    });
  }

  final _$stateAtom = Atom(name: '_CreateSurveyControllerBase.state');

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

  final _$selectedQuestionAtom =
      Atom(name: '_CreateSurveyControllerBase.selectedQuestion');

  @override
  int get selectedQuestion {
    _$selectedQuestionAtom.reportRead();
    return super.selectedQuestion;
  }

  @override
  set selectedQuestion(int value) {
    _$selectedQuestionAtom.reportWrite(value, super.selectedQuestion, () {
      super.selectedQuestion = value;
    });
  }

  final _$selectedChoiceAtom =
      Atom(name: '_CreateSurveyControllerBase.selectedChoice');

  @override
  int get selectedChoice {
    _$selectedChoiceAtom.reportRead();
    return super.selectedChoice;
  }

  @override
  set selectedChoice(int value) {
    _$selectedChoiceAtom.reportWrite(value, super.selectedChoice, () {
      super.selectedChoice = value;
    });
  }

  final _$_CreateSurveyControllerBaseActionController =
      ActionController(name: '_CreateSurveyControllerBase');

  @override
  dynamic setSelectedQuestion(int index) {
    final _$actionInfo = _$_CreateSurveyControllerBaseActionController
        .startAction(name: '_CreateSurveyControllerBase.setSelectedQuestion');
    try {
      return super.setSelectedQuestion(index);
    } finally {
      _$_CreateSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setSelectedChoice(int index) {
    final _$actionInfo = _$_CreateSurveyControllerBaseActionController
        .startAction(name: '_CreateSurveyControllerBase.setSelectedChoice');
    try {
      return super.setSelectedChoice(index);
    } finally {
      _$_CreateSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic addQuestion(MeetingSurveyQuestion question) {
    final _$actionInfo = _$_CreateSurveyControllerBaseActionController
        .startAction(name: '_CreateSurveyControllerBase.addQuestion');
    try {
      return super.addQuestion(question);
    } finally {
      _$_CreateSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic updateQuestions(int index, MeetingSurveyQuestion question) {
    final _$actionInfo = _$_CreateSurveyControllerBaseActionController
        .startAction(name: '_CreateSurveyControllerBase.updateQuestions');
    try {
      return super.updateQuestions(index, question);
    } finally {
      _$_CreateSurveyControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
questions: ${questions},
state: ${state},
selectedQuestion: ${selectedQuestion},
selectedChoice: ${selectedChoice}
    ''';
  }
}
