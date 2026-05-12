import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// for debugPrint if needed

class TranslatorService {
  static String currentLang = "en";

  // 🔥 Memory cache
  static Map<String, String> cache = {};

  // 🔥 Load saved language
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    currentLang = prefs.getString("lang") ?? "en";
  }

  // 🔥 Save language
  static Future<void> saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lang", lang);
  }

  static Future<String> translate(String text) async {
    if (currentLang == "en") return text;

    String key = "$text-$currentLang";

    // ✅ Return cached value
    if (cache.containsKey(key)) {
      return cache[key]!;
    }

    try {
      final url =
          "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$currentLang&dt=t&q=${Uri.encodeComponent(text)}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String translated = data[0][0][0];

        cache[key] = translated; // cache result
        return translated;
      }
    } catch (e) {
      print('Translation error: $e');
    }

    return text;
  }
}
