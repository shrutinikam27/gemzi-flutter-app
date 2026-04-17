import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoldRateService {
  static Future<double> getGoldRate() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://api.metalpriceapi.com/v1/latest?api_key=a4225e0c2ee049bd00a554c5ac790e26&base=USD&currencies=INR,XAU"),
      );

      if (kDebugMode) {
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!data.containsKey("rates")) {
          throw Exception("Rates not found");
        }

        double inrRate = (data["rates"]["INR"] as num).toDouble(); // USD → INR
        double xauRate = (data["rates"]["XAU"] as num).toDouble(); // USD → Gold ounce

        // Calculate Price of 1 Troy Ounce in INR (from 1/XAU * INR)
        double pricePerOunceINR = inrRate / xauRate;

        // Convert Troy Ounce (31.1035g) → 1 Gram 24K (99.9% Purity)
        double pricePerGram24K = pricePerOunceINR / 31.1035;
        
        // Gemzi mostly sells 22K (91.67% purity) or 18K (75% purity)
        // This service returns the 22K base rate as it's the standard for jewelry
        double pricePerGram22K = pricePerGram24K * 0.9167;

        return pricePerGram22K;
      } else {
        throw Exception("API ERROR: ${response.body}");
      }
    } catch (e) {
      debugPrint("ERROR FETCHING GOLD RATE: $e");
      // Return a fallback rate instead of throwing to prevent app crash
      return 7200.0;
    }
  }

  static Stream<double> goldRateStream() async* {
    // Initial fetch
    yield await getGoldRate();
    
    yield* Stream.periodic(const Duration(minutes: 10), (_) => getGoldRate())
        .asyncMap((event) => event);
  }
}
