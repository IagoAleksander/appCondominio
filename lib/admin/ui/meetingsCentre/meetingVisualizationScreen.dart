import 'package:app_condominio/admin/ui/eventsCentre/widgets/user_visualization_card.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/models/feed_event_views.dart';
import 'package:app_condominio/models/user.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MeetingVisualizationScreen extends StatefulWidget {
  final String meetingID;

  MeetingVisualizationScreen(this.meetingID);

  @override
  _MeetingVisualizationScreenState createState() =>
      _MeetingVisualizationScreenState();
}

class _MeetingVisualizationScreenState
    extends State<MeetingVisualizationScreen> {
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
                  title: Text("Visualizações da Reunião",
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Flexible(
                fit: FlexFit.loose,
                child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('meetingsViews')
                      .document(widget.meetingID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingIndicator();
                    }

                    if (!snapshot.hasData || snapshot.data.data == null) {
                      return Container(
                          child: Center(
                              child: Text(
                        "Não há visualizações\na serem exibidas",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                        textAlign: TextAlign.center,
                      )));
                    }

                    FeedEventViews eventViews =
                        FeedEventViews.fromJson(snapshot.data.data);
                    eventViews.eventID = widget.meetingID;

                    return ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      reverse: false,
                      itemCount: eventViews.users.length,
                      itemBuilder: (_, int index) {
                        return StreamBuilder(
                          stream: Firestore.instance
                              .collection('users')
                              .document(eventViews.users[index])
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return LoadingIndicator();
                            }

                            if (!snapshot.hasData) {
                              return Card(
                                  child: Center(
                                      child: Text(
                                "Não há informações sobre o usuário",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              )));
                            }

                            User user = User.fromJson(snapshot.data.data);

                            return UserVisualizationCard(
                              personName: user.name,
                              rgNumber: user.rg,
                              apartmentNumber: user.apartment,
                              buildingNumber: user.building,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
