class AppStrings {
  static String currentLang = "en";

  static Map<String, Map<String, String>> localizedValues = {
    "en": {
      "hello": "Hello",
    },
    "hi": {
      "hello": "नमस्ते",
    },
    "mr": {
      "hello": "नमस्कार",
    },
  };

  static String get(String key) {
    return localizedValues[currentLang]?[key] ?? key;
  }
}