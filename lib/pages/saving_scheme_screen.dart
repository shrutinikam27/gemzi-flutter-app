// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'confirm_plan_screen.dart';
import 'login_screen.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';
import '../services/gold_rate_service.dart';

class SavingSchemeScreen extends StatefulWidget {
  const SavingSchemeScreen({super.key});

  @override
  State<SavingSchemeScreen> createState() => _SavingSchemeScreenState();
}

class _SavingSchemeScreenState extends State<SavingSchemeScreen> {
  int selectedAmount = 2000;
  String planType = "Monthly SIP";
  double currentRate = GoldRateService.currentRate;

  void _playGoldCoinAnimation() {
    debugPrint("🎬 Starting Gold Coin Animation...");
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        });
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SlideInDown(
                from: 100,
                duration: const Duration(milliseconds: 800),
                child: const Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 100),
              ),
              const SizedBox(height: 10),
              BounceInUp(
                duration: const Duration(milliseconds: 1000),
                child: const Icon(Icons.savings_outlined, color: Colors.white, size: 160),
              ),
              const SizedBox(height: 30),
              FadeIn(
                delay: const Duration(milliseconds: 500),
                child: const Text(
                  "Digital Gold Stored!", 
                  style: TextStyle(
                    color: Color(0xFFD4AF37), 
                    fontSize: 26, 
                    fontWeight: FontWeight.bold, 
                    decoration: TextDecoration.none,
                    letterSpacing: 1.2
                  )
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: StreamBuilder<double>(
        stream: GoldRateService.goldRateStream(),
        builder: (context, rateSnapshot) {
          if (rateSnapshot.hasData) {
            currentRate = rateSnapshot.data!;
          }
          return Scaffold(
            backgroundColor: const Color(0xFF0F3D36),
            body: _buildSinglePageProcess(),
          );
        }
      ),
    );
  }

  // 🔹 ONE-PAGE GOLD PURCHASE PROCESS
  Widget _buildSinglePageProcess() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('schemes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE6C76A)));
        }
        
        final schemes = snapshot.data?.docs ?? [];

        return SafeArea(
          child: Column(
            children: [
              // 🔝 TOP NAV & SECURITY BADGE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.green, size: 14),
                          SizedBox(width: 5),
                          Text("INSURED VAULTS", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔥 LIVE PRICE CARD
                      FadeInDown(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFFE6C76A).withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const TranslatedText("Live 24K Price", style: TextStyle(color: Colors.white70)),
                              Text("₹${currentRate.toStringAsFixed(2)} / gm", style: const TextStyle(color: Color(0xFFE6C76A), fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const TranslatedText(
                        "Digital Gold Boutique",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const TranslatedText(
                        "Instant conversion to 24K Gold Grams",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),

                      const SizedBox(height: 25),

                      // AMOUNT SELECTOR
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A4A41),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
                        ),
                        child: Column(
                          children: [
                            const TranslatedText("Buying Amount (₹)", style: TextStyle(color: Colors.white60, fontSize: 14)),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _amountBtn(Icons.remove, () { if (selectedAmount > 100) setState(() => selectedAmount -= 100); }),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text("₹$selectedAmount", style: const TextStyle(color: Color(0xFFE6C76A), fontSize: 36, fontWeight: FontWeight.bold)),
                                ),
                                _amountBtn(Icons.add, () { setState(() => selectedAmount += 100); }),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_fix_high, color: Color(0xFFE6C76A), size: 14),
                                const SizedBox(width: 8),
                                Text(
                                  "Accumulate ${(selectedAmount / currentRate).toStringAsFixed(4)} grams of Gold",
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // STRATEGY SELECTOR
                      const TranslatedText("Choose Strategy", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: schemes.isEmpty ? 2 : schemes.length,
                          itemBuilder: (context, index) {
                            String name;
                            if (schemes.isEmpty) {
                              name = index == 0 ? "Monthly SIP" : "Gold Saver";
                            } else {
                              final sData = schemes[index].data() as Map<String, dynamic>;
                              name = sData['name'] ?? "Scheme";
                            }
                            
                            bool isSelected = planType == name;
                            return GestureDetector(
                              onTap: () => setState(() => planType = name),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(18),
                                margin: const EdgeInsets.only(right: 15),
                                width: 150,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFE6C76A) : Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? Colors.white : Colors.white12),
                                ),
                                child: Center(
                                  child: Text(
                                    name,
                                    style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      // SECURITY NOTES
                      _benefitRow(Icons.security, "Money converted to Gold Grams instantly"),
                      _benefitRow(Icons.lock_clock, "No price change impacts once bought"),
                      _benefitRow(Icons.workspace_premium, "Pure 24K 99.9% Hallmark Gold Coins"),

                      const TranslatedText("Your Active Investments", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      _buildWalletHistory(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // 💳 ACTION BUTTON
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A4A41),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6C76A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please login to proceed with investment")),
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmPlanScreen(amount: selectedAmount, planType: planType, duration: "12 Months"),
                        ),
                      );
                    },
                    child: const TranslatedText("PROCEED TO SECURE BUY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _amountBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE6C76A), size: 16),
          const SizedBox(width: 12),
          Expanded(child: TranslatedText(text, style: const TextStyle(color: Colors.white60, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildWalletHistory() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: TranslatedText("Please login to view history", style: TextStyle(color: Colors.white54)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('investments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE6C76A)));
        }

        final investments = snapshot.data?.docs ?? [];
        if (investments.isEmpty) {
          // Return a dummy card for demonstration
          return GestureDetector(
            onTap: _playGoldCoinAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6C76A).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6C76A).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: Color(0xFFE6C76A)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Monthly SIP (Demo)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("12 Months Plan", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹2000", style: TextStyle(color: Color(0xFFE6C76A), fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text("Sample", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: investments.length,
          itemBuilder: (context, index) {
            final data = investments[index].data() as Map<String, dynamic>;
            final plan = data['planType'] ?? 'SIP';
            final duration = data['duration'] ?? '12 Months';
            final amount = data['amountPaid'] ?? 0;
            
            return GestureDetector(
              onTap: _playGoldCoinAnimation,
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE6C76A).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6C76A).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFE6C76A)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(duration.toString(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹$amount", style: const TextStyle(color: Color(0xFFE6C76A), fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        const TranslatedText("Active", style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
