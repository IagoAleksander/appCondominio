import 'package:app_condominio/common/bloc/visitorsLiberatedPageBloc.dart';
import 'package:app_condominio/common/ui/screens/login/widgets/LoadingIndicator.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_card.dart';
import 'package:app_condominio/common/ui/screens/visitorsCentre/widgets/visitor_details_dialog.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/common/ui/widgets/standard_button.dart';
import 'package:app_condominio/models/access_code.dart';
import 'package:app_condominio/models/visitor.dart';
import 'package:app_condominio/user/bloc/SearchVisitorsBloc.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:app_condominio/utils/constants.dart';
import 'package:app_condominio/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_condominio/utils/globals.dart' as globals;
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class VisitorsCentreScreen extends StatefulWidget {
  final TextEditingController searchFieldController = TextEditingController();
  final SearchVisitorsBloc searchVisitorsBloc = SearchVisitorsBloc();
  final Visitor visitor;

  VisitorsCentreScreen(this.visitor);

  @override
  _VisitorsCentreScreenState createState() => _VisitorsCentreScreenState();
}

class _VisitorsCentreScreenState extends State<VisitorsCentreScreen> {
  final VisitorsLiberatedPageBloc visitorsLiberatedPageBloc =
      VisitorsLiberatedPageBloc();
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  int currentPage = 0;
  PanelController controller = PanelController();

