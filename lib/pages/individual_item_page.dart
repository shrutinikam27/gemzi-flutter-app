import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../widgets/translated_text.dart';

class IndividualItemPage extends StatelessWidget {
  final Map<String, dynamic> item;
  final double currentGoldRate;

  const IndividualItemPage({
    super.key,
    required this.item,
    required this.currentGoldRate,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F2F2B);

    const Color richGold = Color(0xFFD4AF37);

    final double weight = item['weight'] ?? 0.0;
    final double totalPrice = weight * currentGoldRate * 1.15; // 15% making/tax
    final String imagePath = item['image'] ?? 'assets/auth/ring.png';
    final String name = item['name'] ?? 'Luxury Jewellery';
    final String description = item['desc'] ?? 'Exclusively handcrafted gold jewellery piece featuring premium craftsmanship and timeless design.';

    return Scaffold(
      backgroundColor: darkBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Hero Image Section
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                Hero(
                  tag: 'item_${item['name']}',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        darkBg.withValues(alpha: 0.8),
                        darkBg,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Details Section
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: const BoxDecoration(
                color: darkBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: richGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: richGold.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            "$weight gm",
                            style: const TextStyle(color: richGold, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "₹${totalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                        color: richGold,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TranslatedText(
                      "Description",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                    ),
                    const SizedBox(height: 30),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final cart = Provider.of<CartService>(context, listen: false);
                              cart.addItem(CartItem(
                                id: name,
                                name: name,
                                price: totalPrice.toStringAsFixed(0),
                                image: imagePath,
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: TranslatedText("Added to cart"), duration: Duration(seconds: 1)),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: richGold),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const TranslatedText(
                              "Add to Cart",
                              style: TextStyle(color: richGold, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Direct Buy Now logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: TranslatedText("Proceeding to Buy...")),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: richGold,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const TranslatedText(
                              "Buy Now",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
