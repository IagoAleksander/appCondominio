import 'package:app_condominio/common/mobx/slidingPanelController.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/event_report_views.dart';
import 'package:app_condominio/models/feed_event_views.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class EventReportScreen extends StatefulWidget {
  final String eventID;

  EventReportScreen(this.eventID);

  @override
  _EventReportScreenState createState() => _EventReportScreenState();
}

class _EventReportScreenState extends State<EventReportScreen> {
  PanelController controller = PanelController();
  SlidingPanelController slidingPanelController = SlidingPanelController();

  @override
  void initState() {
    super.initState();
    if (!globals.isUserAdmin) addViewerToReport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Relatório",
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
              .collection('eventReports')
              .document(widget.eventID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return LoadingIndicator();
            }

            EventReport report = EventReport.fromJson(snapshot.data.data);
            report.id = widget.eventID;

            return globals.isUserAdmin
                ? SlidingUpPanel(
                    controller: controller,
                    onPanelOpened: () => slidingPanelController.setFilterIsOpen(true),
                    onPanelClosed: () => slidingPanelController.setFilterIsOpen(false),
                    color: ColorsRes.primaryColor,
                    minHeight: 80,
                    maxHeight: 220,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 56),
                              child: StandardButton(
                                label: "Visualizações do Relatório",
                                prefixIcon: Icons.remove_red_eye,
                                backgroundColor: ColorsRes.primaryColorLight,
                                onTapFunction: () {
                                  Navigator.pushNamed(
                                    context,
                                    Constants.reportVisualizationRoute,
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
                                label: "Editar relatório",
                                prefixIcon: Icons.edit,
                                backgroundColor: ColorsRes.primaryColorLight,
                                onTapFunction: () {
                                  Navigator.pushNamed(
                                    context,
                                    Constants.createEventReportRoute,
                                    arguments: [widget.eventID, report],
                                  );
                                },
                                isMin: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    body: eventDetailsWidget(report),
                  )
                : eventDetailsWidget(report);
          }),
    );
  }

  Widget eventDetailsWidget(EventReport report) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: Padding(
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            report.title,
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
                          report.description,
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
      );
    });
  }

  addViewerToReport() async {
    List<String> users = new List<String>();

    DocumentSnapshot snapshot = await Firestore.instance
        .collection('eventReportsViews')
        .document(widget.eventID)
        .get();

    if (snapshot.data != null) {
      EventReportViews eventReportViews = EventReportViews.fromJson(snapshot.data);
      users.addAll(eventReportViews.users);
    }
    if (!users.contains(globals.firebaseCurrentUser.uid))
      users.add(globals.firebaseCurrentUser.uid);

    FeedEventViews newFeedEventViews = FeedEventViews(
      eventID: widget.eventID,
      users: users,
    );

    Firestore.instance
        .collection('eventReportsViews')
        .document(widget.eventID)
        .setData(newFeedEventViews.toJson());
  }
}
