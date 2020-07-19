import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerCustom extends StatelessWidget {
  const TimePickerCustom({
    Key key,
    this.labelText,
    this.selectedTime,
    this.selectTime,
    this.showEmpty = true,
    this.isError = false,
  }) : super(key: key);

  final String labelText;
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> selectTime;
  final bool showEmpty;
  final bool isError;

  Future<void> _selectDate(BuildContext context) async {
    TimeOfDay _initialTime = selectedTime ?? TimeOfDay.now();

    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _initialTime,
    );
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  String _formatDate() {
    if (_willShowLabel()) {
      if (labelText != null && labelText.isNotEmpty) {
        return this.labelText;
      } else {
        return "__:__";
      }
    } else {
      return new DateFormat('HH:mm').format(
          DateUtils.getDayFirstMinute(DateTime.now()).add(Duration(
                  hours: selectedTime.hour, minutes: selectedTime.minute) ??
              DateTime.now()));
    }
  }

  bool _willShowLabel() {
    return selectedTime == null && showEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
        brightness: Brightness.dark,
        accentColor: ColorsRes.accentColor,
        cardColor: ColorsRes.primaryColor,
        primarySwatch: MaterialColor(0xFF5AB9B6, ColorsRes.color),
        backgroundColor: ColorsRes.primaryColorLight,
        dialogBackgroundColor: ColorsRes.primaryColor,
      ),
      child: Builder(builder: (context) {
        return InputDecorator(
          decoration: InputDecoration(
            hintText: labelText,
            hintStyle: TextStyle(fontSize: 5),
            isDense: false,
          ),
          child: GestureDetector(
            onTap: () {
              _selectDate(context);
            },
            child: Container(
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: isError ? Colors.deepOrange : Colors.white24),
                  borderRadius: BorderRadius.circular(90.0),
                  color: Colors.grey[200]),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
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
                      Icons.access_time,
                      size: 17,
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
