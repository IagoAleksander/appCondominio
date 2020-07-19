import 'package:app_condominio/common/mobx/slidingPanelController.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/feed_event_views.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventID;

  EventDetailsScreen(this.eventID);

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  PanelController controller = PanelController();
  SlidingPanelController slidingPanelController = SlidingPanelController();

  @override
  void initState() {
    super.initState();
    if (!globals.isUserAdmin) addViewerToEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Evento",
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
              .collection('feedEvents')
              .document(widget.eventID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return LoadingIndicator();
            }

            FeedEvent event = FeedEvent.fromJson(snapshot.data.data);
            event.id = widget.eventID;

            return globals.isUserAdmin
                ? SlidingUpPanel(
                    controller: controller,
                    onPanelOpened: () =>
                        slidingPanelController.setFilterIsOpen(true),
                    onPanelClosed: () =>
                        slidingPanelController.setFilterIsOpen(false),
                    color: ColorsRes.primaryColor,
                    minHeight: 80,
                    maxHeight: 270,
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
                                    Constants.eventVisualizationRoute,
                                    arguments: widget.eventID,
                                  );
                                },
                                isMin: false,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 56),
                              child: StandardButton(
                                label: "Editar evento",
                                prefixIcon: Icons.edit,
                                backgroundColor: ColorsRes.primaryColorLight,
                                onTapFunction: () {
                                  Navigator.pushNamed(
                                    context,
                                    Constants.registerEventRoute,
                                    arguments: event,
                                  );
                                },
                                isMin: false,
                              ),
                            ),
                            StreamBuilder(
                                stream: Firestore.instance
                                    .collection('eventReports')
                                    .document(widget.eventID)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      !snapshot.hasData) {
                                    return LoadingIndicator();
                                  }
                                  if (snapshot.data.data == null) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 56),
                                      child: StandardButton(
                                        label: "Criar relatório",
                                        prefixIcon: Icons.format_align_justify,
                                        backgroundColor:
                                            ColorsRes.primaryColorLight,
                                        onTapFunction: () {
                                          Navigator.pushNamed(
                                            context,
                                            Constants.createEventReportRoute,
                                            arguments: [widget.eventID, null],
                                          );
                                        },
                                        isMin: false,
                                      ),
                                    );
                                  }

                                  EventReport report =
                                      EventReport.fromJson(snapshot.data.data);
                                  report.id = widget.eventID;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 56),
                                    child: StandardButton(
                                      label: "Ver relatório",
                                      prefixIcon: Icons.format_align_justify,
                                      backgroundColor:
                                          ColorsRes.primaryColorLight,
                                      onTapFunction: () {
                                        Navigator.pushNamed(
                                          context,
                                          Constants.eventReportRoute,
                                          arguments: report.id,
                                        );
                                      },
                                      isMin: false,
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ],
                    ),
                    body: eventDetailsWidget(event),
                  )
                : eventDetailsWidget(event);
          }),
    );
  }

  Widget eventDetailsWidget(FeedEvent event) {
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
                            DateUtils.getFormattedDate(event.eventDateInMillis),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      event.imageUrl != null
                          ? Container(
                              padding: EdgeInsets.all(12.0),
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
                                  CachedNetworkImage(
                                    height: 180,
                                    imageUrl: event.imageUrl,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.error,
                                      color: Colors.grey[500],
                                    ),
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
                                event.title,
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
                              event.description,
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
                        .collection('eventReports')
                        .document(widget.eventID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData) {
                        return LoadingIndicator();
                      }
                      if (snapshot.data.data == null) {
                        return Container();
                      }

                      EventReport report =
                          EventReport.fromJson(snapshot.data.data);
                      report.id = widget.eventID;
                      return Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          left: 56,
                          bottom: 12,
                          right: 56,
                        ),
                        child: StandardButton(
                          label: "Ver relatório",
                          prefixIcon: Icons.format_align_justify,
                          backgroundColor: ColorsRes.primaryColorLight,
                          onTapFunction: () {
                            Navigator.pushNamed(
                              context,
                              Constants.eventReportRoute,
                              arguments: report.id,
                            );
                          },
                          isMin: false,
                        ),
                      );
                    }),
          ],
        ),
      );
    });
  }

  addViewerToEvent() async {
    List<String> users = new List<String>();

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('feedEventsViews')
        .document(widget.eventID)
        .get();

    if (snapshot.data != null) {
      FeedEventViews feedEventViews = FeedEventViews.fromJson(snapshot.data);
      users.addAll(feedEventViews.users);
    }
    if (!users.contains(globals.firebaseCurrentUser.uid))
      users.add(globals.firebaseCurrentUser.uid);

    FeedEventViews newFeedEventViews = FeedEventViews(
      eventID: widget.eventID,
      users: users,
    );

    Firestore.instance
        .collection('feedEventsViews')
        .document(widget.eventID)
        .setData(newFeedEventViews.toJson());
  }
}
