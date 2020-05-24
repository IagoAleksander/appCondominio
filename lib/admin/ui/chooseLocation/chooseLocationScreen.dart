import 'dart:async';

import 'package:app_condominio/admin/bloc/choose_location_bloc.dart';
import 'package:app_condominio/admin/ui/chooseLocation/widgets/text_form_field_address.dart';
import 'package:app_condominio/common/ui/widgets/dialogs.dart';
import 'package:app_condominio/utils/colors_res.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/services.dart';

class ChooseLocationScreen extends StatefulWidget {
  @override
  _ChooseLocationScreenState createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  GlobalKey _mainGlobalKey = GlobalKey<ScaffoldState>();
  FocusNode addressFocusNode;

  ChooseLocationBloc _bloc;
  GoogleMapsPlaces _places;

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController _mapController;

  MarkerId _markerId;
  bool isEditingAddress = false;

  @override
  void initState() {
    addressFocusNode = FocusNode();
    _bloc = ChooseLocationBloc();

    _bloc.listen(
      (state) {
        switch (state) {
          case ChooseLocationState.IDLE:
            break;

          case ChooseLocationState.LOADING:
            Dialogs.showLoadingDialog(
              context,
              "Salvando endereço",
            );
            break;

          case ChooseLocationState.SUCCESS:
            Navigator.pop(context);
            (_mainGlobalKey.currentState as ScaffoldState).showSnackBar(
                SnackBar(content: Text('Endereço configurado com sucesso')));
            Timer(Duration(milliseconds: 2000), () {
              Navigator.pop(context);
            });
            break;

          case ChooseLocationState.ERROR_GENERIC:
            (_mainGlobalKey.currentState as ScaffoldState).showSnackBar(
                SnackBar(content: Text('Ocorreu um erro. Tente novamente.')));
            break;
          case ChooseLocationState.ERROR_FIREBASE:
            Navigator.pop(context);
            (_mainGlobalKey.currentState as ScaffoldState).showSnackBar(
                SnackBar(content: Text('Erro ao salvar endereço')));
            break;
          case ChooseLocationState.ERROR_ADDRESS:
            setState(() {
              isEditingAddress = true;
              addressFocusNode.requestFocus();
            });
            break;
        }
        _bloc.add(ChooseLocationState.IDLE);
      },
    );

    _places = GoogleMapsPlaces(apiKey: _bloc.getGoogleApiKey);
    _markerId = MarkerId(
      'PropertyLocationId',
    );

    _waitForLocation();
    super.initState();
  }

  _waitForLocation() async {
    LatLng location = await _bloc.getUserLocation();
    if (location != null) moveCamera(location);
  }

