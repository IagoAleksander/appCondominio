import 'package:app_condominio/models/scheduled_event.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScheduledEventCard extends StatelessWidget {
  final ScheduledEvent event;
  final Function scheduleFunction;
  final Function cancelFunction;

  ScheduledEventCard({
    @required this.event,
    @required this.scheduleFunction,
    @required this.cancelFunction,
  });

  @override
  Widget build(BuildContext context) {

    DateTime actualDateToCompare = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(hours: 1));
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: ColorsRes.cardBackgroundColor),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 12.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        right:
                            new BorderSide(width: 1.0, color: Colors.white24))),
                child: Icon(
                  event.period == Period.morning
                      ? Icons.wb_sunny
                      : Icons.highlight,
                  color: event.status == ScheduleStatus.available
                      ? ColorsRes.accentColor
                      : event.status == ScheduleStatus.scheduled
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                  size: 30,
                ),
              ),
            ],
          ),
          title: Text(
            ScheduledEvent.scheduleStatusToString(event.status),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 6,
              ),
              Text(ScheduledEvent.periodToString(event.period),
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.white)),
            ],
          ),
          trailing:
              event.scheduledDate > actualDateToCompare.millisecondsSinceEpoch &&
                      (event.status == ScheduleStatus.available ||
                          event.userId == globals.firebaseCurrentUser.uid)
                  ? Stack(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: event.status == ScheduleStatus.available
                                  ? ColorsRes.accentColor
                                  : Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 8.0, left: 10.0),
                                  child: Text(
                                    event.status == ScheduleStatus.available
                                        ? "Agendar"
                                        : "Cancelar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_right,
                                    color: Colors.white, size: 30.0),
                              ],
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.all(
                                  const Radius.circular(10.0),
                                ),
                                onTap: event.status == ScheduleStatus.available
                                    ? scheduleFunction
                                    : cancelFunction,
                              )),
                        ),
                      ],
                    )
                  : null,
        ),
      ),
    );
  }
}
