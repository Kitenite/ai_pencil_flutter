import 'package:flutter/material.dart';

class CustomTheme {
  static var lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: CustomTheme.appBar,
  );

  static var darkTheme = ThemeData(
    primarySwatch: Colors.amber,
    brightness: Brightness.dark,
    appBarTheme: CustomTheme.appBar,
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );

  static const appBar = AppBarTheme(
    centerTitle: false,
    elevation: 2,
    surfaceTintColor: Colors.black87,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  );
}
