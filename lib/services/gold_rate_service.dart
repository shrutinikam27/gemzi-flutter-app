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
      // 🌐 ATTEMPT 1: GoldAPI.io (Primary)
      try {
        if (kDebugMode) debugPrint("📡 CALLING GOLD API (Primary: goldapi.io)...");
        final response = await http.get(
          Uri.parse("https://www.goldapi.io/api/XAU/INR"),
          headers: {
            "x-access-token": "goldapi-16rksm362243j-io",
            "Content-Type": "application/json"
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          double pricePerOunce = (data["price"] as num).toDouble();
          if (pricePerOunce > 50000) {
            double rate = (pricePerOunce / 31.1035) * 0.9167;
            await prefs.setString("last_gold_fetch_date", today);
            await prefs.setDouble("stored_gold_rate", rate);
            _memoryCache = rate;
            return rate;
          }
        }
      } catch (e) {
        debugPrint("⚠️ Primary API Network Error: $e");
      }

      // 🔄 ATTEMPT 2: MetalPriceAPI (Fallback)
      try {
        if (kDebugMode) debugPrint("🔄 Trying Fallback API (metalpriceapi)...");
        final altResponse = await http.get(
          Uri.parse("https://api.metalpriceapi.com/v1/latest?api_key=8259d61a7c5762457d1a74e978e8c559&base=USD&currencies=INR,XAU"),
        ).timeout(const Duration(seconds: 8));

        if (altResponse.statusCode == 200) {
          final altData = json.decode(altResponse.body);
          if (altData["success"] == true) {
            final rates = altData["rates"];
            double inr = (rates["INR"] as num).toDouble();
            double xau = (rates["XAU"] as num).toDouble();
            if (xau != 0) {
              double rate = ((1 / xau) * inr / 31.1035) * 0.9167;
              await prefs.setString("last_gold_fetch_date", today);
              await prefs.setDouble("stored_gold_rate", rate);
              _memoryCache = rate;
              return rate;
            }
          }
        }
      } catch (e) {
        debugPrint("⚠️ Fallback API Network Error: $e");
      }

      // 💾 FINAL ATTEMPT: Last Known Good Rate from Storage
      debugPrint("📢 Using Offline Cached Price");
      return _memoryCache ?? storedRate ?? 7250.0;

    } catch (e) {
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
