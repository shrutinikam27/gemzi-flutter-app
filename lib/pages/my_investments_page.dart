import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/translated_text.dart';
import '../utils/translator_service.dart';

class MyInvestmentsPage extends StatelessWidget {
  const MyInvestmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F2F2B);
    const Color surfaceDark = Color(0xFF17453F);
    const Color richGold = Color(0xFFD4AF37);

    final user = FirebaseAuth.instance.currentUser;

    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: surfaceDark,
          title: const TranslatedText("My Investments", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: user == null
            ? const Center(child: TranslatedText("Please login to view your investments", style: TextStyle(color: Colors.white70)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('investments')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: richGold));
                  }
                  
                  final investments = snapshot.data?.docs ?? [];

                  if (investments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_outlined, color: richGold.withOpacity(0.3), size: 80),
                          const SizedBox(height: 20),
                          const TranslatedText("No active investments yet", style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: investments.length,
                    itemBuilder: (context, index) {
                      final data = investments[index].data() as Map<String, dynamic>;
                      final plan = data['planType'] ?? 'Monthly SIP';
                      final amount = data['amountPaid'] ?? 0;
                      final duration = data['duration'] ?? '12 Months';
                      final date = data['timestamp'] != null 
                          ? (data['timestamp'] as Timestamp).toDate().toString().split(' ')[0] 
                          : 'Recent';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: richGold.withOpacity(0.1)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: richGold.withOpacity(0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.stars_rounded, color: richGold),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plan, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text("Plan Duration: $duration", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text("Invested on: $date", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("₹$amount", style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                const TranslatedText("ACTIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
