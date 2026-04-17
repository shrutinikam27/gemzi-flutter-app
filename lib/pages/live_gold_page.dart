import 'package:flutter/material.dart';
import '../services/gold_rate_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';

class LiveGoldPage extends StatefulWidget {
  const LiveGoldPage({super.key});

  @override
  State<LiveGoldPage> createState() => _LiveGoldPageState();
}

class _LiveGoldPageState extends State<LiveGoldPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  List<double> priceHistory = [];

  double rate24 = 0;
  double rate22 = 0;

  double prev24 = 0;
  double prev22 = 0;

  @override
  void initState() {
    super.initState();
    loadGoldRate();
  }

  // ✅ MAIN LOGIC (Synchronized with GoldRateService)
  Future<void> loadGoldRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String today = DateTime.now().toIso8601String().split('T')[0];
      
      // 1. Get the latest rate from the Daily-Cached Service
      double rate = await GoldRateService.getGoldRate();
      double current22 = rate;
      double current24 = rate / 0.9167; // 💎 Reversing 22K → 24K calculation


      // 2. Fetch History
      List<String> history = prefs.getStringList("gold_history") ?? [];
      String? lastDate = prefs.getString("last_date");

      // 3. Update History if today is new
      if (lastDate != today) {
        // Only add if not already present for today
        bool alreadyExists = history.any((entry) => entry.startsWith(today));
        if (!alreadyExists) {
          history.add("$today|$current24|$current22");
          if (history.length > 30) history.removeAt(0); // Keep last 30 days
          
          await prefs.setStringList("gold_history", history);
          await prefs.setString("last_date", today);
        }
      }

      // 4. Update UI State
      if (mounted) {
        setState(() {
          rate24 = current24;
          rate22 = current22;
        });
        await loadYesterdayFromLocal();
        await loadGraphData();
      }
    } catch (e) {
      debugPrint("ERROR IN LIVE GOLD PAGE: $e");
    }
  }

  // ✅ LOAD PREVIOUS DAY
  Future<void> loadYesterdayFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("gold_history") ?? [];

    if (history.length >= 2) {
      var yesterday = history[history.length - 2].split("|");

      setState(() {
        prev24 = double.parse(yesterday[1]);
        prev22 = double.parse(yesterday[2]);
      });
    }
  }

  // ✅ LOAD GRAPH DATA
  Future<void> loadGraphData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList("gold_history") ?? [];

    List<double> temp = [];

    for (var item in history) {
      var data = item.split("|");
      temp.add(double.parse(data[1]));
    }

    setState(() {
      priceHistory = temp;
    });
  }

  // ✅ UI CARD
  Widget rateCard(String title, double rate, double prevRate) {
    bool up = prevRate != 0 && rate > prevRate;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [surfaceDark, darkBg],
        ),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: richGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: richGold),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslatedText(title, style: TextStyle(color: textSubdued)),
              rate == 0
                  ? const TranslatedText(
                      "Loading...",
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Text(
                      "₹${rate.toStringAsFixed(2)} / gm",
                      style: TextStyle(
                        color: richGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ],
          ),
          const Spacer(),
          if (prevRate != 0)
            Icon(
              up ? Icons.trending_up : Icons.trending_down,
              color: up ? Colors.green : Colors.red,
            ),
        ],
      ),
    );
  }

  // ✅ GRAPH
  Widget buildChart() {
    if (priceHistory.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: richGold),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: priceHistory
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: priceHistory.last >= priceHistory.first
                  ? Colors.green
                  : Colors.red,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (priceHistory.last >= priceHistory.first
                        ? Colors.green
                        : Colors.red)
                    .withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UI
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: ValueKey(TranslatorService.currentLang), // 🔥 important
        child: Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(
            backgroundColor: surfaceDark,
            title: TranslatedText("Live Gold Rate",
                style: TextStyle(color: richGold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TranslatedText("Today's Gold Price",
                    style: TextStyle(
                        color: textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                buildChart(),
                const SizedBox(height: 10),
                TranslatedText(
                  "Last ${priceHistory.length} days trend",
                  style: TextStyle(color: textSubdued),
                ),
                rateCard("24K Gold", rate24, prev24),
                rateCard("22K Gold", rate22, prev22),
                const SizedBox(height: 20),
                TranslatedText(
                  "Rates update daily",
                  style: TextStyle(color: textSubdued),
                ),
              ],
            ),
          ),
        ));
  }
}
