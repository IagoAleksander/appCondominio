import 'package:app_condominio/common/mobx/eventsFeedController.dart';
import 'package:app_condominio/common/mobx/meetingsFeedController.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/date_picker_custom.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/meeting.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/date_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MeetingsFeedScreen extends StatefulWidget {
  @override
  _MeetingsFeedScreenState createState() => _MeetingsFeedScreenState();
}

class _MeetingsFeedScreenState extends State<MeetingsFeedScreen> {
  PanelController controller = PanelController();
  MeetingsFeedController feedController = MeetingsFeedController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: ColorsRes.primaryColorLight,
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("Centro de Reuniões",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                ),
              ),
            ),
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ],
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
          body: Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  new Flexible(
                    child: Observer(
                      builder: (_) {
                        return StreamBuilder(
                          stream: Firestore.instance
                              .collection('meetings')
                              .where("isActive", isEqualTo: true)
                              .where("meetingDateInMillis",
                                  isGreaterThan:
                                      feedController.initialDateApplied)
                              .where("meetingDateInMillis",
                                  isLessThan: feedController.finalDateApplied)
                              .orderBy("meetingDateInMillis", descending: true)
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
                                "No momento não há reuniões\na serem exibidas",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24),
                                textAlign: TextAlign.center,
                              )));
                            }

                            return Observer(
                              builder: (_) {
                                return ListView.builder(
                                  padding: EdgeInsets.all(8.0),
                                  reverse: false,
                                  itemCount:
                                      snapshot.data.documents.length <= 1 ||
                                              feedController.isFiltered
                                          ? snapshot.data.documents.length
                                          : snapshot.data.documents.length + 1,
                                  itemBuilder: (_, int index) {
                                    if (index == 0 &&
                                        !feedController.isFiltered) {
                                      Meeting meeting = Meeting.fromJson(
                                          snapshot.data.documents[index].data);
                                      meeting.id = snapshot
                                          .data.documents[index].documentID;

                                      return Card(
                                        color: ColorsRes.cardBackgroundColor,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              Constants.meetingDetailsRoute,
                                              arguments: [
                                                meeting.id,
                                                meeting.videoID
                                              ],
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.event,
                                                            size: 30.0,
                                                            color: ColorsRes
                                                                .accentColor,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          12.0),
                                                              child: Text(
                                                                DateUtils
                                                                    .getFormattedDaysFromDate(
                                                                        meeting
                                                                            .meetingDateInMillis),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white70,
                                                                    fontSize:
                                                                        14),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 28.0,
                                                            color: ColorsRes
                                                                .accentColor,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          12.0),
                                                              child: Text(
                                                                DateUtils
                                                                    .getFormattedTimeFromDate(
                                                                        meeting
                                                                            .meetingDateInMillis),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white70),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 24,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          meeting.title,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 22,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: ProgressButton(
                                                      color: ColorsRes
                                                          .primaryColor,
                                                      borderRadius: 90.0,
                                                      defaultWidget: Text(
                                                        "VER DETALHES",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                      ),
                                                      progressWidget:
                                                          const CircularProgressIndicator(
                                                        strokeWidth: 4,
                                                        backgroundColor:
                                                            ColorsRes
                                                                .accentColor,
                                                        valueColor:
                                                            const AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.white),
                                                      ),
                                                      width: 160,
                                                      // ignore: missing_return
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          Constants
                                                              .meetingDetailsRoute,
                                                          arguments: [
                                                            meeting.id,
                                                            meeting.videoID
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    if (snapshot.data.documents.length > 1 &&
                                        index == 1 &&
                                        !feedController.isFiltered) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Container(
                                          height: 40,
                                          color: ColorsRes.primaryColorLight,
                                          child: SizedBox.expand(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Histórico",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    Meeting meeting = Meeting.fromJson(snapshot
                                        .data
                                        .documents[feedController.isFiltered
                                            ? index
                                            : index - 1]
                                        .data);
                                    meeting.id = snapshot
                                        .data
                                        .documents[feedController.isFiltered
                                            ? index
                                            : index - 1]
                                        .documentID;

                                    return Card(
                                      color: ColorsRes.cardBackgroundColor,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            Constants.meetingDetailsRoute,
                                            arguments: [
                                              meeting.id,
                                              meeting.videoID
                                            ],
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: Text(
                                                      DateUtils.getFormattedDate(
                                                          meeting
                                                              .meetingDateInMillis),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white70),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16,
                                                ),
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: Text(
                                                      meeting.title,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
