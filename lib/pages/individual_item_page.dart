import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../widgets/translated_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../screens/try_on_screen.dart';
import 'login_screen.dart';
import 'gold_certificate_page.dart';
import 'checkout_page.dart';

class IndividualItemPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final double currentGoldRate;

  const IndividualItemPage({
    super.key,
    required this.item,
    required this.currentGoldRate,
  });

  @override
  State<IndividualItemPage> createState() => _IndividualItemPageState();
}

class _IndividualItemPageState extends State<IndividualItemPage> {
  bool isLiked = false;
  int _currentSlide = 0;
  final PageController _pageController = PageController();
  late List<String> _carouselImages;

  @override
  void initState() {
    super.initState();
    _carouselImages = [
      widget.item['image'] ?? 'assets/auth/ring.png',
      widget.item['image'] ?? 'assets/auth/ring.png',
      widget.item['image'] ?? 'assets/auth/ring.png',
      widget.item['image'] ?? 'assets/auth/ring.png',
    ];
  }

  String _formatCurrency(double amount) {
    String str = amount.toStringAsFixed(0);
    if (str.length > 3) {
      String lastThree = str.substring(str.length - 3);
      String other = str.substring(0, str.length - 3);
      if (other.isNotEmpty) {
        RegExp reg = RegExp(r'\d{1,2}(?=(\d{2})+(?!\d))');
        other = other.replaceAllMapped(reg, (Match m) => "${m[0]},");
        return "₹$other,$lastThree";
      }
    }
    return "₹$str";
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F2F2B);
    const Color surfaceDark = Color(0xFF17453F);
    const Color richGold = Color(0xFFD4AF37);
    const Color textLight = Colors.white;
    const Color textSubdued = Color(0xFFB8D1CD);

    final double weight = widget.item['weight'] ?? 0.0;
    final double totalPrice = weight * widget.currentGoldRate * 1.15; // 15% making/tax
    final double originalPrice = totalPrice * 1.16; // strikethrough original price
    final String imagePath = widget.item['image'] ?? 'assets/auth/ring.png';
    final String name = widget.item['name'] ?? 'Luxury Jewellery';
    final String description = widget.item['desc'] ?? 'Exclusively handcrafted gold jewellery piece featuring premium craftsmanship and timeless design.';

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: textLight),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "Gemzi Jewellery selection: $name"));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: TranslatedText("Product share link copied!"), duration: Duration(seconds: 2)),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : textLight,
            ),
            onPressed: () {
              setState(() {
                isLiked = !isLiked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: TranslatedText(isLiked ? "Added to Wishlist" : "Removed from Wishlist"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: textLight),
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
              final cartService = Provider.of<CartService>(context, listen: false);
              cartService.addItem(CartItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                price: totalPrice.toStringAsFixed(0),
                image: imagePath,
                quantity: 1,
              ));

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: TranslatedText("Added to cart"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 📸 IMAGE CAROUSEL SECTION
            Expanded(
              flex: 4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _carouselImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSlide = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _buildProductImage(_carouselImages[index]),
                        ),
                      );
                    },
                  ),
                  
                  // Left Arrow Overlay
                  Positioned(
                    left: 15,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 22),
                      style: IconButton.styleFrom(backgroundColor: Colors.black38),
                      onPressed: () {
                        if (_currentSlide > 0) {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                  
                  // Right Arrow Overlay
                  Positioned(
                    right: 15,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 22),
                      style: IconButton.styleFrom(backgroundColor: Colors.black38),
                      onPressed: () {
                        if (_currentSlide < _carouselImages.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                  
                  // Dots Indicators Overlay
                  Positioned(
                    bottom: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_carouselImages.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: _currentSlide == index ? 16 : 6,
                          decoration: BoxDecoration(
                            color: _currentSlide == index ? richGold : Colors.white60,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // 📜 DETAILS CARD SECTION
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Prices & Discount
                        Row(
                          children: [
                            Text(
                              _formatCurrency(totalPrice),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: richGold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _formatCurrency(originalPrice),
                              style: const TextStyle(
                                fontSize: 16,
                                color: textSubdued,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "14% OFF",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Specifications Line
                        Text(
                          "22K Gold (916)  •  Weight: ${weight.toStringAsFixed(3)} g",
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSubdued,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Quality Trust Badges Row (Tapping opens the certificate)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoldCertificatePage(
                                  productName: name,
                                  productImage: imagePath,
                                  weight: weight,
                                  purity: "22K Gold (916)",
                                  HUID: "HUID${(name.hashCode.abs() % 9000000) + 1000000}",
                                  certificateId: "GZ-CERT-${(name.hashCode.abs() % 900000) + 100000}",
                                ),
                              ),
                            );
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: darkBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: richGold.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.workspace_premium_rounded, color: richGold, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "BIS Hallmarked",
                                        style: TextStyle(
                                          color: textLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: darkBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: richGold.withValues(alpha: 0.3)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 16),
                                      SizedBox(width: 6),
                                      Text(
                                        "Certified",
                                        style: TextStyle(
                                          color: textLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Explicit Certificate Navigation Link
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoldCertificatePage(
                                    productName: name,
                                    productImage: imagePath,
                                    weight: weight,
                                    purity: "22K Gold (916)",
                                    HUID: "HUID${(name.hashCode.abs() % 9000000) + 1000000}",
                                    certificateId: "GZ-CERT-${(name.hashCode.abs() % 900000) + 100000}",
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_outlined, color: richGold, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "View Gold Authenticity Certificate",
                                    style: TextStyle(
                                      color: richGold,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios_rounded, color: richGold, size: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Secure trust details line
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border.symmetric(
                              horizontal: BorderSide(color: Colors.white10, width: 1.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping_outlined, color: textSubdued, size: 18),
                              SizedBox(width: 8),
                              Text(
                                "Secure Delivery",
                                style: TextStyle(color: textLight, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Try On (AR) & Buy Now buttons row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TryOnScreen()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: richGold, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  "Try On (AR)",
                                  style: TextStyle(
                                    color: richGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
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

                                  final cartService = Provider.of<CartService>(context, listen: false);
                                  
                                  // Clear existing cart to only buy this specific item
                                  cartService.clearCart();
                                  cartService.addItem(CartItem(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: name,
                                    price: totalPrice.toString(),
                                    image: imagePath,
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
                                  backgroundColor: richGold,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "Buy Now",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Product Details description
                        const Text(
                          "Product Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            color: textSubdued,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showProductDetailsBottomSheet(
                            context,
                            name,
                            weight,
                            description,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            child: TranslatedText(
                              "View More",
                              style: TextStyle(
                                color: richGold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
        height: 260,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    
    return Image.asset(
      path,
      height: 260,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 260,
      color: const Color(0xFF0F2F2B),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 60),
          SizedBox(height: 10),
          Text("Gemzi Collection",
              style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  void _showProductDetailsBottomSheet(BuildContext context, String name, double weight, String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17453F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Product Specifications",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFD4AF37), thickness: 1),
              const SizedBox(height: 16),
              _buildSpecRow("Material", "22K Yellow Gold"),
              _buildSpecRow("Purity", "916 Hallmark (BIS Verified)"),
              _buildSpecRow("Approximate Weight", "${weight.toStringAsFixed(3)} grams"),
              _buildSpecRow("HUID Status", "Verified Genuine"),
              _buildSpecRow("Certificate", "Gemzi Trust Shield Signed"),
              _buildSpecRow("Jeweller", "Gemzi Craftsmen Ltd."),
              const SizedBox(height: 16),
              const Text(
                "Description",
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFB8D1CD),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFB8D1CD), fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
