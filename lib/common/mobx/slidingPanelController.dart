import 'package:mobx/mobx.dart';

part 'slidingPanelController.g.dart';

class SlidingPanelController = _SlidingPanelControllerBase
    with _$SlidingPanelController;

enum EnumState {
  IDLE,
  LOADING,
}

abstract class _SlidingPanelControllerBase with Store {
  @observable
  EnumState state = EnumState.IDLE;

  @observable
  bool filterIsOpen = false;

  @action
  setFilterIsOpen(bool isOpen) {
    filterIsOpen = isOpen;
  }
}