  @override
  void initState() {
    super.initState();
    if (widget.visitor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await VisitorDetailsDialog.showVisitorDetails(
            _mainGlobalKey.currentContext, widget.visitor);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _mainGlobalKey,
      backgroundColor: ColorsRes.primaryColor,
      body: SlidingUpPanel(
        controller: controller,
        onPanelOpened: () => widget.searchVisitorsBloc.changeIsOpen(true),
        onPanelClosed: () => widget.searchVisitorsBloc.changeIsOpen(false),
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
              child: Builder(
                builder: (context) => StreamBuilder<bool>(
                    stream: widget.searchVisitorsBloc.streamIsOpen,
                    builder: (context, isOpen) {
                      return StandardButton(
                        label: isOpen.hasData && isOpen.data
                            ? "Esconder busca"
                            : "Liberar visitante",
                        icon: isOpen.data
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        backgroundColor: isOpen.data
                            ? ColorsRes.primaryColor
                            : ColorsRes.primaryColorLight,
                        onTapFunction: () async {
                          if (controller.isPanelOpen) {
                            controller.close();
                            widget.searchVisitorsBloc.changeIsOpen(false);
                          } else {
                            controller.open();
                            widget.searchVisitorsBloc.changeIsOpen(true);
                          }
//                          String result = await showCreateRuleDialog(
//                              context, profileRulesBloc, null);
//                          Scaffold.of(context).hideCurrentSnackBar();
//                          Scaffold.of(context).showSnackBar(SnackBar(
//                              content: Text(result == "SUCCESS"
//                                  ? 'Regra de perfil criada com sucesso'
//                                  : 'Erro na criação da regra')));
                        },
                      );
                    }),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Encontre o visitante desejado",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: widget.searchFieldController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Número de documento (RG)",
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
                              widget.searchVisitorsBloc.changeSearch("");
                            },
                          ),
                        ),
                        inputFormatters: [
                          MaskedTextInputFormatter(
                            mask: 'XX.XXX.XXX-X',
                            separator: '.',
                          ),
                          MaskedTextInputFormatter(
                            mask: 'XX.XXX.XXX-X',
                            separator: '-',
                          )
                        ],
                        onChanged: widget.searchVisitorsBloc.changeSearch,
                        validator: (value) => Validators.validateDocument(
                            value, "Insira um documento válido"),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StandardButton(
                    label: "Buscar visitante",
                    backgroundColor: ColorsRes.primaryColorLight,
                    onTapFunction: () {
                      if (_formKey.currentState.validate()) {
                        searchVisitor();
                      }
//                      Navigator.pushNamed(context, Constants.profileRulesRoute);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
                    title: Text("Visitantes Liberados",
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
              children: <Widget>[
                new Flexible(
                  fit: FlexFit.loose,
                  child: StreamBuilder(
                      stream: !globals.isUserAdmin
                          ? Firestore.instance
                              .collection('accessCodes')
                              .where("isActive", isEqualTo: true)
                              .where("createdBy",
                                  isEqualTo: globals.firebaseCurrentUser.uid)
                              .snapshots()
                          : Firestore.instance
                              .collection('accessCodes')
                              .where("isActive", isEqualTo: true)
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
                            "No momento não há\nacessos liberados",
                            style: TextStyle(color: Colors.white, fontSize: 24),
                            textAlign: TextAlign.center,
                          )));
                        }
                        return ListView.builder(
                            padding: EdgeInsets.all(8.0),
                            reverse: false,
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (_, int index) {
                              AccessCode accessCode = AccessCode.fromJson(
                                  snapshot.data.documents[index].data);

                              return StreamBuilder(
                                  stream: Firestore.instance
                                      .collection('visitors')
                                      .document(accessCode.createdTo)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return LoadingIndicator();
                                    }
                                    if (!snapshot.hasData) {
                                      return Container(
                                          child: Center(
                                              child: Text(
                                        "No momento não há\nacessos liberados",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24),
                                        textAlign: TextAlign.center,
                                      )));
                                    }
                                    Visitor visitor =
                                        Visitor.fromJson(snapshot.data.data);
                                    visitor.id = snapshot.data.documentID;
                                    return VisitorCard(
                                      personName: visitor.name,
                                      rgNumber: visitor.rg,
                                      isLiberated: visitor.isLiberated == null
                                          ? false
                                          : visitor.isLiberated,
                                      onTapFunction: () async {
                                        String status =
                                            await VisitorDetailsDialog
                                                .showVisitorDetails(
                                                    _mainGlobalKey
                                                        .currentContext,
                                                    visitor);

                                        switch (status) {
                                          case "SUCCESS":
//                                          widget.notifyParent(visitor);
                                            break;
                                          case "ERROR":
                                            (_mainGlobalKey.currentState
                                                    as ScaffoldState)
                                                .hideCurrentSnackBar();
                                            (_mainGlobalKey.currentState
                                                    as ScaffoldState)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Erro ao obter informações do visitante')));
                                            break;
                                          case "CANCEL":
                                            break;
                                        }
                                      },
                                    );
                                  });
                            });
                      }),
                ),
                SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  searchVisitor() async {
    Dialogs.showLoadingDialog(
        _mainGlobalKey.currentContext, "Buscando visitante");
    DocumentSnapshot snapshot = await Firestore.instance
        .collection("visitors")
        .document(widget.searchVisitorsBloc.searchSubject.value)
        .get();
    if (snapshot.data == null) {
      Navigator.pop(_mainGlobalKey.currentContext);
      showVisitorNotFoundDialog(_mainGlobalKey.currentContext);
    } else {
      Visitor visitor = Visitor.fromJson(snapshot.data);
      visitor.id = snapshot.documentID;
      Navigator.pop(_mainGlobalKey.currentContext);
      FocusScope.of(_mainGlobalKey.currentContext)
          .requestFocus(new FocusNode());
      controller.close();
      String status = await VisitorDetailsDialog.showVisitorDetails(
          _mainGlobalKey.currentContext, visitor);
      switch (status) {
        case "SUCCESS":
          break;
        case "ERROR":
          (_mainGlobalKey.currentState as ScaffoldState).showSnackBar(SnackBar(
              content: Text('Erro ao obter informações do visitante')));
          break;
        case "CANCEL":
          break;
      }
    }
  }

  Future<String> showVisitorNotFoundDialog(BuildContext context) async {
    String status;
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.pop(context);
        status = "CANCEL";
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Cadastrar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        String rg = widget.searchVisitorsBloc.searchSubject.value;
        Visitor visitor = new Visitor(rg: rg);
        Navigator.pushNamed(context, Constants.registerVisitorRoute,
            arguments: visitor);

//        status = "SUCCESS";
//
//        Navigator.pop(context);
//        Navigator.pop(context);
//        Navigator.pop(context);
      },
    );

// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: ColorsRes.primaryColorLight,
      content: Text(
        "Visitante não encontrado.\nDeseja cadastrar um novo visitante?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

// show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );

    return Future.value(status);
  }
}
