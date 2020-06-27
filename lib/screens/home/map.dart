import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geo_tracker/models/location.dart';
import 'package:geo_tracker/services/auth.dart';
import 'package:geo_tracker/services/database.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geo_tracker/shared/loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as directions;
import 'package:google_maps_webservice/places.dart' as places;
import 'package:provider/provider.dart';

class Maps extends StatefulWidget {
  final Position initialPosition;
  final uid;
  Maps({this.initialPosition, this.uid});
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  final GeolocatorService goeService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.normal;
  final AuthService _authService = AuthService();
  final GeolocatorService geolocatorService = GeolocatorService();
  final Set<Polyline> _polyLines = {};
  Set<Polyline> get polyLines => _polyLines;
  bool _online = false;
  String _status = 'offline';
  final _destinationInputController = TextEditingController();
  final _startingInputController = TextEditingController();

  List<places.Prediction> startingPredictions = [];
  List<places.Prediction> destPredictions = [];
  LatLng _startingLocation;
  bool _loading = false;

  directions.GoogleMapsDirections googleMapsDirections =
      directions.GoogleMapsDirections(
          apiKey: 'AIzaSyCpwuYEeorArZmAOc0iqup9gqgD1wMjM3o');
  places.GoogleMapsPlaces googleMapsPlaces = places.GoogleMapsPlaces(
      apiKey: 'AIzaSyCpwuYEeorArZmAOc0iqup9gqgD1wMjM3o');

