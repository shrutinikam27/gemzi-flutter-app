import 'package:flutter/material.dart';
import 'login_screen.dart'; // ✅ ADD THIS

class SignupSuccessScreen extends StatefulWidget {
  const SignupSuccessScreen({super.key});

  @override
  State<SignupSuccessScreen> createState() => _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends State<SignupSuccessScreen> {
  @override
  void initState() {
    super.initState();

    print("🔥 SUCCESS SCREEN OPENED"); // debug

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2F2B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 100, color: Color(0xFFD4AF37)),
            SizedBox(height: 20),
            Text(
              "Account Created Successfully!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome to Gemzi ✨",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }
}
