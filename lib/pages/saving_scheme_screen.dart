import 'package:flutter/material.dart';
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

  // 🔹 PAGE 2 (Plan Setup)
  Widget _buildPlanPage() {
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

            // 🔥 GOLD IMAGE ON TOP
            Image.asset(
              "assets/auth/coinsbag.png",
              height: 200,
            ),

            const SizedBox(height: 10),

            const TranslatedText(
              "Digital Gold SIP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 AMOUNT CARD (better UI)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A41),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const TranslatedText("Select Amount",
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  Text(
                    "₹$selectedAmount",
                    style: const TextStyle(
                      color: Color(0xFFE6C76A),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [50, 100, 150].map((e) {
                      bool isSelected = selectedAmount == e;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedAmount = e);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFE6C76A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "₹$e",
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 DROPDOWN CARD
            // 🔥 PLAN TYPE DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A41),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ],
              ),
              child: DropdownButton<String>(
                value: planType,
                dropdownColor: const Color(0xFF1A4A41),
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                underline: const SizedBox(),
                iconEnabledColor: const Color(0xFFE6C76A),
                items: ["Daily", "Weekly", "Monthly"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: TranslatedText(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    planType = val!;
                    duration =
                        durationOptions[planType]!.first; // reset duration
                  });
                },
              ),
            ),

            const SizedBox(height: 15),

// 🔥 DYNAMIC DURATION DROPDOWN
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4A41),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                  )
                ],
              ),
              child: DropdownButton<String>(
                value: duration,
                dropdownColor: const Color(0xFF1A4A41),
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                underline: const SizedBox(),
                iconEnabledColor: const Color(0xFFE6C76A),
                items: durationOptions[planType]!
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: TranslatedText(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => duration = val!);
                },
              ),
            ),

            const Spacer(),

            // 🔥 SAVE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE6C76A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 120, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmPlanScreen(
                      amount: selectedAmount,
                      planType: planType,
                      duration: duration,
                    ),
                  ),
                );
              },
              child: const TranslatedText(
                "SAVE",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
