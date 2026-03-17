import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/get_started.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/explore_screen.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // print('Firebase initialized successfully');
  } catch (e) {
    // print('Firebase initialization error: $e');
    // Continue without Firebase or handle gracefully
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
