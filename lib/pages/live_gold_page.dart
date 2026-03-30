import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/gold_rate_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ✅ MAIN LOGIC
  Future<void> loadGoldRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      String today = DateTime.now().toIso8601String().split('T')[0];

      String? lastDate = prefs.getString("last_date");

      List<String> history = prefs.getStringList("gold_history") ?? [];

      // ✅ IF ALREADY FETCHED TODAY
      if (lastDate == today && history.isNotEmpty) {
        var todayData = history.last.split("|");

        setState(() {
          rate24 = double.parse(todayData[1]);
          rate22 = double.parse(todayData[2]);
        });

        await loadYesterdayFromLocal();
        await loadGraphData();
        return;
      }

      // ✅ FETCH NEW DATA
      double rate = await GoldRateService.getGoldRate();

      double new24 = rate;
      double new22 = rate * (22 / 24);

      history.add("$today|$new24|$new22");

      // keep last 30 days
      if (history.length > 30) {
        history.removeAt(0);
      }

      await prefs.setStringList("gold_history", history);
      await prefs.setString("last_date", today);

      await loadYesterdayFromLocal();
      await loadGraphData();

      setState(() {
        rate24 = new24;
        rate22 = new22;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
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
        border: Border.all(color: richGold.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: richGold),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textSubdued)),
              Text(
                rate == 0 ? "Loading..." : "₹${rate.toStringAsFixed(2)} / gm",
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
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
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
              dotData: FlDotData(show: false),
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
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        title: Text("Live Gold Rate", style: TextStyle(color: richGold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Gold Price",
                style: TextStyle(
                    color: textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buildChart(),
            const SizedBox(height: 10),
            Text(
              "Last ${priceHistory.length} days trend",
              style: TextStyle(color: textSubdued),
            ),
            rateCard("24K Gold", rate24, prev24),
            rateCard("22K Gold", rate22, prev22),
            const SizedBox(height: 20),
            Text(
              "Rates update daily",
              style: TextStyle(color: textSubdued),
            ),
          ],
        ),
      ),
    );
  }
}
