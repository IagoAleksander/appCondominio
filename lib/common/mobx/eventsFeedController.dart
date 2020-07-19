import 'package:app_condominio/utils/date_utils.dart';
import 'package:mobx/mobx.dart';

part 'eventsFeedController.g.dart';

class EventsFeedController = _EventsFeedControllerBase
    with _$EventsFeedController;

enum EnumState {
  IDLE,
  LOADING,
}

abstract class _EventsFeedControllerBase with Store {
  @observable
  EnumState state = EnumState.IDLE;

  @observable
  int initialDateApplied = DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch;

  @observable
  int finalDateApplied = DateUtils.MAX_DATE;

  @observable
  int initialDateSelected = DateTime.now().subtract(Duration(days: 60)).millisecondsSinceEpoch;

  @observable
  int finalDateSelected;

  @observable
  bool filterIsOpen = false;

  @action
  setFilterIsOpen(bool isOpen) {
    filterIsOpen = isOpen;
  }

  @action
  setInitialDate(DateTime date) {
    this.initialDateSelected = date.millisecondsSinceEpoch;
  }

  @action
  setFinalDate(DateTime date) {
    this.finalDateSelected = date.millisecondsSinceEpoch;
  }

  @action
  applyFilter() {
    this.initialDateApplied = initialDateSelected;
    this.finalDateApplied = finalDateSelected + DateUtils.DAY_IN_MILLIS;
  }
}
