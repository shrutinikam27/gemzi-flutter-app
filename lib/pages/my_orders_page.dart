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
                          Icon(Icons.shopping_bag_outlined, color: richGold.withValues(alpha: 0.3), size: 80),
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
                      final vaultAmountUsed = (data['vaultAmountUsed'] ?? 0.0).toDouble();
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
                          border: Border.all(color: richGold.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))
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
                            if (vaultAmountUsed > 0) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const TranslatedText("Vault Applied", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  Text("-₹${vaultAmountUsed.toStringAsFixed(0)}", style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TranslatedText(
                                        vaultAmountUsed > 0 ? "Net Amount Paid" : "Total Amount",
                                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                                      ),
                                      Text("₹$totalAmount", style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == 'pending'
                                        ? Colors.amber.withValues(alpha: 0.1)
                                        : status == 'cancelled'
                                            ? Colors.red.withValues(alpha: 0.1)
                                            : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toString().toUpperCase(),
                                    style: TextStyle(
                                      color: status == 'pending'
                                          ? Colors.amberAccent
                                          : status == 'cancelled'
                                              ? Colors.redAccent
                                              : Colors.greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (status == 'pending') ...[
                              const Divider(color: Colors.white10, height: 20),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _cancelOrder(context, orderId, vaultAmountUsed),
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                                  label: const TranslatedText(
                                    "Cancel Order",
                                    style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
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

  Future<void> _cancelOrder(BuildContext context, String orderId, double vaultAmountUsed) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF17453F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TranslatedText("Cancel Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const TranslatedText("Are you sure you want to cancel this order? The used vault balance will be refunded.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TranslatedText("No", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const TranslatedText("Yes, Cancel", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
      ),
    );

    try {
      // 1. Update user order status to 'cancelled'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderId)
          .update({'status': 'cancelled'});

      // 2. Update global order status to 'cancelled'
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': 'cancelled'});

      // 3. Restore vault amount if any was used
      if (vaultAmountUsed > 0) {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await docRef.update({
          'walletBalance': FieldValue.increment(vaultAmountUsed),
        });

        // 4. Log transaction in vault_transactions
        await FirebaseFirestore.instance.collection('vault_transactions').add({
          'userId': user.uid,
          'userEmail': user.email ?? 'Unknown',
          'amount': vaultAmountUsed,
          'grams': vaultAmountUsed / 7500.0, // rough estimation
          'type': 'Gold Restored (Order $orderId Cancelled)',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TranslatedText('Order cancelled successfully'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel order: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }
}
