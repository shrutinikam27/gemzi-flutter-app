import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../widgets/translated_text.dart';
import 'order_success_page.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPaymentMethod = 'UPI';
  bool _isLoading = false;

  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color textLight = Colors.white;

  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _finalizeOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _upiIdController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartService cartService) async {
    if (_selectedPaymentMethod == 'COD') {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    } else if (_selectedPaymentMethod == 'UPI') {
      if (_upiIdController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid UPI ID (e.g. name@bank)')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    if (_selectedPaymentMethod == 'UPI') {
      var options = {
        'key': 'rzp_test_SYjFmzSZEJ2L1r',
        'amount': (cartService.totalPrice * 100).toInt(),
        'name': 'Jewellery App',
        'description': 'Order Payment',
        'prefill': {
          'contact': '9999999999',
          'email': 'test@gemziapp.com'
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      // Mock processing delay for COD
      await Future.delayed(const Duration(seconds: 2));
      await _finalizeOrder();
    }
  }

  Future<void> _finalizeOrder() async {
    final cartService = Provider.of<CartService>(context, listen: false);
    final String orderId = 'ORD${Random().nextInt(900000) + 100000}';
    
    final order = Order(
      orderId: orderId,
      items: List.from(cartService.items), // Clone the items before clearing
      totalAmount: cartService.totalPrice,
      paymentMethod: _selectedPaymentMethod,
      address: _selectedPaymentMethod == 'COD' ? {
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
      } : null,
      timestamp: DateTime.now(),
    );

    // Save locally and clear cart
    await OrderService.saveOrder(order);
    await cartService.clearCart();

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessPage(orderId: orderId),
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: textLight),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: richGold, width: 1.5),
          ),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? 'Required field' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        elevation: 0,
        title: const TranslatedText(
          'Checkout',
          style: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.items.isEmpty && !_isLoading) {
             return const Center(child: Text("Cart is empty", style: TextStyle(color: textLight)));
          }
          
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Summary
                      const TranslatedText('Order Summary', 
                          style: TextStyle(color: richGold, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: cartService.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.name}  x${item.quantity}',
                                      style: const TextStyle(color: textLight, fontSize: 15),
                                    ),
                                  ),
                                  Text(
                                    '₹${(double.tryParse(item.price.replaceAll(',', '').replaceAll('₹', '')) ?? 0.0 * item.quantity).toStringAsFixed(0)}',
                                    style: const TextStyle(color: textLight, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Methods
                      const TranslatedText('Payment Method', 
                          style: TextStyle(color: richGold, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Colors.white54,
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const TranslatedText('UPI Payment (Pay Now)', style: TextStyle(color: textLight)),
                              value: 'UPI',
                              groupValue: _selectedPaymentMethod,
                              activeColor: richGold,
                              tileColor: surfaceDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                            ),
                            const SizedBox(height: 8),
                            RadioListTile<String>(
                              title: const TranslatedText('Cash on Delivery (COD)', style: TextStyle(color: textLight)),
                              value: 'COD',
                              groupValue: _selectedPaymentMethod,
                              activeColor: richGold,
                              tileColor: surfaceDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Dynamic Fields based on Payment Method
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: _selectedPaymentMethod == 'UPI' 
                          ? _buildTextField(_upiIdController, 'Enter UPI ID (e.g. mobile@upi)')
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TranslatedText('Delivery Details', 
                                      style: TextStyle(color: richGold, fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 12),
                                  _buildTextField(_nameController, 'Full Name'),
                                  _buildTextField(_mobileController, 'Mobile Number', type: TextInputType.phone),
                                  _buildTextField(_addressController, 'Address Line'),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTextField(_cityController, 'City')),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildTextField(_stateController, 'State')),
                                    ],
                                  ),
                                  _buildTextField(_pincodeController, 'Pincode', type: TextInputType.number),
                                ],
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TranslatedText('Total Amount:',
                            style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${cartService.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(color: richGold, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _placeOrder(cartService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: richGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: darkBg, strokeWidth: 3),
                            )
                          : TranslatedText(
                              _selectedPaymentMethod == 'UPI' ? 'Pay Now' : 'Place Order',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
