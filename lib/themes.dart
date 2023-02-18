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
      ),
    ),
  );

  static const appBar = AppBarTheme(
    centerTitle: false,
    elevation: 2,
    backgroundColor: Colors.black12,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
  );
}
