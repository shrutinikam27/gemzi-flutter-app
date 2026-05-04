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
  bool showDemoCoins = false; // Demo Toggle
  
  // Real-time stream for user-specific transactions
  Stream<QuerySnapshot>? _transactionsStream;
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

    _transactionsStream = FirebaseFirestore.instance
        .collection('vault_transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    _balanceSubscription = docRef.snapshots().listen((doc) {
      if (doc.exists) {
        double newBalance = (doc.data()?['walletBalance'] ?? 0.0).toDouble();
        if (mounted) {
          if (walletBalance < newBalance && !isBalanceLoading) {
            setState(() => showDemoCoins = false); // Priority to real balance
            _playPiggyBankAnimation();
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

  void _playPiggyBankAnimation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "PiggyDemo",
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                width: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // PIGGY BANK
                    Positioned(
                      bottom: 20,
                      child: ZoomIn(
                        duration: const Duration(milliseconds: 600),
                        child: Icon(Icons.savings, color: richGold, size: 140),
                      ),
                    ),
                    
                    // DROPPING COIN
                    Positioned(
                      top: 0,
                      child: FadeInDown(
                        from: 200,
                        duration: const Duration(seconds: 1),
                        child: Icon(Icons.monetization_on, color: richGold, size: 50),
                      ),
                    ),

                    // IMPACT GLOW (Delayed)
                    Positioned(
                      bottom: 80,
                      child: FadeIn(
                        delay: const Duration(milliseconds: 800),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: richGold.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    const TranslatedText("COIN STASHED!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
                    const SizedBox(height: 8),
                    Text("Digital Asset Secured in Vault", style: TextStyle(color: richGold, fontSize: 14, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: richGold),
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              )
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
        iconTheme: IconThemeData(color: richGold),
        title: TranslatedText("Payment Dashboard",
            style: TextStyle(color: richGold, fontWeight: FontWeight.bold)),
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

            const SizedBox(height: 25),

            /// 🪙 ANIMATED VAULT SHOWCASE
            FadeInUp(
              child: _buildVaultShowcase(),
            ),

            const SizedBox(height: 30),

            /// 📜 RECENT ACTIVITY
            _sectionHeader("Recent Vault Activity"),
            _buildVaultActivity(),

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

            /// 📖 HOW IT WORKS SECTION
            _sectionHeader("How to Store Gold"),
            _buildHowItWorks(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultActivity() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: surfaceDark.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: const Center(child: Text("No transactions yet", style: TextStyle(color: Colors.white24, fontSize: 12))),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            final dateStr = timestamp != null 
                ? "${timestamp.toDate().day}/${timestamp.toDate().month} ${timestamp.toDate().hour}:${timestamp.toDate().minute}" 
                : "Just now";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: surfaceDark.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: richGold.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(Icons.auto_graph_rounded, color: richGold, size: 18),
                ),
                title: Text(data["type"] ?? "Stashed", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("+ ${data["grams"]?.toStringAsFixed(4)}g", style: TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("₹${data["amount"]}", style: const TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _howItem("1", "Add Funds", "Top up your Gemzi wallet via UPI or Card."),
          _howItem("2", "Instant Conversion", "Your INR is instantly converted to 24K Gold grams."),
          _howItem("3", "Secure Storage", "Gold is stashed in our insured vault, visible as coins."),
        ],
      ),
    );
  }

  Widget _howItem(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: richGold, shape: BoxShape.circle),
            child: Text(step, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surfaceDark, surfaceDark.withValues(alpha: 0.8), Colors.black],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: richGold.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 25, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText("Digital Vault Balance",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline,
                              color: Colors.greenAccent, size: 10),
                          SizedBox(width: 4),
                          Text("SECURED BY GEMZI",
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.shield_moon_outlined, color: richGold, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          isBalanceLoading
            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹ ${walletBalance.toStringAsFixed(2)}", 
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.stars, color: richGold, size: 16),
                      const SizedBox(width: 6),
                      Text("≈ ${(walletBalance / (GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0)).toStringAsFixed(4)}g 24K Gold",
                          style: TextStyle(color: richGold, fontSize: 15, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
          const SizedBox(height: 30),
          Row(
            children: [
              _vaultAction(Icons.add_task_rounded, "Add Money", () => _showAddMoneyDialog(context)),
              const SizedBox(width: 12),
              _vaultAction(Icons.savings_rounded, "Test Stash", () => _playPiggyBankAnimation()),
              const SizedBox(width: 12),
              _vaultAction(Icons.auto_awesome_motion_rounded, "Demo", () {
                setState(() => showDemoCoins = !showDemoCoins);
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVaultShowcase() {
    int coinCount = showDemoCoins ? 10 : (walletBalance / 100).clamp(0, 15).toInt();
    if (walletBalance > 0 && coinCount == 0) coinCount = 1; // Always show at least 1 if balance exists
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: richGold.withValues(alpha: 0.1), width: 2),
            boxShadow: [
              BoxShadow(color: richGold.withValues(alpha: 0.05), blurRadius: 40)
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Shimmer
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.grid_3x3, color: richGold, size: 400),
                ),
              ),

              // THE VAULT CONTAINER (Glassy Container)
              Container(
                width: 200,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.02)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    children: [
                      if (coinCount == 0 && !showDemoCoins)
                        const Center(
                          child: TranslatedText("VAULT EMPTY", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2)),
                        ),
                      ...List.generate(coinCount, (index) {
                        return Positioned(
                          bottom: 15 + (index * 4),
                          left: 50 + (index % 3 * 35),
                          child: FadeInDown(
                            delay: Duration(milliseconds: index * 200),
                            duration: const Duration(seconds: 1),
                            child: ElasticIn(
                              delay: Duration(milliseconds: index * 100),
                              child: Icon(Icons.monetization_on, color: richGold, size: 45),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Scanner Line Animation (Static but looks techy)
              Positioned(
                top: 40,
                child: FadeInLeft(
                  duration: const Duration(seconds: 2),
                  child: Container(width: 220, height: 1, color: richGold.withValues(alpha: 0.3)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const TranslatedText("SECURE DIGITAL ASSET VAULT", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 3, fontWeight: FontWeight.bold)),
      ],
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
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: richGold, size: 18),
                const SizedBox(width: 8),
                TranslatedText(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: surfaceDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: richGold, size: 20),
              const SizedBox(width: 10),
              const TranslatedText("Buy Digital Gold"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TranslatedText("Enter the amount you wish to convert into 24K Gold.", style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                onChanged: (val) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: "0.00",
                  hintStyle: const TextStyle(color: Colors.white10),
                  prefixText: "₹ ",
                  prefixStyle: TextStyle(color: richGold, fontSize: 24),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: richGold.withValues(alpha: 0.3))),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: richGold)),
                ),
              ),
              const SizedBox(height: 15),
              if (controller.text.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.stars, color: richGold, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          "You will get ≈ ${(double.tryParse(controller.text) ?? 0 / (GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0)).toStringAsFixed(4)}g",
                          style: TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText("Cancel", style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: richGold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () async {
                double val = double.tryParse(controller.text) ?? 0;
                if (val > 0) {
                  Navigator.pop(context); // Close input dialog
                  
                  // 🔄 SHOW PROCESSING OVERLAY
                  _showProcessingOverlay(val);
                }
              },
              child: const TranslatedText("PROCEED TO BUY", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
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

  void _showProcessingOverlay(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFD4AF37)),
            const SizedBox(height: 20),
            const TranslatedText("Processing Payment...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    // Simulate Payment Delay
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      Navigator.pop(context); // Close processing overlay

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 🔥 INSTANT CREDIT FOR DEMO PURPOSES
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        
        // Calculate grams for logging
        double rate = GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0;
        double grams = amount / rate;

        // 1. Update User Balance
        await docRef.update({
          'walletBalance': FieldValue.increment(amount),
        });

        // 2. Log for Admin App visibility
        await FirebaseFirestore.instance.collection('vault_transactions').add({
          'userId': user.uid,
          'userEmail': user.email ?? 'Unknown',
          'amount': amount,
          'grams': grams,
          'type': 'Gold Stashed',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
        
        _showStatus("Payment Successful! ₹$amount added to Vault.");
      }
    });
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
