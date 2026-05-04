import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_service.dart';

class Order {
  final String orderId;
  final String userId;
  final String userEmail;
  final List<CartItem> items;
  final double totalAmount;
  final String paymentMethod;
  final Map<String, String>? address;
  final DateTime timestamp;
  final String status;

  Order({
    required this.orderId,
    required this.userId,
    required this.userEmail,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    this.address,
    required this.timestamp,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'userId': userId,
        'userEmail': userEmail,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'address': address,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };
}

class OrderService {
  static const String _ordersKey = 'saved_orders';

  /// Saves the order both to Firestore (for admin) and locally (for history)
  static Future<bool> placeOrder(Order order) async {
    // 1. Save to Global Firestore Collection (for Admin)
    Map<String, dynamic> firestoreData = order.toJson();
    firestoreData['timestamp'] = FieldValue.serverTimestamp();
    
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(order.orderId)
        .set(firestoreData);

    // 2. Save to User-Specific Collection (for User History)
    if (order.userId != 'unknown') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.orderId)
          .set(firestoreData);
    }

    // 3. Save locally
    await saveOrderLocal(order);
    return true;
  }

  static Future<void> saveOrderLocal(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final ordersString = prefs.getString(_ordersKey);
    List<dynamic> ordersJson = [];
    
    if (ordersString != null) {
      try {
        ordersJson = jsonDecode(ordersString);
      } catch (e) {
        // Handle potential parsing errors
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
