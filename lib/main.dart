import 'package:ai_pencil/screens/drawing_page.dart';
import 'package:ai_pencil/screens/select_screen.dart';
import 'package:ai_pencil/themes.dart';
import 'package:flutter/material.dart';

// TODO: separate into constant file
class Routes {
  static const SELECT_SCREEN_ROUTE = "select";
  static const DRAW_SCREEN_ROUTE = "draw";
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai Pencil',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.DRAW_SCREEN_ROUTE,
      routes: {
        Routes.SELECT_SCREEN_ROUTE: (context) => const SelectProjectScreen(),
        // Routes.DRAW_SCREEN_ROUTE: (context) => const DrawScreen(),
        Routes.DRAW_SCREEN_ROUTE: (context) => const DrawingPage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
