import 'package:app_condominio/models/address.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationServices;
import 'package:rxdart/rxdart.dart';

enum ChooseLocationState {
  IDLE,
  LOADING,
  ERROR_ADDRESS,
  ERROR_FIREBASE,
  ERROR_GENERIC,
  SUCCESS,
}

class ChooseLocationBloc
    extends Bloc<ChooseLocationState, ChooseLocationState> {
  String kGoogleApiKey = "AIzaSyCjVImXBCHmnElimGDDhA6lbqOL3ChSGnE";
  LocationServices.Location _locationInstance;

  String get getGoogleApiKey => kGoogleApiKey;

  // #region Properties
  LatLng _defaultLocation;

  LatLng get defaultLocation => _defaultLocation;

  void setDefaultLocation(LatLng location) => _defaultLocation = location;

  bool _showCard;

  bool get showCard => _showCard;

  void setShowCard(bool newShowCard) => _showCard = newShowCard;

  bool _haveUserLocation;

  bool get haveUserLocation => _haveUserLocation;

  void setHaveUserLocation(bool newHaveUserLocation) =>
      _haveUserLocation = newHaveUserLocation;

  // #endregion

  // #region Constructor
  ChooseLocationBloc() {
    // Set Default values
    _locationInstance = LocationServices.Location();
    LatLng _brazilLocation = LatLng(-7.4873920547670885, -55.3438646458435);
    _defaultLocation = _brazilLocation;

    _showCard = true;
    _haveUserLocation = false;
    changeIsErrorAddress(false);
  }

  // #endregion

  // #region Bloc implementation
  // Subjects
  BehaviorSubject<bool> _isErrorAddress = BehaviorSubject<bool>();
  BehaviorSubject<String> _subjectAddressLine = BehaviorSubject<String>();
  BehaviorSubject<String> _subjectSubLocality = BehaviorSubject<String>();
  BehaviorSubject<String> _subjectCity = BehaviorSubject<String>();
  BehaviorSubject<String> _subjectDistrict = BehaviorSubject<String>();
  BehaviorSubject<LatLng> _subjectLocationMarker = BehaviorSubject<LatLng>();

  // Streams
  Stream<bool> get outErrorAddress => _isErrorAddress.stream;

  Stream<String> get outAddress => _subjectAddressLine.stream;

  Stream<String> get outSubLocality => _subjectSubLocality.stream;

  Stream<String> get outCity => _subjectCity.stream;

  Stream<String> get outDistrict => _subjectDistrict.stream;

  Stream<LatLng> get outLocationMarker => _subjectLocationMarker.stream;

  LatLng get getLocationMarker => _subjectLocationMarker.value;

  // Changes
  Function(bool) get changeIsErrorAddress => _isErrorAddress.sink.add;

  Function(String) get changeAddressLine => _subjectAddressLine.sink.add;

  Function(String) get changeSubLocality => _subjectSubLocality.sink.add;

  Function(String) get changeCity => _subjectCity.sink.add;

  Function(String) get changeDistrict => _subjectDistrict.sink.add;

  Function(LatLng) get changeLocationMarker => _subjectLocationMarker.sink.add;

  // Getters
  bool isErrorAddress() => _isErrorAddress.value;

  LatLng getLocation() => _subjectLocationMarker.value;

  String getAddressLine() => _subjectAddressLine.value;

  String getSubLocality() => _subjectSubLocality.value;

  String getCity() => _subjectCity.value;

  String getDistrict() => _subjectDistrict.value;

  // #endregion

  // #region General Functions
  submitAddress() async {
    if (getAddressLine() != null && getAddressLine().isNotEmpty) {
      changeIsErrorAddress(false);
      add(ChooseLocationState.LOADING);

      LocationAddress address = new LocationAddress();
      address.addressLine = getAddressLine();
      address.subLocality = getSubLocality();
      address.city = getCity();
      address.district = getDistrict();
      address.latitude = getLocation().latitude;
      address.longitude = getLocation().longitude;

      await Firestore.instance
          .collection('parameters')
          .document('address')
          .setData(address.toJson())
          .catchError((e) {
        return add(ChooseLocationState.ERROR_FIREBASE);
      });

      return add(ChooseLocationState.SUCCESS);
    }

    changeIsErrorAddress(true);
    add(ChooseLocationState.ERROR_ADDRESS);
  }

  LatLng getMarkerLocation() {
    return _subjectLocationMarker.value;
  }

  // #endregion

  clearAddress() {
    changeAddressLine(null);
    changeSubLocality(null);
    changeDistrict(null);
    changeCity(null);
    changeIsErrorAddress(false);
  }

  findAddress(LatLng point) async {
    Coordinates _coordinates = Coordinates(point.latitude, point.longitude);
    List<Address> addresses = await Geocoder.google(kGoogleApiKey)
        .findAddressesFromCoordinates(_coordinates);

    if (addresses.isNotEmpty) {
      Address firstResult = addresses.first;
      String addressLine;
      if (firstResult.thoroughfare != null &&
          firstResult.thoroughfare.isNotEmpty) {
        addressLine = firstResult.thoroughfare + ", ";
      }
      if (firstResult.subThoroughfare != null &&
          firstResult.subThoroughfare.isNotEmpty) {
        addressLine += firstResult.subThoroughfare;
      }
      String subLocality;
      if (firstResult.subLocality != null &&
          firstResult.subLocality.isNotEmpty) {
        subLocality = firstResult.subLocality;
      }
      String city;
      if (firstResult.subAdminArea != null &&
          firstResult.subAdminArea.isNotEmpty) {
        city = firstResult.subAdminArea;
      }
      String district;
      if (firstResult.adminArea != null && firstResult.adminArea.isNotEmpty) {
        district = firstResult.adminArea;
      }
      changeAddressLine(addressLine);
      changeSubLocality(subLocality);
      changeCity(city);
      changeDistrict(district);
    }
  }

  // #region Overrides
  @override
  Future<Function> close() {
    _isErrorAddress.close();
    _subjectAddressLine.close();
    _subjectSubLocality.close();
    _subjectCity.close();
    _subjectDistrict.close();
    _subjectLocationMarker.close();
    return super.close();
  }

  @override
  ChooseLocationState get initialState => ChooseLocationState.IDLE;

  @override
  Stream<ChooseLocationState> mapEventToState(
      ChooseLocationState event) async* {
    yield event;
  }

// #endregion
  Future<bool> _getPermissions() async {
    bool permissionGranted = await _checkPermissions();
    if (!permissionGranted) {
      permissionGranted = await _requestPermission();
    }

    if (permissionGranted) {
      bool locationServicesEnabled = await _checkService();
      if (!locationServicesEnabled) {
        locationServicesEnabled = await _requestService();
      }

      if (locationServicesEnabled) return true;
    }

    return false;
  }

  Future<bool> _requestPermission() async {
    final LocationServices.PermissionStatus permissionResult =
        await _locationInstance.requestPermission();
    if (permissionResult == LocationServices.PermissionStatus.granted)
      return true;
    else
      return false;
  }

  Future<bool> _checkPermissions() async {
    final LocationServices.PermissionStatus permissionResult =
        await _locationInstance.hasPermission();
    if (permissionResult == LocationServices.PermissionStatus.granted)
      return true;
    else
      return false;
  }

  Future<bool> _checkService() async {
    bool locationServiceEnabled = await _locationInstance.serviceEnabled();
    return locationServiceEnabled;
  }

  Future<bool> _requestService() async {
    bool locationServiceEnabled = await _locationInstance.requestService();
    return locationServiceEnabled;
  }

  Future<LocationServices.LocationData> _getUserLocation() async {
    try {
      LocationServices.Location location = LocationServices.Location();
      LocationServices.LocationData _locationDevice =
          await location.getLocation();
      return _locationDevice;
    } catch (error) {
      return null;
    }
  }

  // #region Get User Location
  Future<LatLng> getUserLocation() async {
    LocationServices.LocationData _location;
    if (await _getPermissions()) {
      _location = await _getUserLocation();
      if (_location != null) {
        LatLng actualLocation = LatLng(_location.latitude, _location.longitude);
        setDefaultLocation(actualLocation);
        setHaveUserLocation(true);
        add(ChooseLocationState.IDLE);
        return Future.value(actualLocation);
      } else {
        add(ChooseLocationState.ERROR_GENERIC);
      }
    } else
      add(ChooseLocationState.IDLE);

    return Future.value(null);
  }

// #endregion
}
