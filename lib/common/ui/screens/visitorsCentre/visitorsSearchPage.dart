import 'package:app_condominio/common/bloc/visitorsLiberatedPageBloc.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_card.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_details_dialog.dart';
import 'package:app_condominio/user/bloc/VisitorsCentreBloc.dart';
import 'package:app_condominio/user/ui/screens/home/widgets/option_home_item.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:flutter/material.dart';

class VisitorsSearchPage extends StatefulWidget {
  // ignore: close_sinks
  final VisitorsCentreBloc visitorsCentreBloc = VisitorsCentreBloc();

  final Function(Visitor) notifyParent;
  TextEditingController searchFieldController;

  VisitorsSearchPage({ @required this.notifyParent, this.searchFieldController});

  @override
  _VisitorsSearchPageState createState() => _VisitorsSearchPageState();
}

class _VisitorsSearchPageState extends State<VisitorsSearchPage> {


  @override
  void initState() {

    widget.visitorsCentreBloc.search(widget.searchFieldController.text);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsRes.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: ColorsRes.primaryColorLight,
              padding: const EdgeInsets.all(18.0),
              child: Container(
                alignment: Alignment.center,
                child: TextFormField(
                  controller: widget.searchFieldController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: "Buscar visitante",
                    hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: "WorkSansLight",
                        fontSize: 16.0),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      color: Colors.grey[600],
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                            (_) => widget.searchFieldController.clear());
                        widget.visitorsCentreBloc.search("");
                      },
                    ),
                  ),
                  onChanged: widget.visitorsCentreBloc.changeSearch,
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.loose,
              child: StreamBuilder(
                stream: widget.visitorsCentreBloc.streamVisitor,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data.length == 0) {
                    return LayoutBuilder(
                      builder: (context, constraint) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: constraint.maxHeight),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Busque o visitante desejado",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "através de seu nome (a partir de 3 dígitos)",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "ou",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                OptionHomeItem(
                                  labelText: "Cadastre novo visitante",
                                  iconData: Icons.person_add,
                                  onTapFunction: () {
                                    Navigator.pushNamed(context,
                                        Constants.registerVisitorRoute);
                                  },
                                ),
                              ],
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
                              widget.notifyParent(visitor);
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
            )
          ],
        ),
      ),
    );
  }
}
