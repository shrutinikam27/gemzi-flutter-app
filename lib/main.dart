import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/get_started.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/explore_screen.dart';
import 'pages/homepage.dart';

// 🔥 IMPORT TRANSLATOR
import 'services/notification_service.dart';
import 'utils/translator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Load saved language (VERY IMPORTANT)
  await TranslatorService.loadLanguage();

  await NotificationService.init(); // 🔥 Initialize notifications

  // 🔥 Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gemzi",
      debugShowCheckedModeBanner: false,

      // ❌ Removed locale system (not needed now)

      // FIRST PAGE
      home: const SplashScreen(),

      routes: {
        "/get-started": (_) => const GetStartedPage(),
        "/home": (_) => GemziHome(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/explore": (_) => const ExploreScreen(),
      },
    );
  }
}
