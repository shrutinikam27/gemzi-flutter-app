import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'services/cart_service.dart';
import 'services/google_auth.dart'; // 🔥 IMPORTANT
=======
import 'package:flutter/foundation.dart';
>>>>>>> f47d79d6dc6a919bd74ec40532cfcd3fccfe219b

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

<<<<<<< HEAD
  // Disable Provider debug check
  Provider.debugCheckInvalidValueType = null;
=======
  // 🔥 Load saved language (VERY IMPORTANT)
  //very good
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
>>>>>>> f47d79d6dc6a919bd74ec40532cfcd3fccfe219b

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥🔥🔥 TEMP FIX (VERY IMPORTANT)
  // Prevent auto-login → fixes splash + success screen issue
  await GoogleAuthService.signOut();
  await FirebaseAuth.instance.signOut();

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

<<<<<<< HEAD
  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

=======
>>>>>>> f47d79d6dc6a919bd74ec40532cfcd3fccfe219b
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gemzi",
      debugShowCheckedModeBanner: false,

<<<<<<< HEAD
      // 🌐 LANGUAGE CONFIG
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
=======
      // ❌ Removed locale system (not needed now)
>>>>>>> f47d79d6dc6a919bd74ec40532cfcd3fccfe219b

      // 🔥 START WITH SPLASH
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
