import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart' as os;
import '../services/razorpay_service.dart';
import '../services/email_service.dart';
import '../widgets/translated_text.dart';
import 'order_success_page.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gold_rate_service.dart';
import 'profile_page.dart';

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

  List<DocumentSnapshot> _availableSchemes = [];
  DocumentSnapshot? _selectedScheme;
  double _discountAmount = 0.0;

  // 🏦 Vault Balance State Variables
  double _vaultBalance = 0.0;
  bool _useVaultBalance = false;
  bool _isVaultLoading = true;

  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color textLight = Colors.white;

  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
    _fetchSchemes();
    _fetchVaultBalance();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          if (_nameController.text.isEmpty) {
            _nameController.text = data['name'] ?? '';
          }
          if (_mobileController.text.isEmpty) {
            _mobileController.text = data['phone'] ?? '';
          }
          if (_cityController.text.isEmpty) {
            _cityController.text = data['city'] ?? '';
          }
          if (_stateController.text.isEmpty) {
            _stateController.text = data['state'] ?? '';
          }
          if (_pincodeController.text.isEmpty) {
            _pincodeController.text = data['pincode'] ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint('Profile prefill error: $e');
    }
  }

  void _fetchVaultBalance() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isVaultLoading = false);
        return;
      }
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        if (mounted) {
          setState(() {
            _vaultBalance = (doc.data()?['walletBalance'] ?? 0.0).toDouble();
            _isVaultLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isVaultLoading = false);
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching vault balance: $e");
      if (mounted) {
        setState(() => _isVaultLoading = false);
      }
    }
  }

  void _fetchSchemes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("❌ No user logged in, skipping scheme fetch");
        return;
      }

      bool isFirstOrder = true;
      try {
        // Check if user has previous orders
        final ordersSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
        
        isFirstOrder = ordersSnapshot.docs.isEmpty;
        debugPrint("📊 User Order Status: ${isFirstOrder ? 'FIRST ORDER' : 'RECURRING CUSTOMER'}");
      } catch (e) {
        debugPrint("⚠️ Order check failed (possibly missing index): $e");
        // Fallback: assume not first order if check fails to be safe, or true to be generous
        isFirstOrder = false; 
      }

      // Fetch all schemes
      final snapshot = await FirebaseFirestore.instance.collection('schemes').get();
      debugPrint("📥 Fetched ${snapshot.docs.length} total schemes from Firestore");
      
      if (mounted) {
        setState(() {
          _availableSchemes = snapshot.docs.where((doc) {
            final data = doc.data();
            bool firstOnly = data['isFirstOrderOnly'] ?? false;
            
            if (firstOnly) {
              return isFirstOrder;
            }
            return true;
          }).toList();
          debugPrint("✅ Available schemes after filtering: ${_availableSchemes.length}");
        });
      }
    } catch (e) {
      debugPrint("❌ Fatal error fetching schemes: $e");
    }
  }

  void _applyScheme(DocumentSnapshot? scheme) {
    if (scheme == null) {
      setState(() {
        _selectedScheme = null;
        _discountAmount = 0.0;
      });
      return;
    }

    final data = scheme.data() as Map<String, dynamic>;
    final discountPercent = (data['discountPercentage'] ?? 0.0).toDouble();
    final cartService = Provider.of<CartService>(context, listen: false);
    
    setState(() {
      _selectedScheme = scheme;
      _discountAmount = (cartService.totalPrice * discountPercent) / 100;
    });
  }

  double _calculateVaultDeduction(CartService cartService) {
    if (!_useVaultBalance) return 0.0;
    double finalBeforeVault = cartService.totalPrice - _discountAmount;
    return min(_vaultBalance, finalBeforeVault);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _finalizeOrder(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    _upiIdController.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _placeOrder(CartService cartService) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double vaultDeduction = _calculateVaultDeduction(cartService);
    final double netAmount = cartService.totalPrice - _discountAmount - vaultDeduction;

    if (netAmount > 0 && _selectedPaymentMethod == 'UPI' && _upiIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid UPI ID (e.g. name@bank)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    if (netAmount <= 0) {
      // Bypasses payment gateway as it is fully covered by the Digital Gold Vault
      await Future.delayed(const Duration(seconds: 1));
      await _finalizeOrder('VAULT_PAYMENT');
    } else if (_selectedPaymentMethod == 'UPI') {
      final user = FirebaseAuth.instance.currentUser;
      try {
        await _razorpayService.openCheckout(
          amount: netAmount,
          name: 'Gemzi Order',
          description: 'Payment for your jewellery selection',
          contact: _mobileController.text.isNotEmpty ? _mobileController.text : '9999999999',
          email: user?.email ?? 'test@gemziapp.com',
        );
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Mock processing delay for COD
      await Future.delayed(const Duration(seconds: 2));
      await _finalizeOrder('COD_PAYMENT');
    }
  }

  Future<void> _restoreVaultBalance(String userId, double amount, String orderId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await docRef.update({
        'walletBalance': FieldValue.increment(amount),
      });

      double rate = GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0;
      double grams = amount / rate;

      await FirebaseFirestore.instance.collection('vault_transactions').add({
        'userId': userId,
        'userEmail': FirebaseAuth.instance.currentUser?.email ?? 'Unknown',
        'amount': amount,
        'grams': grams,
        'type': 'Gold Restored (Checkout Sync Failed - Order $orderId)',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'completed',
      });
      debugPrint("✅ Vault balance restored successfully: ₹$amount");
    } catch (e) {
      debugPrint("❌ Failed to restore vault balance: $e");
    }
  }

  Future<void> _finalizeOrder(String? paymentId) async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in to complete your purchase"), backgroundColor: Colors.redAccent),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    final String orderId = 'ORD${Random().nextInt(900000) + 100000}';
    final double vaultDeduction = _calculateVaultDeduction(cartService);
    final double finalAmount = cartService.totalPrice - _discountAmount - vaultDeduction;

    // 🏦 DEDUCT VAULT BALANCE IF USED
    if (vaultDeduction > 0) {
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await docRef.update({
          'walletBalance': FieldValue.increment(-vaultDeduction),
        });

        // Log a transaction record for admin & vault activity screen
        double rate = GoldRateService.currentRate > 0 ? GoldRateService.currentRate : 7500.0;
        double gramsUsed = vaultDeduction / rate;

        await FirebaseFirestore.instance.collection('vault_transactions').add({
          'userId': user.uid,
          'userEmail': user.email ?? 'Unknown',
          'amount': vaultDeduction,
          'grams': gramsUsed,
          'type': 'Gold Redeemed (Order $orderId)',
          'timestamp': FieldValue.serverTimestamp(),
          'status': 'completed',
        });
      } catch (e) {
        debugPrint("⚠️ Vault balance deduction failed: $e");
      }
    }
    
    // Send Email
    EmailService.sendPurchaseEmail(
      paymentId: paymentId ?? 'TXN_SUCCESS',
      items: cartService.items.map((e) => {
        'name': e.name,
        'quantity': e.quantity,
        'price': double.tryParse(e.price) ?? 0.0,
      }).toList(),
      totalAmount: finalAmount,
      context: context,
    );

    // Determine descriptive payment method
    String paymentDesc = _selectedPaymentMethod;
    if (vaultDeduction > 0) {
      if (finalAmount <= 0) {
        paymentDesc = 'Digital Vault';
      } else {
        paymentDesc = '$_selectedPaymentMethod + Vault';
      }
    }

    final order = os.Order(
      orderId: orderId,
      userId: user.uid,
      userEmail: user.email ?? 'Member',
      items: List.from(cartService.items), // Clone the items before clearing
      totalAmount: finalAmount,
      discount: _discountAmount,
      appliedScheme: _selectedScheme != null ? (_selectedScheme!.data() as Map<String, dynamic>)['name'] : null,
      paymentMethod: paymentDesc,
      vaultAmountUsed: vaultDeduction,
      address: {
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
      },
      timestamp: DateTime.now(),
    );

    // Save to Firestore & Local storage, then clear cart
    String? errorMessage;
    try {
      bool success = await os.OrderService.placeOrder(order);
      if (!success) {
        errorMessage = "Unknown Firestore error";
        if (vaultDeduction > 0) {
          await _restoreVaultBalance(user.uid, vaultDeduction, orderId);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      if (vaultDeduction > 0) {
        await _restoreVaultBalance(user.uid, vaultDeduction, orderId);
      }
    }

    if (errorMessage == null) {
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
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Cloud Sync Failed: $errorMessage. Vault amount restored."),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 10),
          ),
        );
      }
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
                      
                      // 🏦 DIGITAL GOLD VAULT SECTION
                      const TranslatedText('Digital Gold Vault', 
                          style: TextStyle(color: richGold, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _useVaultBalance ? richGold : Colors.white10,
                            width: _useVaultBalance ? 1.5 : 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: _isVaultLoading
                            ? const Center(child: CircularProgressIndicator(color: richGold))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.shield_moon_outlined, color: richGold, size: 24),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const TranslatedText(
                                                "Available Vault Balance",
                                                style: TextStyle(color: Colors.white70, fontSize: 12),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "₹${_vaultBalance.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (_vaultBalance > 0)
                                        Switch(
                                          value: _useVaultBalance,
                                          activeColor: richGold,
                                          activeTrackColor: richGold.withOpacity(0.3),
                                          inactiveThumbColor: Colors.white54,
                                          inactiveTrackColor: Colors.white10,
                                          onChanged: (bool value) {
                                            setState(() {
                                              _useVaultBalance = value;
                                            });
                                          },
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const TranslatedText(
                                            "Empty Vault",
                                            style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_useVaultBalance && _vaultBalance > 0) ...[
                                    const Divider(color: Colors.white10, height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const TranslatedText("Vault Deduction:", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                        Text(
                                          "-₹${_calculateVaultDeduction(cartService).toStringAsFixed(2)}",
                                          style: TextStyle(color: richGold, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Methods
                      if (cartService.totalPrice - _discountAmount - _calculateVaultDeduction(cartService) > 0) ...[
                        const TranslatedText('Payment Method', 
                            style: TextStyle(color: richGold, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        
                        Theme(
                          data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Colors.white54,
                          ),
                          child: Column(
                            children: [
                              // ignore: deprecated_member_use
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
                              // ignore: deprecated_member_use
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
                      ] else ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.greenAccent.withOpacity(0.3), width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Fully Covered by Vault",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    SizedBox(height: 4),
                                    TranslatedText(
                                      "Your order is 100% paid using your Digital Gold Vault balance. No other payment is required.",
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
 
                       // 🏷️ DISCOUNT SCHEMES SECTION
                       if (_availableSchemes.isNotEmpty) ...[
                         const TranslatedText('Apply Discount Scheme', 
                             style: TextStyle(color: richGold, fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(height: 12),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           decoration: BoxDecoration(
                             color: surfaceDark,
                             borderRadius: BorderRadius.circular(12),
                           ),
                           child: DropdownButtonHideUnderline(
                             child: DropdownButton<DocumentSnapshot?>(
                               value: _selectedScheme,
                               dropdownColor: surfaceDark,
                               hint: const TranslatedText("Select a scheme for discount", style: TextStyle(color: Colors.white54)),
                               icon: const Icon(Icons.keyboard_arrow_down, color: richGold),
                               isExpanded: true,
                               onChanged: _applyScheme,
                               items: [
                                 const DropdownMenuItem<DocumentSnapshot?>(
                                   value: null,
                                   child: TranslatedText("No Scheme", style: TextStyle(color: textLight)),
                                 ),
                                 ..._availableSchemes.map((scheme) {
                                   final data = scheme.data() as Map<String, dynamic>;
                                   return DropdownMenuItem<DocumentSnapshot?>(
                                     value: scheme,
                                     child: Text(
                                       "${data['name']} (${data['discountPercentage']}% OFF)",
                                       style: const TextStyle(color: textLight),
                                     ),
                                   );
                                 }),
                               ],
                             ),
                           ),
                         ),
                         const SizedBox(height: 24),
                       ],

                       // Mandatory Delivery Details for all Home Delivery orders
                       Form(
                         key: _formKey,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 const TranslatedText('Home Delivery Details',
                                     style: TextStyle(
                                         color: richGold,
                                         fontSize: 16,
                                         fontWeight: FontWeight.bold)),
                                 GestureDetector(
                                   onTap: () async {
                                     await Navigator.push(
                                       context,
                                       MaterialPageRoute(
                                           builder: (_) => const ProfilePage()),
                                     );
                                     _loadProfileData();
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.symmetric(
                                         horizontal: 10, vertical: 5),
                                     decoration: BoxDecoration(
                                       color: richGold.withOpacity(0.12),
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(
                                           color: richGold.withOpacity(0.4)),
                                     ),
                                     child: const Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(Icons.edit_outlined,
                                             color: richGold, size: 13),
                                         SizedBox(width: 4),
                                         Text('Edit',
                                             style: TextStyle(
                                                 color: richGold,
                                                 fontSize: 12,
                                                 fontWeight: FontWeight.w600)),
                                       ],
                                     ),
                                   ),
                                 ),
                               ],
                             ),
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
                       
                       const SizedBox(height: 12),
 
                       // UPI Field (Only if UPI selected AND net amount > 0)
                       AnimatedSize(
                         duration: const Duration(milliseconds: 300),
                         child: (_selectedPaymentMethod == 'UPI' && cartService.totalPrice - _discountAmount - _calculateVaultDeduction(cartService) > 0) 
                           ? _buildTextField(_upiIdController, 'Enter UPI ID (e.g. mobile@upi)')
                           : const SizedBox.shrink(),
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
                     if (_discountAmount > 0) ...[
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const TranslatedText('Discount Applied:',
                               style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                           Text('-₹${_discountAmount.toStringAsFixed(0)}',
                               style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 8),
                     ],
                     if (_useVaultBalance && _vaultBalance > 0) ...[
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           const TranslatedText('Vault Deduction:',
                               style: TextStyle(color: Colors.greenAccent, fontSize: 16)),
                           Text('-₹${_calculateVaultDeduction(cartService).toStringAsFixed(0)}',
                               style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                         ],
                       ),
                       const SizedBox(height: 8),
                     ],
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const TranslatedText('Total Amount:',
                             style: TextStyle(color: textLight, fontSize: 18, fontWeight: FontWeight.bold)),
                         Text('₹${(cartService.totalPrice - _discountAmount - _calculateVaultDeduction(cartService)).toStringAsFixed(0)}',
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
                               (cartService.totalPrice - _discountAmount - _calculateVaultDeduction(cartService) <= 0)
                                   ? 'Pay with Vault'
                                   : _selectedPaymentMethod == 'UPI' ? 'Pay Now' : 'Place Order',
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
