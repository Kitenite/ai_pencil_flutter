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
    bottomAppBarColor: Colors.black26,
    dialogTheme: const DialogTheme(
      backgroundColor: Color.fromARGB(255, 41, 41, 41),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
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
      color: Colors.white,
    ),
  );
}
