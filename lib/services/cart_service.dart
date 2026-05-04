import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final String id;
  final String name;
  final String price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        image: json['image'],
        quantity: json['quantity'] ?? 1,
      );
}

class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  String get _cartKey {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return 'cart_$userId';
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_cartKey);
      if (cartString != null) {
        final List<dynamic> cartJson =
            List<Map<String, dynamic>>.from(jsonDecode(cartString));
        _items = cartJson.map((e) => CartItem.fromJson(e)).toList();
      } else {
        _items = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Cart load error: $e');
    }
  }

  Future<void> addItem(CartItem item) async {
    final existingIndex =
        _items.indexWhere((cartItem) => cartItem.id == item.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(item);
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String id, int quantity) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0 && quantity > 0) {
      _items[index].quantity = quantity;
      await _saveCart();
      notifyListeners();
    } else if (index >= 0) {
      removeItem(id);
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      final price = double.tryParse(
              item.price.toString().replaceAll('₹', '').replaceAll(',', '')) ??
          0.0;
      return sum + price * item.quantity;
    });
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _items.map((e) => e.toJson()).toList();
      await prefs.setString(_cartKey, jsonEncode(cartJson));
    } catch (e) {
      debugPrint('Cart save error: $e');
    }
  }

  void init() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      loadCart();
    });
    loadCart();
  }
}
