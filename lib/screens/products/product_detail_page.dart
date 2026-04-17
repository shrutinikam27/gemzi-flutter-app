import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../pages/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';
import '../../pages/checkout_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final String rating;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.price,
    required this.image,
    required this.rating,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isLiked = false;
  late RazorpayService _razorpayService;

  @override
  void initState() {
    super.initState();
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

    final priceNum = double.tryParse(widget.price.replaceAll('₹', '').replaceAll(',', '')) ?? 0.0;
    
    EmailService.sendPurchaseEmail(
      paymentId: response.paymentId ?? 'TXN_SUCCESS',
      items: [
        {
          'name': widget.name,
          'quantity': 1,
          'price': priceNum,
        }
      ],
      totalAmount: priceNum,
      context: context,
    );
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

    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: surfaceDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),

          // ❌ dynamic → DO NOT translate
          title: TranslatedText(
            widget.name,
            style: const TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _buildProductImage(widget.image),
                            ),
                          ),
                          Positioned(
                            right: 25,
                            top: 30,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLiked = !isLiked;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      /// Product Info Section
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: surfaceDark,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Product Name (dynamic → no translation)
                              TranslatedText(
                                widget.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 8),

                              const SizedBox(height: 12),

                              /// Price (dynamic → no translation)
                              Text(
                                widget.price,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: richGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 15),

                              /// Description ✅ translated
                              const TranslatedText(
                                "Premium handcrafted jewellery made with pure gold and certified diamonds. Perfect for weddings, engagements and special occasions.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                ),
                              ),

                              const Spacer(),

                              /// Buttons Row
                              Row(
                                children: [
                                  /// Add to Cart
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: TranslatedText("Please Login to add items to cart")),
                                          );
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                          return;
                                        }

                                        HapticFeedback.mediumImpact();
                                        // ... existing cart logic
                                        final priceNum = double.tryParse(widget
                                                .price
                                                .replaceAll('₹', '')
                                                .replaceAll(',', '')) ??
                                            0.0;
                                        final cartService =
                                            Provider.of<CartService>(context,
                                                listen: false);
                                        cartService.addItem(CartItem(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          name: widget.name,
                                          price: priceNum.toString(),
                                          image: widget.image,
                                          quantity: 1,
                                        ));

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const TranslatedText(
                                              "Added to cart",
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor: richGold,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const TranslatedText(
                                        "Add to Cart",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  /// Buy Now
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final user = FirebaseAuth.instance.currentUser;
                                        if (user == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: TranslatedText("Please Login to buy jewellery")),
                                          );
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                                          return;
                                        }

                                        HapticFeedback.mediumImpact();

                                        final priceNum = double.tryParse(widget
                                                .price
                                                .replaceAll('₹', '')
                                                .replaceAll(',', '')) ??
                                            0.0;
                                        final cartService =
                                            Provider.of<CartService>(context,
                                                listen: false);
                                        
                                        // Clear existing cart to only buy this specific item
                                        cartService.clearCart();
                                        cartService.addItem(CartItem(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          name: widget.name,
                                          price: priceNum.toString(),
                                          image: widget.image,
                                          quantity: 1,
                                        ));

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CheckoutPage(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const TranslatedText(
                                        "Buy Now",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return _buildPlaceholder();
    }
    
    final path = imagePath.trim();
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: 320,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    
    return Image.asset(
      path,
      width: double.infinity,
      height: 320,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 320,
      color: const Color(0xFF17453F),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 60),
          SizedBox(height: 10),
          Text("Gemzi Collection",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
