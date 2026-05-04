import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/translated_text.dart';
import 'package:animate_do/animate_do.dart';
import '../services/gold_rate_service.dart';
import 'dart:async';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;

  double walletBalance = 0.00;
  bool isBalanceLoading = true;
  List<Map<String, String>> savedCards = [
    {"name": "Visa Platinum", "number": "**** 4242", "type": "Visa"},
    {"name": "Mastercard Gold", "number": "**** 8899", "type": "Mastercard"},
  ];

  StreamSubscription<DocumentSnapshot>? _balanceSubscription;

  @override
  void initState() {
    super.initState();
    _listenToBalance();
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }

  void _listenToBalance() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("❌ ERROR: User not authenticated");
      setState(() => isBalanceLoading = false);
      return;
    }

    _balanceSubscription = FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().listen((doc) {
      if (doc.exists) {
        double newBalance = (doc.data()?['walletBalance'] ?? 0.0).toDouble();
        if (mounted) {
          if (walletBalance < newBalance && !isBalanceLoading) {
            _playGoldCoinAnimation();
          }
          setState(() {
            walletBalance = newBalance;
            isBalanceLoading = false;
          });
        }
      } else {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'walletBalance': 0.0,
        }, SetOptions(merge: true));
      }
    });
  }

  void _playGoldCoinAnimation() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        });
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeInDown(
                duration: const Duration(seconds: 1),
                child: const Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 100),
              ),
              FadeInUp(
                duration: const Duration(seconds: 1),
                child: const Icon(Icons.savings_outlined, color: Colors.white, size: 150),
              ),
              const SizedBox(height: 20),
              const Text("Digital Gold Stored!", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TranslatedText("Payment Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            /// 🏦 THE VAULT (Wallet)
            FadeInDown(
              child: _buildVaultCard(),
            ),

            const SizedBox(height: 30),

            /// 🃏 SAVED METHODS
            _sectionHeader("Your Saved Cards"),
            ...savedCards.map((card) => _buildPremiumCard(card)),

            const SizedBox(height: 25),

            /// 📱 UPI & DIGITAL
            _sectionHeader("Digital UPI"),
            _buildUPITile("Google Pay", "gemzi@okaxis", true),
            _buildUPITile("PhonePe", "gemzi@ybl", false),

            const SizedBox(height: 40),

            _buildAddNewButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: richGold.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TranslatedText("Digital Vault Balance", style: TextStyle(color: Colors.white54, fontSize: 12)),
              Icon(Icons.account_balance_wallet_outlined, color: richGold, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          isBalanceLoading
            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹ ${walletBalance.toStringAsFixed(2)}", 
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 5),
                  Text("≈ ${(walletBalance / (GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0)).toStringAsFixed(3)}g 24K Digital Gold",
                      style: TextStyle(color: richGold, fontSize: 14)),
                ],
              ),
          const SizedBox(height: 30),
          Row(
            children: [
              _vaultAction(Icons.add_rounded, "Top Up", () => _showAddMoneyDialog(context)),
              const SizedBox(width: 15),
              _vaultAction(Icons.history_rounded, "History", () {}),
            ],
          )
        ],
      ),
    );
  }

  Widget _vaultAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: richGold, size: 18),
              const SizedBox(width: 8),
              TranslatedText(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Row(
        children: [
          TranslatedText(title, style: TextStyle(color: richGold, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const Spacer(),
          const Icon(Icons.shield_outlined, color: Colors.white24, size: 14),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(Map<String, String> card) {
    return FadeInRight(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceDark.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(Icons.credit_card_rounded, color: richGold, size: 22),
          ),
          title: Text(card["name"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(card["number"]!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.white24),
            onPressed: () => _removeCard(card["name"]!),
          ),
        ),
      ),
    );
  }

  Widget _buildUPITile(String title, String upiId, bool isDefault) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white10, child: Text(title[0], style: TextStyle(color: richGold))),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(upiId, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: isDefault 
           ? const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 20)
           : const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
      ),
    );
  }

  Widget _buildAddNewButton() {
    return InkWell(
      onTap: () => _showAddMethodSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: richGold.withValues(alpha: 0.3), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: richGold),
            const SizedBox(width: 10),
            TranslatedText("Add New Payment Method", style: TextStyle(color: richGold, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // --- LOGIC ---

  void _removeCard(String name) {
    setState(() {
      savedCards.removeWhere((c) => c["name"] == name);
    });
    _showStatus("Card removed successfully.");
  }

  void _showAddMoneyDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: const TranslatedText("Add to Vault"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: "Amount ₹", hintStyle: const TextStyle(color: Colors.white24), prefixText: "₹ ", prefixStyle: TextStyle(color: richGold)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText("Cancel")),
          ElevatedButton(
            onPressed: () async {
              double val = double.tryParse(controller.text) ?? 0;
              if (val > 0) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('topup_requests').add({
                    'userId': user.uid,
                    'amount': val,
                    'status': 'pending',
                    'timestamp': FieldValue.serverTimestamp(),
                    'userEmail': user.email ?? 'Unknown User',
                  });
                }
                
                Navigator.pop(context);
                _showStatus("Payment request of ₹$val sent to Admin for approval.");
              }
            },
            child: const TranslatedText("Confirm"),
          )
        ],
      ),
    );
  }

  void _showAddMethodSheet(BuildContext context) {
     showModalBottomSheet(
      context: context,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TranslatedText("Select Method Type", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),
            ListTile(leading: Icon(Icons.credit_card, color: richGold), title: const TranslatedText("Credit/Debit Card"), onTap: () => Navigator.pop(context)),
            ListTile(leading: Icon(Icons.qr_code, color: richGold), title: const TranslatedText("UPI / Wallet"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }

  void _showStatus(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: richGold, 
        behavior: SnackBarBehavior.floating, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
      ),
    );
  }
}
