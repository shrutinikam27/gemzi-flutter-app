import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoldRateService {
  static double? _memoryCache;
  static bool _isFetching = false;

  // ⚡ Sync Access: Get the last known rate immediately
  static double get currentRate => _memoryCache ?? 7250.0;

  static Future<double> getGoldRate() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];
    
    // 🛡️ 1. Check persistent daily cache
    final String? lastDate = prefs.getString("last_gold_fetch_date");
    final double? storedRate = prefs.getDouble("stored_gold_rate");

    if (lastDate == today && storedRate != null) {
      if (kDebugMode && _memoryCache == null) {
        debugPrint("✅ DAILY CACHE HIT: Using stored rate for $today: ₹$storedRate");
      }
      _memoryCache = storedRate;
      return storedRate;
    }

    // 🛡️ 2. Memory Cache Check (fallback for session)
    if (_memoryCache != null && lastDate == today) {
      return _memoryCache!;
    }

    // 🛡️ 3. Prevent Multiple Concurrent Calls
    if (_isFetching) {
      while (_isFetching) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _memoryCache ?? 7250.0;
    }

    _isFetching = true;

    try {
      if (kDebugMode) debugPrint("📡 CALLING GOLD API (Daily limit protection active)...");
      
      final response = await http.get(
        Uri.parse(
            "https://api.metalpriceapi.com/v1/latest?api_key=8259d61a7c5762457d1a74e978e8c559&base=USD&currencies=INR,XAU"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (!data.containsKey("rates")) throw Exception("Rates missing");

        final rates = data["rates"];
        double inrRate = (rates["INR"] as num?)?.toDouble() ?? 83.5; 
        double? xauRateRaw = (rates["XAU"] as num?)?.toDouble() ?? 
                            (rates["XAU_USD"] as num?)?.toDouble() ??
                            (rates["GOLD"] as num?)?.toDouble();

        if (xauRateRaw == null || xauRateRaw == 0) return 7250.0;

        double retail24K = ( (1 / xauRateRaw) * inrRate ) / 31.1035;
        double retail22K = retail24K * 0.9167;

        // 💾 PERSIST DATA FOR THE DAY
        await prefs.setString("last_gold_fetch_date", today);
        await prefs.setDouble("stored_gold_rate", retail22K);
        _memoryCache = retail22K;

        if (kDebugMode) debugPrint("✅ API FETCH SUCCESS: New rate for $today is ₹${retail22K.toStringAsFixed(2)}");
        return retail22K;
      } else {
        return _memoryCache ?? storedRate ?? 7250.0;
      }
    } catch (e) {
      debugPrint("ERROR FETCHING GOLD RATE: $e");
      return _memoryCache ?? storedRate ?? 7250.0; 
    } finally {
      _isFetching = false;
    }
  }

  static Stream<double> goldRateStream() async* {
    // Start with whatever we have in memory or a safe default
    yield _memoryCache ?? 7250.0;
    
    // Fetch/Refresh (will instantly return from SharedPreferences if already done today)
    yield await getGoldRate();
    
    // Periodic updates removed to strictly respect DAILY fetch requirement.
    // The rate only updates once per day.
  }
}
