import 'package:flutter/material.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';

class ConfirmPlanScreen extends StatelessWidget {
  final int amount;
  final String planType;
  final String duration;

  const ConfirmPlanScreen({
    super.key,
    required this.amount,
    required this.planType,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    int total = amount * int.parse(duration.split(" ")[0]);

    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F3D36),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔙 BACK BUTTON
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔰 ICON
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Color(0xFFE6C76A),
                    size: 40,
                  ),
                ),

                const SizedBox(height: 20),

                const TranslatedText(
                  "Confirm Your Investment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const TranslatedText(
                  "Please review your plan details before proceeding to payment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 30),

                // 🔥 MAIN CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A4A41),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      // IMAGE + DETAILS
                      Row(
                        children: [
                          Image.asset(
                            "assets/auth/gold2.png",
                            height: 80,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _rowItem("Plan", planType),
                                _rowItem("Amount", "₹$amount"),
                                _rowItem("Duration", duration),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(color: Colors.white24, height: 30),

                      _rowItem(
                        "Total Investment",
                        "₹$total",
                        isHighlight: true,
                      ),

                      const SizedBox(height: 10),

                      _rowItem(
                        "Estimated Gold",
                        "~0.15 grams",
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔐 RAZORPAY INFO
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lock, color: Color(0xFFE6C76A)),
                      SizedBox(width: 10),
                      TranslatedText(
                        "100% Secure Payment with Razorpay",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 💳 BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6C76A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 120,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    // 👉 Razorpay integration here
                  },
                  child: const TranslatedText(
                    "Proceed to Pay",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 10),

                const TranslatedText(
                  "Auto payments will be deducted at the chosen frequency.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Helper Widget
  Widget _rowItem(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TranslatedText(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value, // ✅ dynamic values NOT translated
            style: TextStyle(
              color: isHighlight ? const Color(0xFFE6C76A) : Colors.white,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
