import 'package:flutter/material.dart';
import 'get_started.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // SAME COLORS AS HOMEPAGE
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();

    // Minimum splash duration = 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const GetStartedPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // GEMZI GRADIENT BACKGROUND
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBg, surfaceDark, darkBg],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/auth/gemzi_logo.png",
                height: 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // LOADING INDICATOR
              CircularProgressIndicator(
                color: richGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
