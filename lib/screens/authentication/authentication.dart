import 'package:flutter/material.dart';
import 'package:geo_tracker/screens/authentication/sign_in.dart';
import 'package:geo_tracker/screens/authentication/sign_up.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  final GeolocatorService goeService = GeolocatorService();
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => goeService.getInitialLocation(),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Consumer<Position>(
          builder: (contex, position, widget) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/earth.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: showSignIn
                    ? SignIn(initialPosition: position, toggleView: toggleView)
                    : SignUp(initialPosition: position, toggleView: toggleView),
              ),
            );
          },
        ),
      ),
    );
  }
}
