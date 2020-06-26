import 'package:flutter/material.dart';
import 'package:geo_tracker/models/location.dart';
import 'package:geo_tracker/models/user.dart';
import 'package:geo_tracker/screens/authentication/authentication.dart';
import 'package:geo_tracker/screens/home/map.dart';
import 'package:geo_tracker/services/database.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geo_tracker/shared/loading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  final GeolocatorService goeService = GeolocatorService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      // return Authenticate();
      return Authenticate();
    } else {
      return FutureProvider(
        create: (context) => goeService.getInitialLocation(),
        child: Consumer<Position>(builder: (contex, position, widget) {
          return position != null
              ? StreamProvider<List<Location>>.value(
                  value: DatabaseService().locations,
                  child: Maps(initialPosition: position, uid: user.uid))
              : Loading();
        }),
      );
    }
  }
}
