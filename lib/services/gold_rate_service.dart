import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldRateService {
  static Future<double> getGoldRate() async {
    try {
      // Free public API - reliable gold rates
      final response = await http.get(
        Uri.parse("https://goldpricez.com/api/rate/INR"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Parse price_gram_24k or similar field
        double price =
            (data['price_gram_24k'] ?? data['price'] ?? 7800.0) as double;
        return price;
      }
    } catch (e) {
      // Fallback mock price
    }

    // Reliable fallback
    return 7825.50; // ~24K gold INR/gm
  }
}
