import 'package:app_condominio/models/scheduled_event.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class EventsCentreCalendarBloc
    extends Bloc<GeneralBlocState, GeneralBlocState> {
  final DateTime startDate = DateTime.now().subtract(Duration(days: 180));
  final DateTime endDate = DateTime.now().add(Duration(days: 180));
  DateTime selectedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  Map<DateTime, List> eventsList = Map<DateTime, List>();

  //Subjects
  var selectedDayEventsSubject = BehaviorSubject<List>();

  changeSelectedDay(DateTime selectedDay) {
    this.selectedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    setEventsForTheDay();
  }

  Function(List) get changeEvents => selectedDayEventsSubject.sink.add;

  Stream<List> get streamEvents => selectedDayEventsSubject.stream;

  @override
  GeneralBlocState get initialState => GeneralBlocState.IDLE;

  @override
  Stream<GeneralBlocState> mapEventToState(GeneralBlocState event) async* {
    yield event;
  }

  EventsCentreCalendarBloc() {
    updateEventList(null);
    if (eventsList[selectedDay] == null) {
      selectedDayEventsSubject.add([]);
    }
    selectedDayEventsSubject.add(eventsList[selectedDay]);
  }

  @override
  Future<Function> close() {
    selectedDayEventsSubject.close();
    return super.close();
  }

  updateEventList(List<DocumentSnapshot> snapshots) {
    Map<DateTime, List<ScheduledEvent>> events =
        Map<DateTime, List<ScheduledEvent>>();
    List<ScheduledEvent> eventsTemp = List<ScheduledEvent>();
    if (snapshots != null) {
      snapshots.forEach((element) {
        eventsTemp = List<ScheduledEvent>();
        ScheduledEvent event = ScheduledEvent.fromJson(element.data);
        eventsTemp.add(event);
        DateTime _dateRaw =
            DateTime.fromMillisecondsSinceEpoch(event.scheduledDate);
        DateTime _dateKey =
            DateTime(_dateRaw.year, _dateRaw.month, _dateRaw.day);
        if (!events.containsKey(_dateKey)) {
          events.putIfAbsent(_dateKey, () => eventsTemp);
        } else {
          events.update(_dateKey, (value) {
            eventsTemp = value;
            eventsTemp.add(event);
            return eventsTemp;
          });
        }
      });
    }
    DateTime _cursorDate = startDate;
    while (_cursorDate.year != endDate.year ||
        _cursorDate.month != endDate.month ||
        _cursorDate.day != endDate.day) {
      DateTime _dateKey =
          DateTime(_cursorDate.year, _cursorDate.month, _cursorDate.day);
      if (events.containsKey(_dateKey)) {
        if (events[_dateKey].isNotEmpty) {
          eventsList.update(_dateKey, (value) {
            List<ScheduledEvent> eventsTemp = events[_dateKey];
            if (eventsTemp.length == 2) {
              return [
                eventsTemp[0],
                eventsTemp[1],
              ];
            } else if (eventsTemp[0].period == Period.morning) {
              return [
                eventsTemp[0],
                ScheduledEvent(
                    scheduledDate: _dateKey.millisecondsSinceEpoch,
                    period: Period.evening,
                    userId: "",
                    status: ScheduleStatus.available),
              ];
            } else {
              return [
                ScheduledEvent(
                    scheduledDate: _dateKey.millisecondsSinceEpoch,
                    period: Period.morning,
                    userId: "",
                    status: ScheduleStatus.available),
                eventsTemp[0]
              ];
            }
          });
        }
      } else {
        eventsList.putIfAbsent(
            _dateKey,
            () => [
                  ScheduledEvent(
                      scheduledDate: _dateKey.millisecondsSinceEpoch,
                      period: Period.morning,
                      userId: "",
                      status: ScheduleStatus.available),
                  ScheduledEvent(
                      scheduledDate: _dateKey.millisecondsSinceEpoch,
                      period: Period.evening,
                      userId: "",
                      status: ScheduleStatus.available),
                ]);
      }
      _cursorDate = _cursorDate.add(Duration(days: 1));
    }
    setEventsForTheDay();
  }

  setEventsForTheDay() {
    if (eventsList[selectedDay] == null) {
      selectedDayEventsSubject.add([]);
    }
    selectedDayEventsSubject.add(eventsList[selectedDay]);
  }

  ScheduledEvent getEventForPeriod(List events, Period period) {
    if ((events[0] as ScheduledEvent).period == Period.morning) {
      if (period == Period.morning) {
        return events[0] as ScheduledEvent;
      } else {
        return events[1] as ScheduledEvent;
      }
    } else {
      if (period == Period.morning) {
        return events[1] as ScheduledEvent;
      } else {
        return events[0] as ScheduledEvent;
      }
    }
  }

  scheduleEvent(ScheduledEvent event) async {
    ScheduledEvent newScheduledEvent = ScheduledEvent(
      scheduledDate: event.scheduledDate,
      period: event.period,
      userId: globals.firebaseCurrentUser.uid,
      status: ScheduleStatus.waiting_approval,
    );

    QuerySnapshot snapshot = await Firestore.instance
        .collection('scheduled_events')
        .where("scheduledDate", isEqualTo: event.scheduledDate)
        .where("period", isEqualTo: event.period.toString())
        .getDocuments();

    if (snapshot.documents.isNotEmpty) {
      Firestore.instance
          .collection('scheduled_events')
          .document(snapshot.documents[0].documentID)
          .updateData(newScheduledEvent.toJson());
    } else {
      Firestore.instance
          .collection('scheduled_events')
          .add(newScheduledEvent.toJson());
    }
  }

  cancelEvent(ScheduledEvent event) async {
    ScheduledEvent newScheduledEvent = ScheduledEvent(
      scheduledDate: event.scheduledDate,
      period: event.period,
      userId: globals.firebaseCurrentUser.uid,
      status: ScheduleStatus.available,
    );

    QuerySnapshot snapshot = await Firestore.instance
        .collection('scheduled_events')
        .where("scheduledDate", isEqualTo: event.scheduledDate)
        .where("period", isEqualTo: event.period.toString())
        .getDocuments();

    if (snapshot.documents.isNotEmpty) {
      Firestore.instance
          .collection('scheduled_events')
          .document(snapshot.documents[0].documentID)
          .updateData(newScheduledEvent.toJson());
    }
  }
}

//  Future<String> updateContactInfo() async {
//    try {
//      if (emailSubject.value == null ||
//          emailSubject.value.isEmpty ||
//          phoneSubject.value == null ||
//          phoneSubject.value.isEmpty) {
//        print("Error null values");
//        return "ERROR";
//      }
//
//      if (emailSubject.value == contactInfoSubject.value.email &&
//          phoneSubject.value == contactInfoSubject.value.phoneNumber) {
//        print("Error same values");
//        return "ERROR_NOTHING_CHANGE";
//      }
//
//      ContactInfo newContactInfo = ContactInfo(
//        email: emailSubject.value,
//        phoneNumber: phoneSubject.value.replaceAll(RegExp(r'\D'), '').trim(),
//      );
//      contactInfoSubject.add(newContactInfo);
//
//      Firestore.instance
//          .collection('parameters')
//          .document('contactInfo')
//          .setData(newContactInfo.toJson());
//
//      print("SUCCESS");
//      return "SUCCESS";
//    } catch (error) {
//      print(error.toString());
//      return error;
//    }
//  }
//}