  @override
  void initState() {
    DatabaseService(uid: widget.uid).updateUserStatus(false);
    geolocatorService.checkService();
    goeService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locations = Provider.of<List<Location>>(context) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Geo Locator'),
        backgroundColor: Colors.green[900],
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              await _authService.signOut();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: !_loading
          ? Center(
              child: Stack(children: <Widget>[
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(widget.initialPosition.latitude,
                          widget.initialPosition.longitude),
                      zoom: 18),
                  mapType: _currentMapType,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationButtonEnabled: false,
                  markers: Set<Marker>.of(getMarkers(locations)),
                  polylines:
                      _polyLines.isNotEmpty && _polyLines.first.points != null
                          ? _polyLines
                          : null,
                ),
                Positioned(
                  top: 20.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) async {
                        var autoStartComp = await googleMapsPlaces
                            .autocomplete(value, components: [
                          directions.Component(
                              directions.Component.country, 'usa')
                        ]);
                        setState(() {
                          startingPredictions = autoStartComp.predictions;
                        });
                      },
                      controller: _startingInputController,
                      // enabled: false,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, bottom: 10),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.green[900],
                          ),
                        ),
                        hintText: 'Your location',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) async {
                        var autoCo = await googleMapsPlaces.autocomplete(value,
                            components: [
                              directions.Component(
                                  directions.Component.country, 'usa')
                            ]);
                        setState(() {
                          destPredictions = autoCo.predictions;
                        });
                      },
                      controller: _destinationInputController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.go,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20, bottom: 10),
                          width: 10,
                          height: 10,
                          child: Icon(
                            Icons.local_taxi,
                            color: Colors.green[900],
                          ),
                        ),
                        hintText: 'destination',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, top: 5.0),
                      ),
                    ),
                  ),
                ),
                destPredictions.length != 0
                    ? Positioned(
                        top: 127.0,
                        right: 15.0,
                        left: 15.0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Flexible(
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: destPredictions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Column(
                                    children: <Widget>[
                                      Divider(
                                        height: 1,
                                      ),
                                      ListTile(
                                        title: Text(
                                            destPredictions[index].description),
                                        onTap: () async {
                                          _destinationInputController.text =
                                              destPredictions[index]
                                                  .description;
                                          setState(() {
                                            _loading = true;
                                          });
                                          var placeDetails =
                                              await googleMapsPlaces
                                                  .getDetailsByPlaceId(
                                                      destPredictions[index]
                                                          .placeId);
                                          setState(() {
                                            destPredictions = [];
                                          });
                                          var origin = _startingLocation != null
                                              ? _startingLocation
                                              : LatLng(
                                                  widget
                                                      .initialPosition.latitude,
                                                  widget.initialPosition
                                                      .longitude);
                                          await getPolylines(
                                            origin,
                                            LatLng(
                                                placeDetails.result.geometry
                                                    .location.lat,
                                                placeDetails.result.geometry
                                                    .location.lng),
                                          );
                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                        leading: Icon(Icons.location_on),
                                      ),
                                    ],
                                  ),
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.vertical,
                                ),
                                fit: FlexFit.loose,
                              ),
                            ],
                            mainAxisSize: MainAxisSize.min,
                          ),
                        ),
                      )
                    : Container(),
                startingPredictions.length != 0
                    ? Positioned(
                        top: 70.0,
                        right: 15.0,
                        left: 15.0,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Flex(
                            direction: Axis.vertical,
                            children: <Widget>[
                              Flexible(
                                child: ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: startingPredictions.length,
                                  itemBuilder:
                                      (BuildContext context, int index) =>
                                          Column(
                                    children: <Widget>[
                                      Divider(
                                        height: 1,
                                      ),
                                      ListTile(
                                        title: Text(startingPredictions[index]
                                            .description),
                                        onTap: () async {
                                          _startingInputController.text =
                                              startingPredictions[index]
                                                  .description;

                                          var placeDetails =
                                              await googleMapsPlaces
                                                  .getDetailsByPlaceId(
                                                      startingPredictions[index]
                                                          .placeId);
                                          setState(() {
                                            startingPredictions = [];
                                            _startingLocation = LatLng(
                                                placeDetails.result.geometry
                                                    .location.lat,
                                                placeDetails.result.geometry
                                                    .location.lng);
                                          });
                                        },
                                        leading: Icon(Icons.location_on),
                                      ),
                                    ],
                                  ),
                                  shrinkWrap: true,
                                  // scrollDirection: Axis.vertical,
                                ),
                                fit: FlexFit.loose,
                              ),
                            ],
                            mainAxisSize: MainAxisSize.min,
                          ),
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: 'btn1',
                          onPressed: () => setState(() {
                            _currentMapType = _currentMapType == MapType.normal
                                ? MapType.hybrid
                                : MapType.normal;
                          }),
                          backgroundColor: Colors.green[900],
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          child: Icon(
                            _currentMapType == MapType.normal
                                ? Icons.satellite
                                : Icons.map,
                            size: 30,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FloatingActionButton(
                          heroTag: 'btn2',
                          onPressed: () async {
                            geolocatorService.checkService();
                            Position position = await Geolocator()
                                .getCurrentPosition(
                                    desiredAccuracy: LocationAccuracy.high);
                            centerScreen(position);
                          },
                          child: Icon(Icons.location_searching),
                          backgroundColor: Colors.green[900],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: RaisedButton(
                      onPressed: () async {
                        DatabaseService(uid: widget.uid)
                            .updateUserStatus(!_online);
                        setState(() {
                          _online = !_online;
                          _status = _status == 'online' ? 'offline' : 'online';
                        });
                      },
                      color: _online ? Colors.green[900] : Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'You\'re $_status',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            )
          : Loading(),
    );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 18)),
    );
  }

  List<Marker> getMarkers(List<Location> locations) {
    var markers = List<Marker>();

    locations.forEach((location) {
      Marker marker = Marker(
        markerId: MarkerId(location.email),
        draggable: false,
        infoWindow: InfoWindow(title: location.email),
        position: LatLng(location.lat, location.lng),
      );
      markers.add(marker);
    });
    return markers;
  }

  Future<void> getPolylines(LatLng departure, LatLng destination) async {
    var routes = await googleMapsDirections.directionsWithLocation(
        directions.Location(departure.latitude, departure.longitude),
        directions.Location(destination.latitude, destination.longitude));
    print(routes.status);
    createRoute(routes.routes.first.overviewPolyline.points);
  }

  void createRoute(String encondedPoly) {
    setState(() {
      _polyLines.add(Polyline(
          polylineId: PolylineId('route1'),
          width: 8,
          points: _convertToLatLng(_decodePoly(encondedPoly)),
          color: Colors.blue[700]));
    });
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];
    return lList;
  }
}
