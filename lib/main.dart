import 'package:ai_pencil/constants.dart';
import 'package:ai_pencil/screens/inference_screen.dart';
import 'package:ai_pencil/screens/select_screen.dart';
import 'package:ai_pencil/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupFirebase();
  setupLogging();
  runApp(const MainApp());
}

void setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void setupLogging() {
  // https://pub.dev/packages/logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ai Pencil',
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute: Routes.SELECT_SCREEN_ROUTE,
      routes: {
        Routes.SELECT_SCREEN_ROUTE: (context) => const SelectProjectScreen(),
        // Routes.DRAW_SCREEN_ROUTE: (context) => const DrawScreen(),
        Routes.INFERENCE_SCREEN_ROUTE: (context) => const InferenceScreen()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
