import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/cart_service.dart';

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/get_started.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/explore_screen.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Provider debug check for singleton
  Provider.debugCheckInvalidValueType = null;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Continue without Firebase or handle gracefully
  }

  final cartService = CartService()..init();
  runApp(
    ChangeNotifierProvider<CartService>.value(
      value: cartService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gemzi",
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/get-started": (_) => const GetStartedPage(),
        "/home": (_) => const GemziHome(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/explore": (_) => const ExploreScreen(),
      },
    );
  }
}
