import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_service.dart';

class Order {
  final String orderId;
  final List<CartItem> items;
  final double totalAmount;
  final String paymentMethod;
  final Map<String, String>? address;
  final DateTime timestamp;

  Order({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.address,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'address': address,
        'timestamp': timestamp.toIso8601String(),
      };
}

class OrderService {
  static const String _ordersKey = 'saved_orders';

  static Future<void> saveOrder(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString(_ordersKey);
    List<dynamic> ordersJson = [];
    
    if (ordersString != null) {
      try {
        ordersJson = jsonDecode(ordersString);
      } catch (e) {
        // Handle potential parsing errors if format changes
      }
    }
    
    ordersJson.add(order.toJson());
    await prefs.setString(_ordersKey, jsonEncode(ordersJson));
  }
  
  static Future<List<dynamic>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString(_ordersKey);
    if (ordersString != null) {
      try {
        return jsonDecode(ordersString);
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
