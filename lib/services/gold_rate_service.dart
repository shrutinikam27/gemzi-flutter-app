import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldRateService {

  static Future<double> getGoldRate() async {

    final response = await http.get(
      Uri.parse("https://www.goldapi.io/api/XAU/INR"),
      headers: {
        "x-access-token": "goldapi-4oarvmsmmu635kq-io",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {

      final data = json.decode(response.body);

      double pricePerGram = data["price"] / 31.1035;

      return pricePerGram;

    } else {
      throw Exception("Failed to fetch gold rate");
    }
  }
}