// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventsFeedController.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$EventsFeedController on _EventsFeedControllerBase, Store {
  final _$stateAtom = Atom(name: '_EventsFeedControllerBase.state');

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

  final _$initialDateAppliedAtom =
      Atom(name: '_EventsFeedControllerBase.initialDateApplied');

  @override
  int get initialDateApplied {
    _$initialDateAppliedAtom.reportRead();
    return super.initialDateApplied;
  }

  @override
  set initialDateApplied(int value) {
    _$initialDateAppliedAtom.reportWrite(value, super.initialDateApplied, () {
      super.initialDateApplied = value;
    });
  }

  final _$finalDateAppliedAtom =
      Atom(name: '_EventsFeedControllerBase.finalDateApplied');

  @override
  int get finalDateApplied {
    _$finalDateAppliedAtom.reportRead();
    return super.finalDateApplied;
  }

  @override
  set finalDateApplied(int value) {
    _$finalDateAppliedAtom.reportWrite(value, super.finalDateApplied, () {
      super.finalDateApplied = value;
    });
  }

  final _$initialDateSelectedAtom =
      Atom(name: '_EventsFeedControllerBase.initialDateSelected');

  @override
  int get initialDateSelected {
    _$initialDateSelectedAtom.reportRead();
    return super.initialDateSelected;
  }

  @override
  set initialDateSelected(int value) {
    _$initialDateSelectedAtom.reportWrite(value, super.initialDateSelected, () {
      super.initialDateSelected = value;
    });
  }

  final _$finalDateSelectedAtom =
      Atom(name: '_EventsFeedControllerBase.finalDateSelected');

  @override
  int get finalDateSelected {
    _$finalDateSelectedAtom.reportRead();
    return super.finalDateSelected;
  }

  @override
  set finalDateSelected(int value) {
    _$finalDateSelectedAtom.reportWrite(value, super.finalDateSelected, () {
      super.finalDateSelected = value;
    });
  }

  final _$filterIsOpenAtom =
      Atom(name: '_EventsFeedControllerBase.filterIsOpen');

  @override
  bool get filterIsOpen {
    _$filterIsOpenAtom.reportRead();
    return super.filterIsOpen;
  }

  @override
  set filterIsOpen(bool value) {
    _$filterIsOpenAtom.reportWrite(value, super.filterIsOpen, () {
      super.filterIsOpen = value;
    });
  }

  final _$_EventsFeedControllerBaseActionController =
      ActionController(name: '_EventsFeedControllerBase');

  @override
  dynamic setFilterIsOpen(bool isOpen) {
    final _$actionInfo = _$_EventsFeedControllerBaseActionController
        .startAction(name: '_EventsFeedControllerBase.setFilterIsOpen');
    try {
      return super.setFilterIsOpen(isOpen);
    } finally {
      _$_EventsFeedControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setInitialDate(DateTime date) {
    final _$actionInfo = _$_EventsFeedControllerBaseActionController
        .startAction(name: '_EventsFeedControllerBase.setInitialDate');
    try {
      return super.setInitialDate(date);
    } finally {
      _$_EventsFeedControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setFinalDate(DateTime date) {
    final _$actionInfo = _$_EventsFeedControllerBaseActionController
        .startAction(name: '_EventsFeedControllerBase.setFinalDate');
    try {
      return super.setFinalDate(date);
    } finally {
      _$_EventsFeedControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic applyFilter() {
    final _$actionInfo = _$_EventsFeedControllerBaseActionController
        .startAction(name: '_EventsFeedControllerBase.applyFilter');
    try {
      return super.applyFilter();
    } finally {
      _$_EventsFeedControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state},
initialDateApplied: ${initialDateApplied},
finalDateApplied: ${finalDateApplied},
initialDateSelected: ${initialDateSelected},
finalDateSelected: ${finalDateSelected},
filterIsOpen: ${filterIsOpen}
    ''';
  }
}
