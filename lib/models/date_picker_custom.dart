import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerCustom extends StatelessWidget {
  const DatePickerCustom({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectDate,
    this.minDate,
    this.maxDate,
    this.showEmpty = true,
    this.darkMode = true,
    this.isError = false,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;
  final DateTime minDate;
  final DateTime maxDate;
  final bool showEmpty;
  final bool darkMode;
  final bool isError;

  Future<void> _selectDate(BuildContext context) async {
    DateTime _maxDate = maxDate ?? DateTime(2101);

    DateTime _initialDate =
        selectedDate ?? DateUtils.getDayFirstMinute(DateTime.now());
    _initialDate = _initialDate.isBefore(_maxDate)
        ? _initialDate
        : DateUtils.getDayFirstMinute(_maxDate);

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _initialDate,
        firstDate: minDate == null ? new DateTime(2020, 1) : minDate,
        lastDate: _maxDate,
        locale: Locale("pt"),
        initialEntryMode: DatePickerEntryMode.calendar);
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  String _formatDate() {
    if (_willShowLabel()) {
      if (labelText != null && labelText.isNotEmpty) {
        return this.labelText;
      } else {
        return "__/__/____";
      }
    } else {
      return new DateFormat('dd/MM/yyyy')
          .format(selectedDate ?? DateTime.now());
    }
  }

  bool _willShowLabel() {
    return selectedDate == null && showEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
        brightness: Brightness.dark,
        accentColor: ColorsRes.primaryColor,
        cardColor: ColorsRes.primaryColor,
        primarySwatch: MaterialColor(0xFF5AB9B6, ColorsRes.color),
        dialogBackgroundColor: ColorsRes.primaryColorLight,
      ),
      child: Builder(builder: (context) {
        return InputDecorator(
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: TextStyle(fontSize: 5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: darkMode ? 10 : 0,
            ),
            isDense: false,
          ),
          child: GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: darkMode
                ? Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _formatDate(),
                    style: _willShowLabel()
                        ? TextStyle(color: Colors.white70, fontSize: 16)
                        : TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 15,
                  color: Colors.white,
                ),
              ],
            )
                : Container(
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: isError ? Colors.deepOrange : Colors.white24),
                  borderRadius: BorderRadius.circular(90.0),
                  color: Colors.grey[200]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_formatDate(),
                        style: _willShowLabel()
                            ? TextStyle(
                            color: Colors.grey[600],
                            fontFamily: "WorkSansLight",
                            fontSize: 16.0)
                            : TextStyle(
                            color: Colors.grey[600],
                            fontFamily: "WorkSansLight",
                            fontSize: 16.0)),
                    Icon(
                      Icons.calendar_today,
                      size: 15,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
