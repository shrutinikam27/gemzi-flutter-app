// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:math';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';
import '../services/gold_rate_service.dart';
import 'order_success_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/razorpay_service.dart';
import '../services/email_service.dart';

class ConfirmPlanScreen extends StatefulWidget {
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
  State<ConfirmPlanScreen> createState() => _ConfirmPlanScreenState();
}

class _ConfirmPlanScreenState extends State<ConfirmPlanScreen> {
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}'), backgroundColor: Colors.green),
    );

    int total = widget.amount * int.parse(widget.duration.split(" ")[0]);
    EmailService.sendPurchaseEmail(
      paymentId: response.paymentId ?? 'TXN_SUCCESS',
      items: [
        {
          'name': "${widget.planType} - ${widget.duration}",
          'quantity': 1,
          'price': total.toDouble(),
        }
      ],
      totalAmount: total.toDouble(),
      context: context,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).collection('investments').add({
        'planType': widget.planType,
        'duration': widget.duration,
        'amountPaid': total.toDouble(),
        'paymentId': response.paymentId ?? 'TXN_SUCCESS',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Pop the screen after successful payment
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }
  @override
  Widget build(BuildContext context) {
    int total = widget.amount * int.parse(widget.duration.split(" ")[0]);

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
                    color: Colors.white.withValues(alpha: 0.05),
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
                        color: Color.fromRGBO(0, 0, 0, 0.4),
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
                                _rowItem("Plan", widget.planType),
                                _rowItem("Amount", "₹${widget.amount}"),
                                _rowItem("Duration", widget.duration),
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
                        "${(widget.amount / GoldRateService.currentRate).toStringAsFixed(4)} grams",
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
                    color: Colors.white.withValues(alpha: 0.05),
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
                      horizontal: 100, // Reduced slightly to avoid overflow with loading
                      vertical: 16,
                    ),
                  ),
                  onPressed: _isLoading ? null : () async {
                    setState(() => _isLoading = true);
                    final user = FirebaseAuth.instance.currentUser;
                    String mobile = "9999999999";
                    String email = user?.email ?? "test@example.com";
                    
                    try {
                      await _razorpayService.openCheckout(
                        amount: total.toDouble(),
                        name: widget.planType,
                        description: "Investment for ${widget.planType} - ${widget.duration}",
                        contact: mobile,
                        email: email,
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  },
                  child: _isLoading 
                    ? const SizedBox(
                        width: 20, 
                        height: 20, 
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      )
                    : const TranslatedText(
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
