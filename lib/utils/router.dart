import 'package:app_condominio/admin/ui/chooseLocation/chooseLocationScreen.dart';
import 'package:app_condominio/admin/ui/eventsCentre/createEventReportScreen.dart';
import 'package:app_condominio/admin/ui/eventsCentre/eventVisualizationScreen.dart';
import 'package:app_condominio/admin/ui/eventsCentre/eventsCentreScreen.dart';
import 'package:app_condominio/admin/ui/eventsCentre/registerEventScreen.dart';
import 'package:app_condominio/admin/ui/eventsCentre/reportVisualizationScreen.dart';
import 'package:app_condominio/admin/ui/meetingsCentre/createSurveyScreen.dart';
import 'package:app_condominio/admin/ui/meetingsCentre/meetingVisualizationScreen.dart';
import 'package:app_condominio/admin/ui/meetingsCentre/meetingsCentreScreen.dart';
import 'package:app_condominio/admin/ui/meetingsCentre/registerMeetingScreen.dart';
import 'package:app_condominio/admin/ui/meetingsCentre/resultSurveyScreen.dart';
import 'package:app_condominio/admin/ui/residentsCentre/residentsCentreScreen.dart';
import 'package:app_condominio/admin/ui/setContactInfo/setContactInfoScreen.dart';
import 'package:app_condominio/admin/ui/visitorsCentre/profileRulesScreen.dart';
import 'package:app_condominio/admin/ui/visitorsCentre/visitorsCentreAdminScreen.dart';
import 'package:app_condominio/common/ui/screens/eventsCentre/eventDetailsScreen.dart';
import 'package:app_condominio/common/ui/screens/eventsCentre/eventReportScreen.dart';
import 'package:app_condominio/common/ui/screens/eventsCentreCalendar/eventsCentreCalendarScreen.dart';
import 'package:app_condominio/common/ui/screens/home/homeScreenSelector.dart';
import 'package:app_condominio/common/ui/screens/login/loginScreen.dart';
import 'package:app_condominio/common/ui/screens/meetingsCentre/meetingDetailsScreen.dart';
import 'package:app_condominio/common/ui/screens/register/registerScreen.dart';
import 'package:app_condominio/models/contact_info.dart';
import 'package:app_condominio/models/event_report.dart';
import 'package:app_condominio/models/feed_event.dart';
import 'package:app_condominio/models/meeting.dart';
import 'package:app_condominio/models/meeting_survey_question.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/ui/screens/eventsCentre/eventsFeedScreen.dart';
import 'package:app_condominio/user/ui/screens/meetingsCentre/answerSurveyScreen.dart';
import 'package:app_condominio/user/ui/screens/meetingsCentre/meetingsFeedScreen.dart';
import 'package:app_condominio/user/ui/screens/registerVisitor/registerVisitorScreen.dart';
import 'package:app_condominio/user/ui/screens/visitorsCentre/visitorsCentreScreen.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Constants.loginRoute:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case Constants.registerRoute:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case Constants.homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreenSelector());
      case Constants.visitorsCentreRoute:
        var visitor = settings.arguments as Visitor;
        return MaterialPageRoute(builder: (_) => VisitorsCentreScreen(visitor));
      case Constants.registerVisitorRoute:
        var visitor = settings.arguments as Visitor;
        return MaterialPageRoute(
            builder: (_) => RegisterVisitorScreen(visitor));
      case Constants.residentsCentreRoute:
        return MaterialPageRoute(builder: (_) => ResidentsCentreScreen());
      case Constants.visitorsCentreAdminRoute:
        return MaterialPageRoute(builder: (_) => VisitorsCentreAdminScreen());
      case Constants.profileRulesRoute:
        return MaterialPageRoute(builder: (_) => ProfileRulesScreen());
      case Constants.chooseLocationRoute:
        return MaterialPageRoute(builder: (_) => ChooseLocationScreen());
      case Constants.setContactInfoRoute:
        var info = settings.arguments as ContactInfo;
        return MaterialPageRoute(builder: (_) => SetContactInfoScreen(info));
      case Constants.eventsCentreCalendarRoute:
        return MaterialPageRoute(builder: (_) => EventsCentreCalendarScreen());
      case Constants.eventsFeedRoute:
        return MaterialPageRoute(builder: (_) => EventsFeedScreen());
      case Constants.eventDetailsRoute:
        var eventID = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => EventDetailsScreen(eventID),
            fullscreenDialog: true);
      case Constants.eventsCentreRoute:
        return MaterialPageRoute(builder: (_) => EventsCentreScreen());
      case Constants.registerEventRoute:
        var event = settings.arguments as FeedEvent;
        return MaterialPageRoute(builder: (_) => RegisterEventScreen(event));
      case Constants.eventVisualizationRoute:
        var eventID = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => EventVisualizationScreen(eventID));
      case Constants.createEventReportRoute:
        var args = settings.arguments as List;
        var eventID = args[0];
        var report = args[1];
        return MaterialPageRoute(
            builder: (_) => CreateEventReportScreen(eventID, report));
      case Constants.eventReportRoute:
        var eventID = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => EventReportScreen(eventID));
      case Constants.reportVisualizationRoute:
        var eventID = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ReportVisualizationScreen(eventID));
      case Constants.meetingsFeedRoute:
        return MaterialPageRoute(builder: (_) => MeetingsFeedScreen());
      case Constants.meetingDetailsRoute:
        var varList = settings.arguments as List;
        var meetingID = varList[0];
        var videoID = varList[1];
        return MaterialPageRoute(
            builder: (_) => MeetingDetailsScreen(meetingID, videoID));
      case Constants.registerMeetingRoute:
        var meeting = settings.arguments as Meeting;
        return MaterialPageRoute(builder: (_) => RegisterMeetingScreen(meeting));
      case Constants.createSurveyRoute:
        var args = settings.arguments as List;
        var eventID = args[0];
        var questions = args[1];
        return MaterialPageRoute(
            builder: (_) => CreateSurveyScreen(eventID, questions));
      case Constants.meetingVisualizationRoute:
        var eventID = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => MeetingVisualizationScreen(eventID));
      case Constants.answerSurveyRoute:
        var varList = settings.arguments as List;
        var meetingID = varList[0] as String;
        var questions = varList[1] as List<MeetingSurveyQuestion>;
        return MaterialPageRoute(builder: (_) => AnswerSurveyScreen(meetingID, questions));
      case Constants.meetingsCentreRoute:
        return MaterialPageRoute(builder: (_) => MeetingsCentreScreen());
      case Constants.resultSurveyRoute:
        var meetingID = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => ResultSurveyScreen(meetingID));
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
