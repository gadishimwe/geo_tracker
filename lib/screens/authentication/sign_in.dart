import 'package:flutter/material.dart';
import 'package:geo_tracker/services/auth.dart';
import 'package:geo_tracker/services/geolocator.dart';
import 'package:geo_tracker/shared/constant.dart';
import 'package:geolocator/geolocator.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  final Position initialPosition;
  SignIn({this.initialPosition, this.toggleView});
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GeolocatorService geolocatorService = GeolocatorService();
  @override
  void initState() {
    geolocatorService.checkService();
    super.initState();
  }

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  String email = '';
  String password = '';
  String error = '';
  Future _getCurrentLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.png'),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              'Geo Locator',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
                fontSize: 36,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: textInputDecoration.copyWith(labelText: 'Email'),
                  onChanged: (value) => setState(() => email = value),
                  validator: (value) => value.isEmpty ||
                          !value.contains('@') ||
                          !value.contains('.')
                      ? 'Enter a valid email'
                      : null,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  decoration:
                      textInputDecoration.copyWith(labelText: 'Password'),
                  onChanged: (value) => setState(() => password = value),
                  validator: (value) => value.length < 6
                      ? 'Password must be 6 charactors long'
                      : null,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  error,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: RaisedButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() => loading = true);
                        Position position = await _getCurrentLocation();
                        dynamic result = await _authService.signIn(email,
                            password, position.latitude, position.longitude);
                        if (result == null) {
                          setState(() {
                            error =
                                'Incorrect email or password, please try again.';
                            loading = false;
                          });
                        }
                      }
                    },
                    color: Colors.green[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlineButton(
                    onPressed: widget.toggleView,
                    color: Colors.green[900],
                    borderSide: BorderSide(color: Colors.green[900]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text('by Gad Ishimwe'),
                Text('email: coolshigad@gmail.com'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
