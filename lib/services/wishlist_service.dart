import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistItem {
  final String id;
  final String name;
  final String price;
  final String image;
  final String rating;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.rating = '4.5',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'rating': rating,
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        image: json['image'],
        rating: json['rating'] ?? '4.5',
      );
}

class WishlistService with ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  List<WishlistItem> _items = [];

  List<WishlistItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;

  String get _wishlistKey {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'wishlist_$userId';
  }

  bool isWishlisted(String productName) {
    return _items.any((item) => item.name == productName);
  }

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistString = prefs.getString(_wishlistKey);
      if (wishlistString != null) {
        final List<dynamic> wishlistJson =
            List<Map<String, dynamic>>.from(jsonDecode(wishlistString));
        _items = wishlistJson.map((e) => WishlistItem.fromJson(e)).toList();
      } else {
        _items = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Wishlist load error: $e');
    }
  }

  Future<void> addItem(WishlistItem item) async {
    final alreadyExists = _items.any((i) => i.name == item.name);
    if (!alreadyExists) {
      _items.add(item);
      await _saveWishlist();
      notifyListeners();
    }
  }

  Future<void> removeItem(String productName) async {
    _items.removeWhere((item) => item.name == productName);
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> toggleItem(WishlistItem item) async {
    if (isWishlisted(item.name)) {
      await removeItem(item.name);
    } else {
      await addItem(item);
    }
  }

  Future<void> clearWishlist() async {
    _items.clear();
    await _saveWishlist();
    notifyListeners();
  }

  Future<void> _saveWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = _items.map((e) => e.toJson()).toList();
      await prefs.setString(_wishlistKey, jsonEncode(wishlistJson));
    } catch (e) {
      debugPrint('Wishlist save error: $e');
    }
  }

  void init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadWishlist();
    });
    loadWishlist();
  }
}