  _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    _mapController = controller;
  }

  _onMapTap(LatLng point) async {
    _bloc.changeLocationMarker(point);
    _bloc.clearAddress();
    await _bloc.findAddress(point);

    setState(() {
      isEditingAddress = false;
    });
  }

  Widget _showInfoCard() {
    return Padding(
      padding: EdgeInsets.only(
        top: 65,
        left: 8,
        right: 8,
      ),
      child: StreamBuilder(
          stream: _bloc.outErrorAddress,
          builder: (context, snapshot) {
            return Card(
              shape: snapshot.data != null && snapshot.data
                  ? RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    )
                  : null,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Icon(Icons.info_outline),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        "Busque acima para localizar o condomínio no mapa e depois clique em sua localização",
                        style: Theme.of(context).textTheme.body1,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () => setState(
                        () => _bloc.setShowCard(false),
                      ),
                      icon: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget _showIconInfo() {
    return Padding(
      padding: EdgeInsets.only(
        top: 65,
        left: 12,
        right: 12,
      ),
      child: MaterialButton(
        onPressed: () => setState(
          () => _bloc.setShowCard(true),
        ),
        color: Colors.grey[200].withOpacity(0.9),
        disabledColor: Theme.of(context).primaryColor,
        elevation: 8,
        child: Icon(
          Icons.info,
          color: Colors.black54,
          size: 26,
        ),
      ),
    );
  }

  Widget _showAddressCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
          padding: EdgeInsets.all(
            5,
          ),
          child: Card(
            color: ColorsRes.cardBackgroundColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormFieldAddress(
                        hintText: "Escreva a rua e o número do condomínio",
                        addressText: _bloc.getAddressLine(),
                        isEditing: isEditingAddress,
                        isError: _bloc.isErrorAddress(),
                        focusNode: addressFocusNode,
                        onChangeFunction: _bloc.changeAddressLine,
                      ),
                      TextFormFieldAddress(
                        hintText: "Escreva o bairro",
                        addressText: _bloc.getSubLocality(),
                        isEditing: isEditingAddress,
                        onChangeFunction: _bloc.changeSubLocality,
                      ),
                      TextFormFieldAddress(
                        hintText: "Escreva a cidade",
                        addressText: _bloc.getCity(),
                        isEditing: isEditingAddress,
                        onChangeFunction: _bloc.changeCity,
                      ),
                      TextFormFieldAddress(
                        hintText: "Escreva o Estado",
                        addressText: _bloc.getDistrict(),
                        isEditing: isEditingAddress,
                        onChangeFunction: _bloc.changeDistrict,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 50,
                            color: ColorsRes.primaryColorLight,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                isEditingAddress
                                    ? "Salvar endereço"
                                    : "Editar endereço",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isEditingAddress = !isEditingAddress;
                                    addressFocusNode.requestFocus();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 50,
                            color: ColorsRes.accentColor,
                            child: Align(
                              child: Text(
                                "Confirmar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    isEditingAddress = false;
                                  });
                                  _bloc.submitAddress();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Future<void> displayPrediction(Prediction prediction) async {
    if (prediction != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(
        prediction.placeId,
      );

      LatLng newLocation = LatLng(
        detail.result.geometry.location.lat,
        detail.result.geometry.location.lng,
      );

      await moveCamera(newLocation);

      LatLng _marker = _bloc.getLocationMarker;
      if (_marker != null) {
        LatLngBounds _visibleRegion = await _mapController.getVisibleRegion();
        if (_visibleRegion.contains(_marker) == false) {
          _bloc.changeLocationMarker(null);
          _bloc.clearAddress();
          isEditingAddress = false;
        }
      }
    }
  }

  Future<void> moveCamera(LatLng newLocation) async {
    await _mapController.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: newLocation,
          zoom: 18,
        ),
      ),
    );

    FocusScope.of(context).requestFocus(
      new FocusNode(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Selecione a localização",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        ),
      ),
      key: _mainGlobalKey,
      body: SafeArea(
        child: StreamBuilder<LatLng>(
          stream: _bloc.outLocationMarker,
          builder: (context, snapshotMarker) {
            Widget helpWidget;
            if (_bloc.showCard)
              helpWidget = _showInfoCard();
            else
              helpWidget = _showIconInfo();

            List<Marker> locationMarker = snapshotMarker.data != null
                ? [
                    Marker(
                      consumeTapEvents: true,
                      markerId: _markerId,
                      position: snapshotMarker.data,
                    )
                  ]
                : [];

            String locationCoordinates = '';
            if (snapshotMarker.data != null)
              locationCoordinates =
                  '${snapshotMarker.data.latitude}, ${snapshotMarker.data.longitude}';

            return Stack(
              children: <Widget>[
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onTap: _onMapTap,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _bloc.defaultLocation,
                    zoom: 5.0,
                  ),
                  markers: locationMarker.toSet(),
                ),
                Padding(
                  padding: EdgeInsets.all(12),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      border: InputBorder.none,
                      hintText: 'Buscar endereço',
                      suffixIcon: Icon(
                        Icons.search,
                        size: 22,
                      ),
                      fillColor: Colors.white,
                    ),
                    controller: TextEditingController(
                      text: locationCoordinates,
                    ),
                    readOnly: true,
                    textInputAction: TextInputAction.search,
                    onTap: () async {
                      FocusScope.of(context).requestFocus(
                        new FocusNode(),
                      );
                      Prediction prediction = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: _bloc.getGoogleApiKey,
                        language: "pt-br",
                        mode: Mode.overlay,
                        components: [
                          Component(Component.country, "br"),
                        ],
                      );
                      displayPrediction(prediction);
                    },
                  ),
                ),
                helpWidget,
                _bloc.getAddressLine() != null || _bloc.getSubLocality() != null
                    ? _showAddressCard()
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    addressFocusNode.dispose();
    super.dispose();
  }
}
