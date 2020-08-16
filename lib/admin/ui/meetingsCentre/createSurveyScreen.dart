import 'dart:async';

import 'package:app_condominio/common/mobx/slidingPanelController.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/common/ui/widgets/text_form_field_custom.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// ignore: must_be_immutable
class CreateSurveyScreen extends StatefulWidget {
  final String eventID;
  List<MeetingSurveyQuestion> questions;

  CreateSurveyScreen(this.eventID, this.questions);

  @override
  _CreateSurveyScreenState createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  PanelController controller = PanelController();
  SlidingPanelController slidingPanelController = SlidingPanelController();
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedQuestion = -1;
  int selectedChoice = -1;
  bool isCreatingNew = false;
  bool isValidating = false;
  bool errorLessThanMinimalQuestions = false;
  bool errorLessThanMinimalChoices = false;

  @override
  void initState() {
    if (widget.questions == null) {
      isCreatingNew = true;
      widget.questions = List<MeetingSurveyQuestion>();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsRes.primaryColor,
      appBar: AppBar(
        title: Text(
          isCreatingNew ? "Criação de Questionário" : "Edição de Questionário",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      body: SlidingUpPanel(
        controller: controller,
        onPanelOpened: () => slidingPanelController.setFilterIsOpen(true),
        onPanelClosed: () => slidingPanelController.setFilterIsOpen(false),
        color: ColorsRes.primaryColor,
        minHeight: 80,
        maxHeight: selectedQuestion != -1 ? 270 : 160,
        panel: Column(
          children: [
            Container(
              color: ColorsRes.primaryColorLight,
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Observer(
                builder: (_) {
                  return StandardButton(
                    label: slidingPanelController.filterIsOpen
                        ? "Esconder opções"
                        : "Mostrar opções",
                    suffixIcon: slidingPanelController.filterIsOpen
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    backgroundColor: slidingPanelController.filterIsOpen
                        ? ColorsRes.primaryColor
                        : ColorsRes.primaryColorLight,
                    onTapFunction: () async {
                      if (controller.isPanelOpen) {
                        controller.close();
                        slidingPanelController.setFilterIsOpen(false);
                      } else {
                        controller.open();
                        slidingPanelController.setFilterIsOpen(true);
                      }
                    },
                  );
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                selectedQuestion != -1 && selectedChoice == -1
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 56),
                            child: StandardButton(
                              label: "Editar pergunta",
                              prefixIcon: Icons.edit,
                              backgroundColor: ColorsRes.primaryColorLight,
                              onTapFunction: () =>
                                  showEditQuestionDialog(context),
                              isMin: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 56),
                            child: StandardButton(
                              label: "Remover pergunta",
                              prefixIcon: Icons.close,
                              backgroundColor: ColorsRes.primaryColorLight,
                              onTapFunction: () =>
                                  showDeleteQuestionDialog(context),
                              isMin: false,
                            ),
                          ),
                        ],
                      )
                    : selectedQuestion != -1 && selectedChoice != -1
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 56),
                                child: StandardButton(
                                  label: "Editar alternativa",
                                  prefixIcon: Icons.edit,
                                  backgroundColor: ColorsRes.primaryColorLight,
                                  onTapFunction: () =>
                                      showEditChoiceDialog(context),
                                  isMin: false,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 56),
                                child: StandardButton(
                                  label: "Remover alternativa",
                                  prefixIcon: Icons.close,
                                  backgroundColor: ColorsRes.primaryColorLight,
                                  onTapFunction: () =>
                                      showDeleteChoiceDialog(context),
                                  isMin: false,
                                ),
                              ),
                            ],
                          )
                        : Container(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 56),
                  child: StandardButton(
                    label:
                        isCreatingNew ? "Concluir criação" : "Concluir edição",
                    prefixIcon: Icons.format_align_justify,
                    backgroundColor: ColorsRes.primaryColorLight,
                    onTapFunction: () {
                      bool isError = false;
                      errorLessThanMinimalQuestions = false;
                      errorLessThanMinimalChoices = false;
                      if (widget.questions.isEmpty) {
                        isError = true;
                        errorLessThanMinimalQuestions = true;
                      } else {
                        for (MeetingSurveyQuestion question
                            in widget.questions) {
                          if (question.title.isEmpty) {
                            isError = true;
                          }
                          if (question.choices == null ||
                              question.choices.length < 2) {
                            isError = true;
                            errorLessThanMinimalChoices = true;
                          } else {
                            for (String answer in question.choices) {
                              if (answer.isEmpty) {
                                isError = true;
                              }
                            }
                          }
                        }
                      }
                      if (isError) {
                        Dialogs.showAlertDialog(
                          context,
                          errorLessThanMinimalQuestions
                              ? "Por favor, adicione ao menos uma pergunta ao questionário"
                              : errorLessThanMinimalChoices
                                  ? "Por favor, adicione ao menos duas alternativas para cada pergunta"
                                  : "Por favor, preencha corretamente as informações",
                          onPressed: () {
                            Navigator.pop(context);
                            setState(
                              () {
                                isValidating = true;
                              },
                            );
                          },
                        );
                      } else {
//                        save   eventId widget.questions
                        isCreatingNew? sendQuestion() : showEditSurveyConfirmationDialog();
                      }
//                      Navigator.pushNamed(
//                        context,
//                        Constants.createSurveyRoute,
//                        arguments: [
//                          widget.meetingID,
//                          null
//                        ],
//                      );
                    },
                    isMin: false,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraint) {
            return Padding(
              padding: EdgeInsets.only(bottom: 160.0),
              child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: false,
                itemCount: widget.questions.length + 1,
                itemBuilder: (_, int index) {
                  return Card(
                    color: Colors.white,
                    child: index == widget.questions.length
                        ? GestureDetector(
                            onTap: () => setState(() {
                              widget.questions.add(MeetingSurveyQuestion(
                                  title: "", choices: List<String>()));
                            }),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Expanded(
                                child: Text(
                                  "Adicionar pergunta",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(
                                    () {
                                      selectedQuestion = index;
                                      selectedChoice = -1;
                                      controller.open();
                                    },
                                  ),
                                  child: Container(
                                    decoration: selectedQuestion == index &&
                                            selectedChoice == -1
                                        ? new BoxDecoration(
                                            border: new Border.all(
                                                color: ColorsRes
                                                    .cardBackgroundColor),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            color: ColorsRes.accentColor)
                                        : new BoxDecoration(
                                            color: Colors.transparent),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            widget.questions[index].title
                                                    .isEmpty
                                                ? "Editar pergunta"
                                                : widget.questions[index].title,
                                            style: TextStyle(
                                                color: selectedQuestion ==
                                                            index &&
                                                        selectedChoice == -1
                                                    ? Colors.white
                                                    : widget.questions[index]
                                                            .title.isEmpty
                                                        ? isValidating
                                                            ? Colors.red
                                                            : Colors.grey
                                                        : Colors.black,
                                                fontSize: 14),
                                          ),
                                        )),
                                  ),
                                ),
                                ListView.builder(
                                  padding: EdgeInsets.only(
                                      left: 24.0, top: 8.0, bottom: 8.0),
                                  reverse: false,
                                  itemCount:
                                      widget.questions[index].choices.length +
                                          1,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (_, int index2) {
                                    return index2 ==
                                            widget
                                                .questions[index].choices.length
                                        ? GestureDetector(
                                            onTap: () => setState(() {
                                              widget.questions[index].choices
                                                  .add("");
                                            }),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                    "Adicionar alternativa"),
                                              ),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () => setState(
                                              () {
                                                selectedQuestion = index;
                                                selectedChoice = index2;
                                                controller.open();
                                              },
                                            ),
                                            child: Container(
                                              decoration: selectedQuestion ==
                                                          index &&
                                                      selectedChoice == index2
                                                  ? new BoxDecoration(
                                                      border: new Border.all(
                                                          color: ColorsRes
                                                              .cardBackgroundColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                      color:
                                                          ColorsRes.accentColor)
                                                  : new BoxDecoration(
                                                      color:
                                                          Colors.transparent),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0,
                                                    left: 6.0,
                                                    bottom: 6.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        widget
                                                                .questions[
                                                                    index]
                                                                .choices[index2]
                                                                .isEmpty
                                                            ? " ○ Editar alternativa"
                                                            : " ○ " +
                                                                widget
                                                                    .questions[
                                                                        index]
                                                                    .choices[index2],
                                                        style: TextStyle(
                                                            color: selectedQuestion ==
                                                                        index &&
                                                                    selectedChoice ==
                                                                        index2
                                                                ? Colors.white
                                                                : widget
                                                                        .questions[
                                                                            index]
                                                                        .choices[
                                                                            index2]
                                                                        .isEmpty
                                                                    ? isValidating
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey
                                                                    : Colors
                                                                        .black,
                                                            fontSize: 14),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  showEditQuestionDialog(BuildContext context) async {
    TextEditingController _titleFieldController = TextEditingController(
        text: widget.questions.length > selectedQuestion &&
                widget.questions[selectedQuestion] != null &&
                widget.questions[selectedQuestion].title.isNotEmpty
            ? widget.questions[selectedQuestion].title
            : null);

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Editar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        widget.questions[selectedQuestion].title =
            _titleFieldController.text.trim();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edite o texto da pergunta selecionada",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 24,
          ),
          TextFormFieldCustom(
            maxLines: 7,
            minLines: 3,
            textInputType: TextInputType.multiline,
            controller: _titleFieldController,
            hintText: "Editar pergunta",
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteQuestionDialog(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Remover",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        setState(() {
          widget.questions.removeAt(selectedQuestion);
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja remover a pergunta ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showEditChoiceDialog(BuildContext context) async {
    TextEditingController _titleFieldController = TextEditingController(
        text: widget.questions.length > selectedQuestion &&
                widget.questions[selectedQuestion] != null &&
                widget.questions[selectedQuestion].choices != null &&
                widget.questions[selectedQuestion].choices.length >
                    selectedChoice &&
                widget.questions[selectedQuestion].choices[selectedChoice] !=
                    null &&
                widget.questions[selectedQuestion].choices[selectedChoice]
                    .isNotEmpty
            ? widget.questions[selectedQuestion].choices[selectedChoice]
            : null);

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Editar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        FocusScope.of(context).requestFocus(new FocusNode());
        widget.questions[selectedQuestion].choices[selectedChoice] =
            _titleFieldController.text.trim();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Edite o texto da alternativa selecionada",
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            height: 24,
          ),
          TextFormFieldCustom(
            maxLines: 7,
            minLines: 3,
            textInputType: TextInputType.multiline,
            controller: _titleFieldController,
            hintText: "Editar alternativa",
          ),
        ],
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteChoiceDialog(BuildContext context) async {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Remover",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        setState(() {
          widget.questions[selectedQuestion].choices.removeAt(selectedChoice);
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja remover a alternativa ?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showEditSurveyConfirmationDialog() async {

    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () => Navigator.pop(context),
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Continuar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () async {
        sendQuestion();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Você tem certeza de que deseja editar o questionário?\n\nTodas as respostas obtidas até o momento serão descartadas.",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  sendQuestion() async {
    Dialogs.showLoadingDialog(
      context,
      isCreatingNew ? "Criando questionário..." : "Atualizando questionário...",
    );
    try {
      if (!isCreatingNew) {
        await deleteAllPreviousSurveyInfoFromDatabase();
      }

      for (MeetingSurveyQuestion question in widget.questions) {
        Map<String, Object> chosen = Map<String, Object>();
        for (int i = 0; i < question.choices.length; i++) {
          chosen.putIfAbsent(i.toString(), () => []);
        }
        DocumentReference doc = await Firestore.instance
            .collection('meetingSurveys')
            .document(widget.eventID)
            .collection("questions")
            .add(question.toJson());
        Firestore.instance
            .collection('meetingSurveys')
            .document(widget.eventID)
            .collection('answers')
            .document(doc.documentID)
            .setData({"chosen": chosen});
      }
      Dialogs.showToast(
          _scaffoldKey.currentContext,
          isCreatingNew
              ? "Questionário criado com sucesso"
              : "Questionário atualizado com sucesso");
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    } catch (error) {
      print(error.toString());
      Dialogs.showToast(
          _scaffoldKey.currentContext,
          isCreatingNew
              ? "Erro na criação do questionário"
              : "Erro na edição do questionário");
    }
  }

  deleteAllPreviousSurveyInfoFromDatabase() async {
    await Firestore.instance
        .collection('meetingSurveys')
        .document(widget.eventID)
        .collection("questions")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
    await Firestore.instance
        .collection('meetingSurveys')
        .document(widget.eventID)
        .collection("answers")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
    Firestore.instance
        .collection('meetingSurveys')
        .document(widget.eventID)
        .setData({"participatingUsers": []});
  }
}
