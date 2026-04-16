// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'confirm_plan_screen.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';

class SavingSchemeScreen extends StatefulWidget {
  const SavingSchemeScreen({super.key});

  @override
  State<SavingSchemeScreen> createState() => _SavingSchemeScreenState();
}

class _SavingSchemeScreenState extends State<SavingSchemeScreen> {
  final PageController _controller = PageController();

  int selectedAmount = 100;
  String planType = "Monthly";
  String duration = "3 Months";

  Map<String, List<String>> durationOptions = {
    "Daily": ["7 Days", "15 Days", "30 Days"],
    "Weekly": ["1 Week", "2 Weeks", "4 Weeks"],
    "Monthly": ["3 Months", "6 Months", "12 Months"],
  };

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang), // 🔥 important
      child: Scaffold(
        backgroundColor: const Color(0xFF0F3D36),
        body: PageView(
          controller: _controller,
          children: [
            _buildIntroPage(),
            _buildPlanPage(),
          ],
        ),
      ),
    );
  }

  // 🔹 PAGE 1 (Intro)
  Widget _buildIntroPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 IMAGE ON TOP
            Image.asset(
              "assets/auth/gold2.png",
              height: 400,
              width: 500,
            ),

            const SizedBox(height: 30),

            const TranslatedText(
              "Secure Your Future with",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 10),

            const TranslatedText(
              "Digital Gold Savings",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFE6C76A),
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Column(
              children: const [
                TranslatedText(
                  "Daily, Weekly & Monthly plans",
                  style: TextStyle(color: Colors.white60, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                TranslatedText(
                  "24K pure gold investment",
                  style: TextStyle(color: Colors.white60, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                TranslatedText(
                  "Safe & Easy withdrawal",
                  style: TextStyle(color: Colors.white60, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C76A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
              onPressed: () {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: const TranslatedText(
                "NEXT",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _seedSchemes() async {
    final schemes = FirebaseFirestore.instance.collection('schemes');
    await schemes.add({'name': 'Daily Gold', 'type': 'Daily', 'active': true});
    await schemes.add({'name': 'Weekly Savings', 'type': 'Weekly', 'active': true});
    await schemes.add({'name': 'Monthly SIP', 'type': 'Monthly', 'active': true});
  }

  // 🔹 PAGE 2 (Plan Setup)
  Widget _buildPlanPage() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('schemes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE6C76A)));
        }
        
        final schemes = snapshot.data!.docs;
        if (schemes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TranslatedText("No schemes available yet.", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _seedSchemes,
                  child: const Text("Initialize Sample Schemes"),
                )
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset("assets/auth/coinsbag.png", height: 200),
                const SizedBox(height: 10),
                const TranslatedText("Digital Gold SIP", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                // AMOUNT SELECTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFF1A4A41), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10)]),
                  child: Column(
                    children: [
                      const TranslatedText("Select Amount", style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 10),
                      Text("₹$selectedAmount", style: const TextStyle(color: Color(0xFFE6C76A), fontSize: 30, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [50, 100, 150].map((e) {
                          bool isSelected = selectedAmount == e;
                          return GestureDetector(
                            onTap: () => setState(() => selectedAmount = e),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(color: isSelected ? const Color(0xFFE6C76A) : Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Text("₹$e", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // DYNAMIC SCHEMES DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: const Color(0xFF1A4A41), borderRadius: BorderRadius.circular(15)),
                  child: DropdownButton<String>(
                    value: schemes.any((s) => s['name'] == planType) ? planType : schemes.first['name'],
                    dropdownColor: const Color(0xFF1A4A41),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    underline: const SizedBox(),
                    iconEnabledColor: const Color(0xFFE6C76A),
                    items: schemes.map((s) {
                      final sData = s.data() as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: sData['name'] as String,
                        child: Text("${sData['name']} (${sData['type']})"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => planType = val!),
                  ),
                ),
                
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE6C76A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 16)),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ConfirmPlanScreen(amount: selectedAmount, planType: planType, duration: "Selected Plan")));
                  },
                  child: const TranslatedText("SAVE", style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
