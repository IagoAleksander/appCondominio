import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:mobx/mobx.dart';

part 'createSurveyController.g.dart';

class CreateSurveyController = _CreateSurveyControllerBase
    with _$CreateSurveyController;

enum EnumState {
  IDLE,
  LOADING,
}

abstract class _CreateSurveyControllerBase with Store {

  @observable
  ObservableList<MeetingSurveyQuestion> questions =
      ObservableList<MeetingSurveyQuestion>();

  @observable
  EnumState state = EnumState.IDLE;

  @observable
  int selectedQuestion = -1;

  @observable
  int selectedChoice = -1;

  @action
  setSelectedQuestion(int index) {
    selectedQuestion = index;
  }

  @action
  setSelectedChoice(int index) {
    selectedChoice = index;
  }

  @action
  addQuestion(MeetingSurveyQuestion question) {
    questions.add(question);
  }

  @action
  updateQuestions(int index, MeetingSurveyQuestion question) {
    selectedQuestion = index;
  }
}
