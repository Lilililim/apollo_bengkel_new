import 'package:flutter/material.dart';

var buttonColor = 0xff24AADF;

var themeData = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  backgroundColor: Colors.blue,
  textTheme: TextTheme(
    button: TextStyle(
      color: Colors.white,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      primary: Color(buttonColor),
    ),
  ),
  buttonColor: Color(buttonColor),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: MaterialStateProperty.all(
        TextStyle(
          color: Colors.white,
        ),
      ),
      foregroundColor: MaterialStateProperty.all(
        Color(
          buttonColor,
        ),
      ),
    ),
  ),
);
