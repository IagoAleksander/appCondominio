class FeedEventViews {
  String eventID;
  List<String> users;

  FeedEventViews({
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
    return FeedEventViews(
      eventID: parsedJson['eventID'],
      users: usersList,
    );
  }
}
