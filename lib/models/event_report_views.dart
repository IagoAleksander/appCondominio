class EventReportViews {
  String eventID;
  List<String> users;

  EventReportViews({
    this.eventID,
    this.users,
  });

  Map<String, dynamic> toJson() => {
        'eventID': eventID,
        'users': users,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    List<String> usersList = List<String>();
    for (dynamic val in parsedJson['users']) {
      usersList.add(val as String);
    }
    return EventReportViews(
      eventID: parsedJson['eventID'],
      users: usersList,
    );
  }
}
