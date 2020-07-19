// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slidingPanelController.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SlidingPanelController on _SlidingPanelControllerBase, Store {
  final _$stateAtom = Atom(name: '_SlidingPanelControllerBase.state');

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

  final _$filterIsOpenAtom =
      Atom(name: '_SlidingPanelControllerBase.filterIsOpen');

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

  final _$_SlidingPanelControllerBaseActionController =
      ActionController(name: '_SlidingPanelControllerBase');

  @override
  dynamic setFilterIsOpen(bool isOpen) {
    final _$actionInfo = _$_SlidingPanelControllerBaseActionController
        .startAction(name: '_SlidingPanelControllerBase.setFilterIsOpen');
    try {
      return super.setFilterIsOpen(isOpen);
    } finally {
      _$_SlidingPanelControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state},
filterIsOpen: ${filterIsOpen}
    ''';
  }
}
