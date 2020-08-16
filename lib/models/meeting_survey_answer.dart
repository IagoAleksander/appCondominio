class MeetingSurveyAnswer {
  String answerID;
  Map<String, List<String>> chosen;

  MeetingSurveyAnswer({
    this.answerID,
    this.chosen,
  });

  Map<String, dynamic> toJson() => {
        'chosen': chosen,
      };

  static fromJson(String documentID, Map<String, dynamic> parsedJson) {
    Map<String, List<String>> chosenList = Map<String, List<String>>();
    parsedJson['chosen'].forEach((key, values) {
      List<String> userIDs = new List<String>();
      for (dynamic userID in values) {
        userIDs.add(userID as String);
      }
      chosenList.putIfAbsent(key, () => userIDs);
    });
    return MeetingSurveyAnswer(
      answerID: documentID,
      chosen: chosenList,
    );
  }
}
