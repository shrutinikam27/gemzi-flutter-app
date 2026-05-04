import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/translated_text.dart';
import '../utils/translator_service.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

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
          title: const TranslatedText("My Product Orders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: user == null
            ? const Center(child: TranslatedText("Please login to view your orders", style: TextStyle(color: Colors.white70)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('orders')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: richGold));
                  }
                  
                  final orders = snapshot.data?.docs ?? [];

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined, color: richGold.withOpacity(0.3), size: 80),
                          const SizedBox(height: 20),
                          const TranslatedText("No orders placed yet", style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final data = orders[index].data() as Map<String, dynamic>;
                      final items = data['items'] as List? ?? [];
                      final totalAmount = data['totalAmount'] ?? 0;
                      final status = data['status'] ?? 'pending';
                      final orderId = data['orderId'] ?? 'ORD-XXXX';
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text("ID: $orderId", style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 8),
                                Text(date, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "${item['name']} x${item['quantity']}",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            )).toList(),
                            const Divider(color: Colors.white10, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const TranslatedText("Total Amount", style: TextStyle(color: Colors.white38, fontSize: 10)),
                                      Text("₹$totalAmount", style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'pending' ? Colors.amber.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toString().toUpperCase(),
                                    style: TextStyle(
                                      color: status == 'pending' ? Colors.amberAccent : Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
