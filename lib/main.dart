import 'package:flutter/material.dart';
import 'package:geo_tracker/models/user.dart';
import 'package:geo_tracker/screens/wrapper.dart';
import 'package:geo_tracker/services/auth.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Geo-Locator',
        theme: ThemeData(
          primaryColor: Colors.green[900],
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Wrapper(),
      ),
    );
  }
}
