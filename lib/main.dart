import 'package:flutter/material.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.dark,
      initialRoute: Routes.SELECT_SCREEN_ROUTE,
      routes: {
        Routes.SELECT_SCREEN_ROUTE: (context) => const SelectProjectScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class SelectProjectScreen extends StatefulWidget {
  const SelectProjectScreen({super.key});

  @override
  State<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends State<SelectProjectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Ai Pencil",
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Hello"),
          ],
        ),
      ),
    );
  }
}
