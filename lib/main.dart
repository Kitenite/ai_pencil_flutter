import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/screens/inference_complete_screen.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/screens/select_screen.dart';
import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/utils/themes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupFirebase();
  setupLogging();
  setupPromptStyles();
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

void setupPromptStyles() async {
  PromptStylesManager.getInstance().initialize();
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
        Routes.INFERENCE_COMPLETE_SCREEN_ROUTE: (context) =>
            InferenceCompleteScreen(
              imageBytes: PngImageBytes.fromList([]),
              prompt: "Test",
              onAddImageAsLayer: (imageBytes, title) {},
              onRetryInference: (imageBytes) {},
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
