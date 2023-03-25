import 'package:flutter/material.dart';

class CustomTheme {
  static var lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: appBar,
  );

  static var darkTheme = ThemeData(
    primarySwatch: Colors.amber,
    brightness: Brightness.dark,
    appBarTheme: appBar,
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    bottomAppBarTheme: bottomNavigationBar,
  );

  static const appBar = AppBarTheme(
    centerTitle: false,
    elevation: 2,
    backgroundColor: Colors.black12,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static const bottomNavigationBar = BottomAppBarTheme(
    color: Colors.black12,
    elevation: 2,
  );
}
