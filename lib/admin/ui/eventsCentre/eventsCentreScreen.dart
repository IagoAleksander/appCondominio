import 'package:app_condominio/admin/ui/visitorsCentre/widgets/accessHistoryPage.dart';
import 'package:app_condominio/common/mobx/eventsFeedController.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/visitorsLiberatedPage.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/date_picker_custom.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// ignore: must_be_immutable
class EventsCentreScreen extends StatefulWidget {
  @override
  _EventsCentreScreenState createState() => _EventsCentreScreenState();
}

class _EventsCentreScreenState extends State<EventsCentreScreen> {
  PanelController controller = PanelController();
  EventsFeedController feedController = EventsFeedController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Centro de Eventos",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: ColorsRes.primaryColorLight,
      ),
      backgroundColor: ColorsRes.primaryColor,
      body: SlidingUpPanel(
        controller: controller,
        onPanelOpened: () => feedController.setFilterIsOpen(true),
        onPanelClosed: () => feedController.setFilterIsOpen(false),
        color: ColorsRes.primaryColor,
        minHeight: 80,
        maxHeight: 320,
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
                    label: feedController.filterIsOpen
                        ? "Esconder filtro"
                        : "Filtrar por data",
                    suffixIcon: feedController.filterIsOpen
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    backgroundColor: feedController.filterIsOpen
                        ? ColorsRes.primaryColor
                        : ColorsRes.primaryColorLight,
                    onTapFunction: () async {
                      if (controller.isPanelOpen) {
                        controller.close();
                        feedController.setFilterIsOpen(false);
                      } else {
                        controller.open();
                        feedController.setFilterIsOpen(true);
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Filtre pelo período desejado",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Observer(
                          builder: (_) {
                            return DatePickerCustom(
                              labelText: "Início",
                              selectDate: feedController.setInitialDate,
                              selectedDate:
                                  feedController.initialDateSelected == null
                                      ? null
                                      : DateTime.fromMillisecondsSinceEpoch(
                                          feedController.initialDateSelected),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Observer(
                          builder: (_) {
                            return DatePickerCustom(
                              labelText: "Fim",
                              selectDate: feedController.setFinalDate,
                              selectedDate:
                                  feedController.finalDateSelected == null
                                      ? null
                                      : DateTime.fromMillisecondsSinceEpoch(
                                          feedController.finalDateSelected),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StandardButton(
                    label: "Filtrar",
                    backgroundColor: ColorsRes.primaryColorLight,
                    onTapFunction: () {
                      feedController.applyFilter();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StandardButton(
                label: "Cadastrar novo evento",
                backgroundColor: ColorsRes.primaryColorLight,
                onTapFunction: () {
                  Navigator.pushNamed(context, Constants.registerEventRoute);
                },
              ),
            ),
            Container(
              color: ColorsRes.primaryColorLight,
              height: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Observer(
                  builder: (_) {
                    return StreamBuilder(
                      stream: Firestore.instance
                          .collection('feedEvents')
                          .where("eventDateInMillis",
                              isGreaterThan: feedController.initialDateApplied)
                          .where("eventDateInMillis",
                              isLessThan: feedController.finalDateApplied)
                          .orderBy("eventDateInMillis", descending: true)
                          .limit(20)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingIndicator();
                        }
                        if (!snapshot.hasData ||
                            snapshot.data.documents.length == 0) {
                          return Container(
                              child: Center(
                                  child: Text(
                            "No momento não há eventos\na serem exibidos",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                            textAlign: TextAlign.center,
                          )));
                        }
                        return ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          reverse: false,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (_, int index) {
                            FeedEvent feedEvent = FeedEvent.fromJson(
                                snapshot.data.documents[index].data);
                            feedEvent.id =
                                snapshot.data.documents[index].documentID;

                            return Card(
                              color: ColorsRes.cardBackgroundColor,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Constants.eventDetailsRoute,
                                      arguments: feedEvent.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0),
                                                child: Text(
                                                  DateUtils.getFormattedDate(
                                                      feedEvent
                                                          .eventDateInMillis),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 22,
                                            ),
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0),
                                                child: Text(
                                                  feedEvent.title,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4.0),
                                                child: Text(
                                                  feedEvent.description,
                                                  textAlign: TextAlign.justify,
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      feedEvent.imageUrl != null
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Container(
                                                padding: EdgeInsets.all(4.0),
                                                decoration: new BoxDecoration(
                                                    border: new Border.all(
                                                        color: Colors.white24),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    color: ColorsRes
                                                        .primaryColorLight),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    CachedNetworkImage(
                                                      width: 120,
                                                      height: 120,
                                                      imageUrl:
                                                          feedEvent.imageUrl,
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(
                                                        Icons.error,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
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
              ),
            ),
            SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
