import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'homepage.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: Stack(
        children: [
          // ----------- BACKGROUND IMAGE -----------
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("assets/auth/gs.png"), // 🔥 your jewellery image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ----------- TOP GRADIENT -----------
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          // ----------- SKIP BUTTON -----------
          Positioned(
            top: 45,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // ----------- MAIN CONTENT -----------
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
              height: MediaQuery.of(context).size.height * 0.43,
              decoration: const BoxDecoration(
                color: AppColors.lightBeige,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Jewelry",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleBrown,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Find your dream jewellery",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.subtitleBrown,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ----------- LOGIN BUTTON -----------
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.titleBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ----------- REGISTER BUTTON -----------
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
