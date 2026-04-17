import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final Function(PaymentSuccessResponse) onSuccess;
  final Function(PaymentFailureResponse) onError;
  final Function(ExternalWalletResponse)? onWallet;

  RazorpayService({required this.onSuccess, required this.onError, this.onWallet}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (onWallet != null) onWallet!(response);
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String contact,
    required String email,
  }) {
    var options = {
      'key': 'rzp_test_SeGMUx79YKdi6E', // Secret test key
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': name,
      'description': description,
      'timeout': 120, // in seconds
      'prefill': {
        'contact': contact,
        'email': email
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
