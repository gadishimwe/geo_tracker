import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
  filled: true,
  fillColor: Colors.white,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: Colors.grey,
    width: 1,
  )),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: Colors.grey,
    width: 1,
  )),
  errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: Colors.red,
    width: 1,
  )),
  focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
    color: Colors.red,
    width: 1,
  )),
);
