import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../pages/login_screen.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartService>(context, listen: false).init();
    });
    
    _razorpayService = RazorpayService(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}'), backgroundColor: Colors.green),
    );
    
    final cartService = Provider.of<CartService>(context, listen: false);
    
    List<Map<String, dynamic>> itemsList = cartService.items.map((cartItem) {
      return {
        'name': cartItem.name,
        'quantity': cartItem.quantity,
        'price': cartItem.price,
      };
    }).toList();

    EmailService.sendPurchaseEmail(
      paymentId: response.paymentId ?? 'TXN_SUCCESS',
      items: itemsList,
      totalAmount: cartService.totalPrice,
      context: context,
    );
    
    // Optionally clear cart
    cartService.clearCart();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F2F2B);
    const Color surfaceDark = Color(0xFF17453F);
    const Color richGold = Color(0xFFD4AF37);
    const Color textLight = Colors.white;

    return KeyedSubtree(
        key: ValueKey(TranslatorService.currentLang),
        child: Scaffold(
          backgroundColor: darkBg,
          appBar: AppBar(
            backgroundColor: surfaceDark,
            elevation: 0,
            title: const TranslatedText(
              'My Cart',
              style: TextStyle(
                color: textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: textLight),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Consumer<CartService>(
            builder: (context, cartService, child) {
              if (cartService.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      TranslatedText(
                        'Your cart is empty',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      TranslatedText(
                        'Add items to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartService.items.length,
                      itemBuilder: (context, index) {
                        final item = cartService.items[index];
                        return Card(
                          color: surfaceDark,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildCartImage(item.image),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle(color: textLight),
                            ),
                            subtitle: TranslatedText(
                              '₹${item.price} x ${item.quantity}',
                              style: const TextStyle(color: Colors.amber),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => cartService.updateQuantity(
                                      item.id, item.quantity - 1),
                                  icon: const Icon(Icons.remove,
                                      color: Colors.red),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  onPressed: () => cartService.updateQuantity(
                                      item.id, item.quantity + 1),
                                  icon: const Icon(Icons.add,
                                      color: Colors.green),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      cartService.removeItem(item.id),
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: surfaceDark,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TranslatedText('Total Items:',
                                style:
                                    TextStyle(color: textLight, fontSize: 16)),
                            Text('${cartService.totalQuantity}',
                                style: const TextStyle(
                                    color: richGold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const TranslatedText('Total Amount:',
                                style: TextStyle(
                                    color: textLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '₹${cartService.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: richGold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: cartService.totalQuantity > 0
                                ? () {
                                    final user = FirebaseAuth.instance.currentUser;
                                    if (user == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: TranslatedText("Please Login to proceed to checkout")),
                                      );
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                      return;
                                    }

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CheckoutPage(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: richGold,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const TranslatedText(
                              'Checkout',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
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
        ));
  }

  Widget _buildCartImage(String path) {
    if (path.trim().isEmpty) return _errorPlaceholder();
    
    if (path.trim().startsWith('http')) {
      return Image.network(
        path.trim(),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _errorPlaceholder(),
      );
    }
    return Image.asset(
      path,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _errorPlaceholder(),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey.shade900,
      child: const Icon(Icons.image_not_supported, color: Colors.white24),
    );
  }
}
