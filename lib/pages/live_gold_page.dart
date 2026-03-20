import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../services/gold_rate_service.dart';

class LiveGoldPage extends StatefulWidget {
  const LiveGoldPage({super.key});

  @override
  State<LiveGoldPage> createState() => _LiveGoldPageState();
}

class _LiveGoldPageState extends State<LiveGoldPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color bronze = const Color(0xFFB8962E);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  double rate24 = 0;
  double rate22 = 0;

  double prev24 = 0;
  double prev22 = 0;

  Timer? timer;

  void loadGoldRate() async {
    try {
      var rates = await GoldRateService.getGoldRate();

      setState(() {
        prev24 = rate24;
        prev22 = rate22;

        rate24 = rates;
        rate22 = rates * (22 / 24);
      });
    } catch (e) {
      // print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    loadGoldRate();

    timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      loadGoldRate();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget rateCard(String title, double rate, double prevRate) {
    bool up = rate > prevRate;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [surfaceDark, darkBg],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: richGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: richGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.monetization_on, color: richGold),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textSubdued,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                rate == 0 ? "Loading..." : "₹${rate.toStringAsFixed(2)} / gm",
                style: TextStyle(
                  color: richGold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Icon(
            up ? Icons.trending_up : Icons.trending_down,
            color: up ? Colors.green : Colors.red,
            size: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        elevation: 0,
        title: Text(
          "Live Gold Rate",
          style: TextStyle(
            color: richGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                "Today's Gold Price",
                style: TextStyle(
                  color: textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: rateCard("24K Gold", rate24, prev24),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: rateCard("22K Gold", rate22, prev22),
            ),
            const SizedBox(height: 25),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.update, color: richGold),
                    const SizedBox(width: 10),
                    Text(
                      "Rates update every 1 minute",
                      style: TextStyle(
                        color: textSubdued,
                        fontSize: 14,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
