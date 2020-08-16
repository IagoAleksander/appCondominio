class MeetingSurveyQuestion {
  String questionID;
  String title;
  List<String> choices = List<String>();

  MeetingSurveyQuestion({
    this.questionID,
    this.title,
    this.choices,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'choices': choices,
      };

  static fromJson(String documentID, Map<String, dynamic> parsedJson) {
    List<String> choicesList = List<String>();
    for (dynamic val in parsedJson['choices']) {
      choicesList.add(val as String);
    }
    return MeetingSurveyQuestion(
      questionID: documentID,
      title: parsedJson['title'],
      choices: choicesList,
    );
  }
}
