import 'package:ai_pencil/model/image/types.dart';
import 'package:ai_pencil/screens/inference_complete_screen.dart';
import 'package:ai_pencil/screens/landing_screen.dart';
import 'package:ai_pencil/screens/premium_screen.dart';
import 'package:ai_pencil/utils/constants.dart';
import 'package:ai_pencil/screens/select_screen.dart';
import 'package:ai_pencil/utils/event_analytics.dart';
import 'package:ai_pencil/utils/prompt_styles_manager.dart';
import 'package:ai_pencil/utils/shared_preference.dart';
import 'package:ai_pencil/utils/themes.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logging/logging.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupFirebase();
  setupLogging();
  setupPromptStyles();

  MixPanelAnalyticsManager
      .init(); // Singleton initiation to start collecting general events
  await SharedPreferenceHelper
      .init(); // Singleton initiation for shared preferences
  runApp(const MainApp());
}

void setupFirebase() async {
  if (kDebugMode) {
    return;
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
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
      darkTheme: CustomTheme.darkTheme,
      themeMode: ThemeMode.dark,
      initialRoute:
          kIsWeb ? Routes.LANDING_SCREEN_ROUTE : Routes.SELECT_SCREEN_ROUTE,
      routes: {
        Routes.SELECT_SCREEN_ROUTE: (context) => const SelectProjectScreen(),
        Routes.LANDING_SCREEN_ROUTE: (context) => const LandingScreen(),
        Routes.INFERENCE_COMPLETE_SCREEN_ROUTE: (context) =>
            InferenceCompleteScreen(
              imageBytes: PngImageBytes.fromList([]),
              prompt: "Test",
              onAddImageAsLayer: (imageBytes, title) {},
              onRetryInference: (imageBytes) {},
            ),
        Routes.PREMIUM_SCREEN_ROUTE: (context) => const PremiumScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
