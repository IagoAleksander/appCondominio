import 'package:app_condominio/models/meeting_survey_answer.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobx/mobx.dart';
import 'package:app_condominio/utils/globals.dart' as globals;

part 'answerSurveyController.g.dart';

class AnswerSurveyController = _AnswerSurveyControllerBase
    with _$AnswerSurveyController;

enum EnumState {
  IDLE,
  SUCCESS,
  LOADING,
  ERROR_ALREADY_ANSWERED,
  ERROR_GENERIC,
}

abstract class _AnswerSurveyControllerBase with Store {
  @observable
  EnumState state = EnumState.IDLE;

  String meetingID;
  List<MeetingSurveyQuestion> questions;
  List<int> radioValues;

  @observable
  ObservableList<int> radioValuesObservable = ObservableList<int>();

  @observable
  bool needToValidate = false;

  initValues(String meetingID, List<MeetingSurveyQuestion> questionsList) {
    this.meetingID = meetingID;
    questions = questionsList;

    radioValues = List<int>(questionsList.length);
    radioValues.fillRange(0, questionsList.length, -1);

    radioValuesObservable.addAll(radioValues);
  }

  @action
  changeState(EnumState state) {
    this.state = state;
  }

  @action
  updateRadioValue(int index, int value) {
    radioValuesObservable[index] = value;
  }

  @action
  setNeedToValidate(bool needToValidate) {
    this.needToValidate = needToValidate;
  }

  sendAnswer() async {
    setNeedToValidate(true);
    try {
      if (radioValuesObservable.contains(-1)) {
        print("Error null values");
        return "ERROR";
      }

      changeState(EnumState.LOADING);

      final snapshotUsers = await Firestore.instance
          .collection('meetingSurveys')
          .document(meetingID)
          .get();

      List participatingUsers = snapshotUsers.data["participatingUsers"];
      if (participatingUsers == null || participatingUsers.isEmpty) {
        participatingUsers = List();

        final snapShot = await Firestore.instance
            .collection('meetingSurveys')
            .document(meetingID)
            .collection('answers')
            .getDocuments();

        List<MeetingSurveyAnswer> answers = List<MeetingSurveyAnswer>();
        for (int i = 0; i < snapShot.documents.length; i++) {
          DocumentSnapshot document = snapShot.documents[i];
          MeetingSurveyAnswer answer =
              MeetingSurveyAnswer.fromJson(document.documentID, document.data);
          if (!answer.chosen[radioValuesObservable[i].toString()]
              .contains(globals.firebaseCurrentUser.uid)) {
            answer.chosen[radioValuesObservable[i].toString()]
                .add(globals.firebaseCurrentUser.uid);
          }
          answers.add(answer);
        }

        for (MeetingSurveyAnswer answer in answers) {
          Firestore.instance
              .collection('meetingSurveys')
              .document(meetingID)
              .collection("answers")
              .document(answer.answerID)
              .setData({"chosen": answer.chosen});
        }

        if (!participatingUsers.contains(globals.firebaseCurrentUser.uid)) {
          participatingUsers.add(globals.firebaseCurrentUser.uid);

          Firestore.instance
              .collection('meetingSurveys')
              .document(meetingID)
              .updateData({"participatingUsers": participatingUsers});
        }
        print("SUCCESS");
        changeState(EnumState.SUCCESS);
      } else {
        print("Error user already answered");
        changeState(EnumState.ERROR_ALREADY_ANSWERED);
      }
    } catch (error) {
      print(error.toString());
      changeState(EnumState.ERROR_GENERIC);
    }
  }
}
