import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as geoLocator;
import 'package:location/location.dart' as loc;

class GeolocatorService {
  final geoLocator.Geolocator geo = geoLocator.Geolocator();

  Stream<geoLocator.Position> getCurrentLocation() {
    var locationOptions = geoLocator.LocationOptions(
        accuracy: geoLocator.LocationAccuracy.high, distanceFilter: 1);
    return geo.getPositionStream(locationOptions);
  }

  Future<geoLocator.Position> getInitialLocation() async {
    return geo.getCurrentPosition(
        desiredAccuracy: geoLocator.LocationAccuracy.high,
        locationPermissionLevel: geoLocator.GeolocationPermission.location);
  }

  void checkService() async {
    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return SystemNavigator.pop();
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
  }
}
