import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemzi_user_app/services/notification_service.dart';
import 'package:gemzi_user_app/utils/translator_service.dart';
import 'package:provider/provider.dart';

import 'services/cart_service.dart';
import 'services/google_auth.dart'; // 🔥 IMPORTANT

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/get_started.dart';
import 'pages/login_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/explore_screen.dart';
import 'pages/homepage.dart';
import 'pages/exclusive_collections_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Provider debug check
  Provider.debugCheckInvalidValueType = null;

  // 🔥 Load saved language (VERY IMPORTANT)
  await TranslatorService.loadLanguage();

  await NotificationService.init(); // 🔥 Initialize notifications

  // 🔥 Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (may already be initialized): $e');
  }

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gemzi",
      debugShowCheckedModeBanner: false,

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

      // 🔥 START WITH SPLASH
      home: const SplashScreen(),

      routes: {
        "/get-started": (_) => const GetStartedPage(),
        "/home": (_) => const GemziHome(),
        "/login": (_) => const LoginScreen(),
        "/signup": (_) => const SignupScreen(),
        "/explore": (_) => ExploreScreen(),
        "/exclusive-collections": (_) => ExclusiveCollectionsPage(),
      },
    );
  }
}
