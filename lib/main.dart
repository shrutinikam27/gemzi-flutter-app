import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/services/notification_service.dart';
import 'package:flutter_project/utils/translator_service.dart';
import 'package:provider/provider.dart';

import 'services/cart_service.dart';
import 'services/google_auth.dart'; // 🔥 IMPORTANT

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/get_started.dart';
import 'pages/admin_login_screen.dart';
import 'screens/admin/admin_navigation_screen.dart';
import 'screens/admin/jewellery_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable Provider debug check
  Provider.debugCheckInvalidValueType = null;

  // 🔥 Load saved language (VERY IMPORTANT)
  //very good
  await TranslatorService.loadLanguage();

  await NotificationService.init(); // 🔥 Initialize notifications

  // 🔥 Initialize Firebase (only once)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error (may already be initialized): $e');
  }

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

      // 🔥 START WITH ADMIN LOGIN FOR GEMZI ADMIN
      home: const AdminLoginScreen(),

      routes: {
        "/login": (_) => const AdminLoginScreen(),
        "/admin-home": (_) => const AdminNavigationScreen(),
      },
    );
  }
}
