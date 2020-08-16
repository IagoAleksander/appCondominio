import 'package:app_condominio/models/meeting_survey_answer.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';

class MeetingSurvey {
  String id;
  List<MeetingSurveyQuestion> questions;
  List<MeetingSurveyAnswer> answers;

  MeetingSurvey({
    this.questions,
    this.answers,
  });

  Map<String, dynamic> toJson() => {
        'questions': questions,
        'answers': answers,
      };

  static fromJson(Map<String, dynamic> parsedJson) {
    return MeetingSurvey(
      questions: parsedJson['questions'],
      answers: parsedJson['answers'],
    );
  }
}
