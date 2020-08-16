import 'dart:async';

import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/models/meeting_survey_answer.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultSurveyScreen extends StatefulWidget {
  final String meetingID;

  ResultSurveyScreen(this.meetingID);

  @override
  _ResultSurveyScreenState createState() => _ResultSurveyScreenState();
}

class _ResultSurveyScreenState extends State<ResultSurveyScreen> {
  List<MeetingSurveyQuestion> questions = new List<MeetingSurveyQuestion>();
  List<MeetingSurveyAnswer> answers = new List<MeetingSurveyAnswer>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          "Questionário",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('meetingSurveys')
            .document(widget.meetingID)
            .collection("questions")
            .snapshots(),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: Firestore.instance
                .collection('meetingSurveys')
                .document(widget.meetingID)
                .collection("answers")
                .snapshots(),
            builder: (context, snapshot2) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot2.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData ||
                  !snapshot2.hasData) {
                return LoadingIndicator();
              }
              if (snapshot.data == null || snapshot2.data == null) {
                return Container();
              }

              questions.clear();
              for (dynamic document in snapshot.data.documents) {
                questions.add(MeetingSurveyQuestion.fromJson(
                    document.documentID, document.data));
              }
              answers.clear();
              for (dynamic document in snapshot2.data.documents) {
                answers.add(MeetingSurveyAnswer.fromJson(
                    document.documentID, document.data));
              }
              return LayoutBuilder(
                builder: (context, constraint) {
                  return SingleChildScrollView(
                    child: Container(
                      color: ColorsRes.primaryColor,
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                "Até o momento, o resultado do questionário é:",
                                textAlign: TextAlign.center,
                                style: new TextStyle(fontSize: 14.0),
                              ),
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              itemCount: questions.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return questionWidget(questions[index], index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget questionWidget(MeetingSurveyQuestion question, int groupValue) {
    MeetingSurveyAnswer answer;
    for (MeetingSurveyAnswer answerTemp in answers) {
      if (answerTemp.answerID == question.questionID) {
        answer = answerTemp;
        break;
      }
    }

    List<String> chosenIDSorted = List<String>();

    answer.chosen.forEach((k, v) {
      int maxLength = 0;
      String maxID;
      answer.chosen.forEach((key, values) {
        if (values.length >= maxLength && !chosenIDSorted.contains(key)) {
          maxLength = values.length;
          maxID = key;
        }
      });
      chosenIDSorted.add(maxID);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            question.title,
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: question.choices.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return resultSurveyOptionWidget(
                  question, answer, chosenIDSorted, index);
            },
          )
        ],
      ),
    );
  }

  Widget resultSurveyOptionWidget(MeetingSurveyQuestion question,
      MeetingSurveyAnswer answer, List<String> chosenIDSorted, int choiceID) {
    String chosenIdText = chosenIDSorted[choiceID];
    int chosenID = int.parse(chosenIdText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          child: Text(
            answer.chosen[chosenIdText].length.toString(),
            style: new TextStyle(fontSize: 14.0),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              question.choices[chosenID],
              style: new TextStyle(fontSize: 14.0),
            ),
          ),
        ),
      ],
    );
  }
}
