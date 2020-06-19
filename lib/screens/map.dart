import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Map extends StatefulWidget {
  final Position initialPosition;
  Map({this.initialPosition});
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final GeolocatorService goeService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  MapType _currentMapType = MapType.hybrid;
  @override
  void initState() {
    goeService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Geo-Tracker'),
        backgroundColor: Colors.green[900],
      ),
      body: Center(
        child: Stack(children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialPosition.latitude,
                    widget.initialPosition.longitude),
                zoom: 30),
            mapType: _currentMapType,
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            myLocationButtonEnabled: false,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topRight,
              child: Column(
                children: <Widget>[
                  FloatingActionButton(
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
                    onPressed: () async {
                      Position position = await Geolocator().getCurrentPosition(
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
        ]),
      ),
    );
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 18)),
    );
  }
}
