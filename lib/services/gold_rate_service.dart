import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoldRateService {
  static Future<double> getGoldRate() async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://api.metalpriceapi.com/v1/latest?api_key=b7d26fa9fc40aab40d7a29a4acafaff1&base=USD&currencies=INR,XAU"),
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

        double inrRate = data["rates"]["INR"]; // USD → INR
        double xauRate = data["rates"]["XAU"]; // USD → Gold ounce

        // 🔥 Convert properly
        double pricePerOunceUSD = 1 / xauRate;
        double pricePerOunceINR = pricePerOunceUSD * inrRate;

        // Convert ounce → gram
        double pricePerGram = pricePerOunceINR / 31.1035;

        return pricePerGram;
      } else {
        throw Exception("API ERROR: ${response.body}");
      }
    } catch (e) {
      debugPrint("ERROR FETCHING GOLD RATE: $e");
      throw Exception("FAILED TO FETCH GOLD RATE");
    }
  }
}
