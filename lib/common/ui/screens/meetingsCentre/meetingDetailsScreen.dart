import 'package:app_condominio/common/mobx/slidingPanelController.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/feed_event_views.dart';
import 'package:app_condominio/models/meeting.dart';
import 'package:app_condominio/models/meeting_survey.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final String meetingID;
  final String videoID;

  MeetingDetailsScreen(this.meetingID, this.videoID);

  @override
  _MeetingDetailsScreenState createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  PanelController controller = PanelController();
  SlidingPanelController slidingPanelController = SlidingPanelController();
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.videoID != null && widget.videoID.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.videoID,
        flags: YoutubePlayerFlags(
          autoPlay: false,
        ),
      );
    }
    if (!globals.isUserAdmin) addViewerToMeeting();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller != null) {
      return YoutubePlayerBuilder(
        onExitFullScreen: () {
          _controller.pause();
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return baseScreen(player);
        },
      );
    } else {
      return baseScreen(null);
    }
  }

  Widget baseScreen(Widget player) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reunião",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      backgroundColor: ColorsRes.primaryColor,
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('meetings')
            .document(widget.meetingID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingIndicator();
          }

          Meeting meeting = Meeting.fromJson(snapshot.data.data);
          meeting.id = widget.meetingID;

          return globals.isUserAdmin
              ? StreamBuilder(
                  stream: Firestore.instance
                      .collection('meetingSurveys')
                      .document(widget.meetingID)
                      .collection("questions")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    return SlidingUpPanel(
                      controller: controller,
                      onPanelOpened: () =>
                          slidingPanelController.setFilterIsOpen(true),
                      onPanelClosed: () =>
                          slidingPanelController.setFilterIsOpen(false),
                      color: ColorsRes.primaryColor,
                      minHeight: 80,
                      maxHeight: snapshot.data.documents == null ||
                              snapshot.data.documents.isEmpty
                          ? 280
                          : 330,
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
                                  suffixIcon:
                                      slidingPanelController.filterIsOpen
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_up,
                                  backgroundColor:
                                      slidingPanelController.filterIsOpen
                                          ? ColorsRes.primaryColor
                                          : ColorsRes.primaryColorLight,
                                  onTapFunction: () async {
                                    if (controller.isPanelOpen) {
                                      controller.close();
                                      slidingPanelController
                                          .setFilterIsOpen(false);
                                    } else {
                                      controller.open();
                                      slidingPanelController
                                          .setFilterIsOpen(true);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 56),
                                child: StandardButton(
                                  label: "Visualizações",
                                  prefixIcon: Icons.remove_red_eye,
                                  backgroundColor: ColorsRes.primaryColorLight,
                                  onTapFunction: () {
                                    Navigator.pushNamed(
                                      context,
                                      Constants.meetingVisualizationRoute,
                                      arguments: widget.meetingID,
                                    );
                                  },
                                  isMin: false,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 56),
                                child: StandardButton(
                                  label: "Editar reunião",
                                  prefixIcon: Icons.edit,
                                  backgroundColor: ColorsRes.primaryColorLight,
                                  onTapFunction: () {
                                    Navigator.pushNamed(
                                      context,
                                      Constants.registerMeetingRoute,
                                      arguments: meeting,
                                    );
                                  },
                                  isMin: false,
                                ),
                              ),
                              snapshot.data.documents == null ||
                                      snapshot.data.documents.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 56),
                                      child: StandardButton(
                                        label: "Criar questionário",
                                        prefixIcon: Icons.format_align_justify,
                                        backgroundColor:
                                            ColorsRes.primaryColorLight,
                                        onTapFunction: () {
                                          Navigator.pushNamed(
                                            context,
                                            Constants.createSurveyRoute,
                                            arguments: [widget.meetingID, null],
                                          );
                                        },
                                        isMin: false,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 56),
                                          child: StandardButton(
                                            label: "Editar questionário",
                                            prefixIcon:
                                                Icons.format_align_justify,
                                            backgroundColor:
                                                ColorsRes.primaryColorLight,
                                            onTapFunction: () {
                                              List<MeetingSurveyQuestion>
                                                  questions = new List<
                                                      MeetingSurveyQuestion>();
                                              for (dynamic document
                                                  in snapshot.data.documents) {
                                                questions.add(
                                                    MeetingSurveyQuestion
                                                        .fromJson(
                                                            document.documentID,
                                                            document.data));
                                              }
                                              Navigator.pushNamed(
                                                context,
                                                Constants.createSurveyRoute,
                                                arguments: [
                                                  widget.meetingID,
                                                  questions
                                                ],
                                              );
                                            },
                                            isMin: false,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0, horizontal: 56),
                                          child: StandardButton(
                                            label: "Ver respostas",
                                            prefixIcon:
                                                Icons.format_align_justify,
                                            backgroundColor:
                                                ColorsRes.primaryColorLight,
                                            onTapFunction: () {
                                              Navigator.pushNamed(
                                                context,
                                                Constants.resultSurveyRoute,
                                                arguments: widget.meetingID,
                                              );
                                            },
                                            isMin: false,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                      body: meetingDetailsWidget(meeting, player),
                    );
                  },
                )
              : meetingDetailsWidget(meeting, player);
        },
      ),
    );
  }

  Widget meetingDetailsWidget(Meeting meeting, Widget player) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: globals.isUserAdmin
                  ? const EdgeInsets.only(
                      left: 4.0,
                      top: 4.0,
                      right: 4.0,
                      bottom: 164.0,
                    )
                  : EdgeInsets.all(4.0),
              child: Card(
                color: ColorsRes.cardBackgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Text(
                            DateUtils.getFormattedDate(
                                meeting.meetingDateInMillis),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      player != null
                          ? Container(
                              padding: EdgeInsets.all(4.0),
                              decoration: new BoxDecoration(
                                  border: new Border.all(color: Colors.white24),
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: ColorsRes.primaryColorLight),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Flexible(
                                    child: player,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                meeting.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Text(
                              meeting.description,
                              textAlign: TextAlign.justify,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            globals.isUserAdmin
                ? Container()
                : StreamBuilder(
                    stream: Firestore.instance
                        .collection('meetingSurveys')
                        .document(widget.meetingID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData ||
                          snapshot.data.data == null) {
                        return Container();
                      }
                      List participatingUsers =
                          snapshot.data.data["participatingUsers"];
                      if (participatingUsers != null &&
                          participatingUsers
                              .contains(globals.firebaseCurrentUser.uid)) {
                        return Container();
                      }
                      return StreamBuilder(
                        stream: Firestore.instance
                            .collection('meetingSurveys')
                            .document(widget.meetingID)
                            .collection("questions")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              !snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data.documents.isEmpty) {
                            return Container();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 4.0,
                              left: 56,
                              bottom: 12,
                              right: 56,
                            ),
                            child: StandardButton(
                              label: "Ver questionário",
                              prefixIcon: Icons.format_align_justify,
                              backgroundColor: ColorsRes.primaryColorLight,
                              onTapFunction: () {
                                List<MeetingSurveyQuestion> questions =
                                    new List<MeetingSurveyQuestion>();
                                for (dynamic document
                                    in snapshot.data.documents) {
                                  questions.add(MeetingSurveyQuestion.fromJson(
                                      document.documentID, document.data));
                                }
                                Navigator.pushNamed(
                                  context,
                                  Constants.answerSurveyRoute,
                                  arguments: [widget.meetingID, questions],
                                );
                              },
                              isMin: false,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      );
    });
  }

  addViewerToMeeting() async {
    List<String> users = new List<String>();

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('meetingsViews')
        .document(widget.meetingID)
        .get();

    if (snapshot.data != null) {
      FeedEventViews feedEventViews = FeedEventViews.fromJson(snapshot.data);
      users.addAll(feedEventViews.users);
    }
    if (!users.contains(globals.firebaseCurrentUser.uid))
      users.add(globals.firebaseCurrentUser.uid);

    FeedEventViews newFeedEventViews = FeedEventViews(
      eventID: widget.meetingID,
      users: users,
    );

    Firestore.instance
        .collection('meetingsViews')
        .document(widget.meetingID)
        .setData(newFeedEventViews.toJson());
  }

  @override
  void dispose() {
    if (_controller != null) _controller.dispose();
    super.dispose();
  }
}
