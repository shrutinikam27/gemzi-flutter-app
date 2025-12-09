import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_project/pages/success_screen.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/explore_screen.dart';
import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: "Gemzi",
      debugShowCheckedModeBanner: false,

      // Initial Page
      home: const SplashScreen(),
      // ROUTES
      routes: {
        "/home": (_) => HomePage(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/explore": (_) => const ExploreScreen(),
        // "/success": (_) => const SignupSuccessScreen(),
      },
    );
    return materialApp;
  }
}
