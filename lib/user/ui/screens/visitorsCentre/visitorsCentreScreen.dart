import 'package:app_condominio/common/ui/screens/visitorsCentre/visitorsLiberatedPage.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/visitorsSearchPage.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/bloc/VisitorsCentreBloc.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class VisitorsCentreScreen extends StatefulWidget {
  final Visitor visitor;

  VisitorsCentreScreen(this.visitor);

  VisitorsSearchPage visitorsSearchPage;
  VisitorsLiberatedPage visitorsLiberatedPage;

  @override
  _VisitorsCentreScreenState createState() => _VisitorsCentreScreenState();
}

class _VisitorsCentreScreenState extends State<VisitorsCentreScreen> {
  // ignore: close_sinks
  final VisitorsCentreBloc visitorsCentreBloc = VisitorsCentreBloc();
  int currentPage = 0;
  var _searchFieldController;

  @override
  void initState() {
    _searchFieldController = TextEditingController(
        text: widget.visitor != null ? widget.visitor.name : null);

    widget.visitorsSearchPage = VisitorsSearchPage(
      notifyParent: refresh,
      searchFieldController: _searchFieldController,
    );
    widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.person, title: "Lista de Visitantes"),
          TabData(iconData: Icons.history, title: "Acessos Liberados"),
        ],
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
        barBackgroundColor: ColorsRes.primaryColorLight,
        circleColor: ColorsRes.primaryColor,
        inactiveIconColor: Colors.white,
        textColor: Colors.white,
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            sliver: SliverSafeArea(
              top: false,
              sliver: SliverAppBar(
                backgroundColor: ColorsRes.primaryColorLight,
                expandedHeight: 160,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Centro de Visitantes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
        ],
        body: currentPage == 0
            ? widget.visitorsSearchPage
            : widget.visitorsLiberatedPage,
      ),
    );
  }

  refresh(Visitor visitor) {
    setState(() {
//      visitorsCentreBloc.visitors[visitor.rg] = visitor;
      widget.visitorsSearchPage = VisitorsSearchPage(
        notifyParent: refresh,
        searchFieldController: _searchFieldController,
      );
      widget.visitorsLiberatedPage = VisitorsLiberatedPage(refresh);
    });
  }
}
