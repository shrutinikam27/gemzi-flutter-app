import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoldRateService {
  static Future<double> getGoldRate() async {
    try {
      final response = await http.get(
        Uri.parse("https://www.goldapi.io/api/XAU/INR"),
        headers: {
          "x-access-token": "goldapi-eldrsmn2t40ez-io",
          "Content-Type": "application/json",
        },
      );

      if (kDebugMode) {
        debugPrint("STATUS: ${response.statusCode}");
        debugPrint("BODY: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!data.containsKey("price")) {
          throw Exception("Price not found");
        }

        double perGram = data["price"] / 31.1035;

        return perGram;
      } else {
        throw Exception("API ERROR: ${response.body}");
      }
    } catch (e) {
      throw Exception("FAILED TO FETCH GOLD RATE");
    }
  }
}
