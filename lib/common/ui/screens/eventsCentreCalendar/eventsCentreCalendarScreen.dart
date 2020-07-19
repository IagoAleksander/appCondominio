import 'dart:async';

import 'package:app_condominio/common/bloc/EventsCentreCalendarBloc.dart';
import 'package:app_condominio/common/ui/screens/eventsCentreCalendar/widgets/ScheduledEventCard.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/models/scheduled_event.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/string_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsCentreCalendarScreen extends StatefulWidget {
  @override
  _EventsCentreCalendarScreenState createState() =>
      _EventsCentreCalendarScreenState();
}

class _EventsCentreCalendarScreenState
    extends State<EventsCentreCalendarScreen> {
  EventsCentreCalendarBloc bloc;
  CalendarController _calendarController;
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    bloc = EventsCentreCalendarBloc();
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainGlobalKey,
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          "Centro de Eventos",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('scheduled_events')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      bloc.updateEventList(snapshot.data.documents);
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: ColorsRes.primaryColorLight,
                          child: TableCalendar(
                            startDay: bloc.startDate,
                            endDay: bloc.endDate.subtract(Duration(days: 1)),
                            calendarController: _calendarController,
                            locale: 'pt_BR',
                            events: bloc.eventsList,
                            initialSelectedDay: DateTime.now(),
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              weekdayStyle:
                                  TextStyle().copyWith(color: Colors.white),
                              weekendStyle:
                                  TextStyle().copyWith(color: Colors.white),
                              holidayStyle:
                                  TextStyle().copyWith(color: Colors.white),
                              outsideStyle:
                                  TextStyle().copyWith(color: Colors.grey[700]),
                              outsideWeekendStyle:
                                  TextStyle().copyWith(color: Colors.grey[700]),
                              unavailableStyle:
                                  TextStyle().copyWith(color: Colors.grey[700]),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle:
                                  TextStyle().copyWith(color: Colors.white),
                              weekdayStyle:
                                  TextStyle().copyWith(color: Colors.white),
                            ),
                            headerStyle: HeaderStyle(
                              centerHeaderTitle: true,
                              formatButtonVisible: false,
                              titleTextStyle: TextStyle(
                                color: Colors.white,
                              ),
                              leftChevronIcon: Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                            ),
                            onDaySelected: (day, events) {
                              bloc.changeSelectedDay(day);
                              bloc.changeEvents(events);
                            },
                            onUnavailableDaySelected: () => Dialogs.showToast(
                                context,
                                "Data fora do período válido para seleção"),
                            builders: CalendarBuilders(
                              selectedDayBuilder: (context, date, _) {
                                return _buildDay(
                                    date: date,
                                    isSelected: true,
                                    isToday: false,
                                    isOutside: false);
                              },
                              outsideDayBuilder: (context, date, events) {
                                return _buildDay(
                                    date: date,
                                    isSelected: false,
                                    isToday: false,
                                    isOutside: true);
                              },
                              outsideWeekendDayBuilder:
                                  (context, date, events) {
                                return _buildDay(
                                    date: date,
                                    isSelected: false,
                                    isToday: false,
                                    isOutside: true);
                              },
                              dayBuilder: (context, date, events) {
                                return _buildDay(
                                    date: date,
                                    isSelected: false,
                                    isToday: false,
                                    isOutside: false);
                              },
                              todayDayBuilder: (context, date, _) {
                                return _buildDay(
                                    date: date,
                                    isSelected: false,
                                    isToday: true,
                                    isOutside: false);
                              },
                              markersBuilder:
                                  (context, date, events, holidays) {
                                final children = <Widget>[];

                                children.add(
                                  Positioned(
                                    bottom: 8,
                                    child: _buildEventsMarker(date, events),
                                  ),
                                );

                                return children;
                              },
                            ),
                          ),
                        ),
                        StreamBuilder(
                            stream: bloc.streamEvents,
                            builder: (context, snapshot) {
                              if (snapshot.data == null) {
                                return Container();
                              }
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Center(
                                      child: Text(
                                        StringUtils.formatDate(
                                            bloc.selectedDay),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                  ),
                                  _buildEventList(snapshot.data),
                                ],
                              );
                            }),
                      ],
                    );
                  }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDay(
      {@required DateTime date,
      @required bool isSelected,
      @required bool isToday,
      @required bool isOutside}) {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(color: Colors.white),
              color: ColorsRes.primaryColor,
            )
          : null,
      color: isToday ? ColorsRes.primaryColor : null,
      width: 100,
      height: 100,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Text(
            '${date.day}',
            style: TextStyle().copyWith(
              fontSize: 16.0,
              color: isOutside ? Colors.grey[600] : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    ScheduledEvent eventMorning =
        bloc.getEventForPeriod(events, Period.morning);
    ScheduledEvent eventEvening =
        bloc.getEventForPeriod(events, Period.evening);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: eventMorning.status == ScheduleStatus.available
                  ? Colors.green
                  : eventMorning.status == ScheduleStatus.scheduled
                      ? Colors.redAccent
                      : Colors.orange),
          width: 8.0,
          height: 8.0,
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: eventEvening.status == ScheduleStatus.available
                  ? Colors.green
                  : eventEvening.status == ScheduleStatus.scheduled
                      ? Colors.redAccent
                      : Colors.orange),
          width: 8.0,
          height: 8.0,
        ),
      ],
    );
  }

  Widget _buildEventList(List events) {
    ScheduledEvent eventMorning =
        bloc.getEventForPeriod(events, Period.morning);
    ScheduledEvent eventEvening =
        bloc.getEventForPeriod(events, Period.evening);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScheduledEventCard(
          event: eventMorning,
          scheduleFunction: () =>
              showScheduleEventDialog(context, bloc, eventMorning),
          cancelFunction: () => showCancelEventDialog(context, bloc, eventMorning),
        ),
        ScheduledEventCard(
          event: eventEvening,
          scheduleFunction: () =>
              showScheduleEventDialog(context, bloc, eventEvening),
          cancelFunction: () => showCancelEventDialog(context, bloc, eventEvening),
        ),
      ],
    );
  }

  static showScheduleEventDialog(BuildContext context,
      EventsCentreCalendarBloc bloc, ScheduledEvent event) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Agendar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Dialogs.showLoadingDialog(
          context,
          "Agendando salão de festas",
        );

        bloc.scheduleEvent(event);

        Timer(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Ao agendar uma data, ela fica travada por 24h e uma cobrança "
            "automática será gerada. Caso não haja confirmação do pagamento "
            "nesse período, ela é liberada novamente.\nÉ possível desistir do "
            "agendamento até uma semana antes da data escolhida, com "
            "reembolso de 50%. Depois disso não há devolução do valor.",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "Você tem certeza de que deseja agendar o "
            "${ScheduledEvent.periodToString(event.period).toLowerCase()} "
            "do dia ${StringUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(event.scheduledDate)).toLowerCase()} ?",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showCancelEventDialog(BuildContext context,
      EventsCentreCalendarBloc bloc, ScheduledEvent event) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Remover agendamento",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Dialogs.showLoadingDialog(
          context,
          "Cancelando agendamento",
        );

        bloc.cancelEvent(event);

        Timer(Duration(milliseconds: 1500), () {
          Navigator.pop(context);
          Navigator.pop(context);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja remover o agendamento do "
        "${ScheduledEvent.periodToString(event.period).toLowerCase()} "
        "do dia ${StringUtils.formatDate(DateTime.fromMillisecondsSinceEpoch(event.scheduledDate)).toLowerCase()} ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
