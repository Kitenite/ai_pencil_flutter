import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTheme {
  static var lightTheme = ThemeData(
    brightness: Brightness.light,
    appBarTheme: appBar,
  );

  static var primaryColor = Colors.amber;

  static var darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: CustomTheme.primaryColor,
    primaryColor: CupertinoColors.darkBackgroundGray,
    primaryColorBrightness: Brightness.dark,
    accentColor: CupertinoColors.activeBlue,
    accentColorBrightness: Brightness.dark,
    scaffoldBackgroundColor: CupertinoColors.darkBackgroundGray,
    backgroundColor: CupertinoColors.darkBackgroundGray,
    indicatorColor: CupertinoColors.activeBlue,
    dialogBackgroundColor: CupertinoColors.darkBackgroundGray,
    dividerColor: Colors.grey[600],
    popupMenuTheme: cupertinoPopupMenuTheme,
    // primarySwatch: CustomTheme.primaryColor,
    // brightness: Brightness.dark,
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
    outlinedButtonTheme: cupertinoOutlinedButtonTheme,
    bottomSheetTheme: cupertinoBottomSheetTheme,
  );

  static const appBar = AppBarTheme(
    centerTitle: false,
    elevation: 2,
    backgroundColor: Colors.black45,
    titleTextStyle: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );

  static final PopupMenuThemeData cupertinoPopupMenuTheme = PopupMenuThemeData(
    color: CupertinoColors.darkBackgroundGray,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 8,
    textStyle: const TextStyle(
      fontSize: 16,
      color: CupertinoColors.white,
      fontWeight: FontWeight.w400,
    ),
  );

  static final OutlinedButtonThemeData cupertinoOutlinedButtonTheme =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: CustomTheme.primaryColor,
            width: 2,
          ),
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(
        CupertinoColors.darkBackgroundGray,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        CustomTheme.primaryColor,
      ),
      overlayColor: MaterialStateProperty.all<Color>(
        CupertinoColors.systemGrey3,
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        const Size(0, 36),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 16),
      ),
      side: MaterialStateProperty.all<BorderSide>(
        BorderSide.none,
      ),
    ),
  );

  static final BottomSheetThemeData cupertinoBottomSheetTheme =
      BottomSheetThemeData(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    backgroundColor: CupertinoColors.darkBackgroundGray,
    modalBackgroundColor: CupertinoColors.darkBackgroundGray,
    elevation: 8,
    modalElevation: 8,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    modalBarrierColor: CupertinoColors.black.withOpacity(0.4),
    // isDismissible: true,
    // enableDrag: true,
  );
}
