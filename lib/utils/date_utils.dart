import 'package:intl/intl.dart';

class DateUtils {
  static DateTime getDayFirstMinute(DateTime date) {
    DateTime newDate;

    newDate = date.subtract(
      Duration(
        hours: date.hour,
        minutes: date.minute,
        seconds: date.second,
        milliseconds: date.millisecond,
        microseconds: date.microsecond,
      ),
    );

    return newDate;
  }

  static DateTime getDayNoon(DateTime date) {
    DateTime newDate;

    newDate = getDayFirstMinute(date).add(
      Duration(
        hours: 12,
        minutes: 0,
        seconds: 0,
        milliseconds: 0,
        microseconds: 0,
      ),
    );

    return newDate;
  }

  static DateTime getDayLastMinute(DateTime date) {
    DateTime newDate;

    newDate = getDayFirstMinute(date).add(
      Duration(
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
        microseconds: 999,
      ),
    );

    return newDate;
  }

  static String getFormattedDate(int dateInMillis) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    final String formatted = formatter
        .format(DateTime.fromMillisecondsSinceEpoch(dateInMillis));
    return formatted;
  }

  static String getFormattedDaysFromDate(int dateInMillis) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formatted = formatter
        .format(DateTime.fromMillisecondsSinceEpoch(dateInMillis));
    return formatted;
  }

  static String getFormattedTimeFromDate(int dateInMillis) {
    final DateFormat formatter = DateFormat('HH:mm');
    final String formatted = formatter
        .format(DateTime.fromMillisecondsSinceEpoch(dateInMillis));
    return formatted;
  }

  static const int MAX_DATE = 5000000000000;
  static const int DAY_IN_MILLIS = 86400000;
}