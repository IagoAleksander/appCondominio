import 'package:app_condominio/common/bloc/visitorsLiberatedPageBloc.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_card.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_details_dialog.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter/material.dart';

class VisitorsLiberatedPage extends StatefulWidget {
  // ignore: close_sinks
  final VisitorsLiberatedPageBloc visitorsLiberatedPageBloc =
      VisitorsLiberatedPageBloc();

  final Function(Visitor) notifyParent;

  VisitorsLiberatedPage(this.notifyParent);

  @override
  _VisitorsLiberatedPageState createState() => _VisitorsLiberatedPageState();
}

class _VisitorsLiberatedPageState extends State<VisitorsLiberatedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: Column(
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: StreamBuilder(
              stream: widget.visitorsLiberatedPageBloc.streamHistory,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingIndicator();
                }
                if (!snapshot.hasData || snapshot.data.length == 0) {
                  return LayoutBuilder(
                    builder: (context, constraint) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minHeight: constraint.maxHeight),
                          child: Center(
                            child: Text(
                              "Não há visitantes liberados",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: snapshot.data.length,
                  itemBuilder: (_, int index) {
                    Visitor visitor = snapshot.data[index];
                    return VisitorCard(
                      personName: visitor.name,
                      rgNumber: visitor.rg,
                      isLiberated: visitor.isLiberated == null
                          ? false
                          : visitor.isLiberated,
                      onTapFunction: () async {
                        String status =
                            await VisitorDetailsDialog.showVisitorDetails(
                                context, visitor);

                        switch (status) {
                          case "SUCCESS":
                            setState(() {
                              widget.notifyParent(visitor);
                            });
                            break;
                          case "ERROR":
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Erro ao obter informações do visitante')));
                            break;
                          case "CANCEL":
                            break;
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
