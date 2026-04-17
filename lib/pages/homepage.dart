import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../services/cart_service.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/products/rings_page.dart' as rings_page;
import '../screens/products/product_detail_page.dart';
import '../screens/products/necklaces_page.dart' as necklaces_page;
import '../screens/products/bangles_page.dart' as bangles_page;
import '../screens/products/earrings_page.dart' as earrings_page;
import 'package:firebase_auth/firebase_auth.dart';

import '../services/gold_rate_service.dart';
import '../utils/translator_service.dart';
import '../widgets/translated_text.dart';
import 'saving_scheme_screen.dart';
import 'settings_page.dart';
import 'live_gold_page.dart';
import '../screens/try_on_screen.dart';
import 'cart_page.dart';
import 'dart:async';

class GemziHome extends StatefulWidget {
  const GemziHome({super.key});

  @override
  State<GemziHome> createState() => _GemziHomeState();
}

class _GemziHomeState extends State<GemziHome> with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String?>> filteredItems = [];
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color bronze = const Color(0xFFB8962E);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);
  final Color white = Colors.white;
  String userName = "User";
  String selectedLanguage = "EN";
  double rate24 = 0;
  double rate22 = 0;

  double prev24 = 0;
  double prev22 = 0;

  Future<void> loadGoldRate() async {
    if (!mounted) return;
    try {
      double old24 = rate24;
      double old22 = rate22;

      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('gold_history') ?? [];

      bool loaded = false;
      if (history.isNotEmpty) {
        List<String> todayData = history.last.split('|');
        if (todayData.length >= 3) {
          double? hist24 = double.tryParse(todayData[1]);
          double? hist22 = double.tryParse(todayData[2]);
          if (hist24 != null && hist24 > 0 && hist22 != null) {
            setState(() {
              prev24 = rate24;
              prev22 = rate22;
              rate24 = hist24;
              rate22 = hist22;
            });
            loaded = true;
          }
        }
      }

      if (!loaded) {
        double rate = await GoldRateService.getGoldRate();
        if (mounted) {
          setState(() {
            prev24 = old24;
            prev22 = old22;
            rate24 = rate;
            rate22 = rate * (22 / 24);
          });
        }
      }
    } catch (e) {
      debugPrint('GoldRate load error: $e');
      if (mounted) {
        setState(() {
          rate24 = 7200;
          rate22 = 6600;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Start gold rate fetch
    loadGoldRate();

    // Start ads carousel
    filteredItems = trendingItems;
    Future.microtask(() => _loadUserName());
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = trendingItems;
      });
      return;
    }
    final results = trendingItems.where((item) {
      final name = item["name"]!.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredItems = results;
    });
  }

  void addToCart(Map<String, String?> item) {
    final user = FirebaseAuth.instance.currentUser;

    // ❌ NOT LOGGED IN
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText("Please login to add items to cart"),
        ),
      );

      // 🔥 REDIRECT TO LOGIN
      Navigator.pushNamed(context, "/login");
      return;
    }

    // ✅ LOGGED IN → ADD TO CART
    final cartService = Provider.of<CartService>(context, listen: false);

    final priceNum = double.tryParse(
            item["price"]!.replaceAll('₹', '').replaceAll(',', '')) ??
        0.0;

    cartService.addItem(CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item["name"] ?? "",
      price: priceNum.toString(),
      image: item["image"] ?? "",
      quantity: 1,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: TranslatedText("${item["name"]} added to cart")),
    );
  }

  // ✅ FETCH USER NAME FROM FIREBASE
  // ✅ SAFE USER FETCH (NO CRASH)
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null && data['name'] != null) {
          setState(() {
            userName = data['name'];
          });
        } else {
          setState(() {
            userName = "User";
          });
        }
      } else {
        setState(() {
          userName = "User";
        });
      }
    } catch (e) {
      // Removed print for production - error handled silently
    }
  }

  final List<String> categoryImages = [
    "assets/auth/ring.png",
    "assets/auth/necklace.png",
    "assets/auth/earring.png",
    "assets/auth/bangles.jpeg",
    "assets/auth/coin.jpeg",
  ];

  final List<String> categoryLabels = [
    "Rings",
    "Necklaces",
    "Earrings",
    "Bangles",
    "Coins"
  ];

  final List<Map<String, String?>> trendingItems = [
    {
      "name": "Diamond Ring",
      "price": "₹50,000",
      "image": "assets/auth/ring.png"
    },
    {
      "name": "Emerald Earrings",
      "price": "₹35,000",
      "image": "assets/auth/emeraldearrings.jpeg"
    },
    {
      "name": "Gold Necklace",
      "price": "₹75,000",
      "image": "assets/auth/necklace.png"
    },
    {
      "name": "Royal Bangles",
      "price": "₹60,000",
      "image": "assets/auth/bangles.jpeg"
    },
    {"name": "Gold Coin", "price": "₹15,000", "image": "assets/auth/coin.jpeg"},
    {
      "name": "Luxury Ring",
      "price": "₹80,000",
      "image": "assets/auth/luxuryring.jpeg"
    },
    {
      "name": "Pearl Necklace",
      "price": "₹45,000",
      "image": "assets/auth/pearlnecklace.jpeg"
    },
    {
      "name": "Diamond Bangles",
      "price": "₹90,000",
      "image": "assets/auth/diamondbangles.jpeg"
    },
    {
      "name": "Gold Earrings",
      "price": "₹30,000",
      "image": "assets/auth/earring.png"
    },
    {
      "name": "Premium Coin",
      "price": "₹20,000",
      "image": "assets/auth/coin.jpeg"
    },
  ];


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: ValueKey(TranslatorService.currentLang),
        child: Scaffold(
          drawer: buildSideDrawer(context),
          backgroundColor: darkBg,
          body: Stack(
            children: [
              _buildBackgroundGradient(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(context),
                      _buildSearchBar(),
                      const SizedBox(height: 15),
                      const GemziCarousel(),
                      _buildCategoryList(),
                      _buildLiveGoldRate(),
                      _buildMainProductCollection(),
                      _buildExclusiveCollections(),
                      _buildARSection(),
                    ],
                  ),
                ),
              ),
              _buildFloatingNavBar(),
            ],
          ),
        ));
  }

  Widget buildSideDrawer(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: user == null ? _buildLoginCard() : _buildProfileCard(user),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                _menuItem(context, Icons.circle_outlined, "Rings",
                    rings_page.RingsPage()),
                _menuItem(context, Icons.earbuds, "Earrings",
                    earrings_page.EarringsPage()),
                _menuItem(context, Icons.diamond, "Necklace",
                    necklaces_page.NecklacesPage()),
                _menuItem(
                  context,
                  Icons.watch,
                  "Bangles",
                  bangles_page.BanglesPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Row(
      children: [
        Image.asset("assets/auth/bag.png", width: 60),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TranslatedText(
                "Flat Rs. 500 off",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const TranslatedText("on your first order"),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const TranslatedText("LOGIN",
                        style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 10),
                  const Text("|"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/signup");
                    },
                    child: const TranslatedText("SIGN UP",
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProfileCard(User user) {
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
      builder: (context, snapshot) {
        String name = "User";
        String email = user.email ?? "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "User";
        }

        return Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(email, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      setState(() {});
                    },
                    child: const TranslatedText(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon),

      // your translated text stays
      title: TranslatedText(title),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

      onTap: () {
        Navigator.pop(context); // close drawer

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBg, surfaceDark, darkBg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ✅ HEADER WITH CART BADGE + DRAWER + GREETING + LANGUAGE
  Widget _buildTopHeader(BuildContext context) {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Icon(Icons.menu, color: richGold, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            TranslatedText(
              "Gemzi",
              style: TextStyle(
                  color: richGold, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: TranslatedText("Hello, $userName",
                    style: TextStyle(color: textSubdued)),
              ),
            ),
            const Spacer(),
            Consumer<CartService>(
              builder: (context, cartService, child) {
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const CartPage())),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: textLight, size: 28),
                      if (cartService.totalQuantity > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text('${cartService.totalQuantity}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
            GestureDetector(
              onTap: () => _showLanguageDialog(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: surfaceDark,
                child: Icon(Icons.translate, color: richGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TranslatedText("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                title: TranslatedText("English"),
                onTap: () => _changeLanguage(context, "en")),
            ListTile(
                title: TranslatedText("हिंदी"),
                onTap: () => _changeLanguage(context, "hi")),
            ListTile(
                title: TranslatedText("मराठी"),
                onTap: () => _changeLanguage(context, "mr")),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String langCode) async {
    await TranslatorService.saveLanguage(langCode);
    setState(() => TranslatorService.currentLang = langCode);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildSearchBar() {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: searchController,
            style: const TextStyle(color: Colors.white),
            onChanged: (value) => searchProducts(value),
            decoration: InputDecoration(
              hintText: "Search jewellery...",
              hintStyle: TextStyle(color: textSubdued),
              prefixIcon: Icon(Icons.search, color: textSubdued),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: textSubdued),
                onPressed: () => searchProducts(searchController.text),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TranslatedText(
            "Categories",
            style: TextStyle(
                color: textLight, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categoryImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (categoryLabels[index] == "Rings") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const rings_page.RingsPage(),
                      ),
                    );
                  }

                  if (categoryLabels[index] == "Necklaces") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const necklaces_page.NecklacesPage(),
                      ),
                    );
                  }

                  if (categoryLabels[index] == "Bangles") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const bangles_page.BanglesPage(),
                      ),
                    );
                  }

                  if (categoryLabels[index] == "Earrings") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const earrings_page.EarringsPage(),
                      ),
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: richGold.withAlpha(102), // 0.4 * 255
                              blurRadius: 15,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            categoryImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TranslatedText(
                        categoryLabels[index],
                        style: TextStyle(color: textLight),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildLiveGoldRate() {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LiveGoldPage(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: richGold.withAlpha(102)), // 0.4
          ),
          child: Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.green),
              const SizedBox(width: 10),
              TranslatedText("Gold Rate Live",
                  style: TextStyle(color: textLight)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    rate24 == 0
                        ? "Loading..."
                        : "24K: ₹${rate24.toStringAsFixed(2)} / gm",
                    style:
                        TextStyle(color: richGold, fontWeight: FontWeight.bold),
                  ),
                  TranslatedText(
                    rate22 == 0
                        ? ""
                        : "22K: ₹${rate22.toStringAsFixed(2)} / gm",
                    style: TextStyle(color: textSubdued),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }





  Widget _buildARSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TryOnScreen()),
        );
      },
      child: FadeInUp(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [surfaceDark, darkBg]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: richGold.withAlpha(77)), // 0.3 * 255
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TranslatedText(
                      "Try Jewellery in AR",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [richGold, bronze]),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const TranslatedText(
                        "Try Now",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.camera_alt_outlined,
                size: 60,
                color: Color(0x80D4AF37), // richGold with 0.5 alpha
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFloatingNavBar() {
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 40,
        blur: 20,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            surfaceDark.withAlpha(229), // 0.9 * 255
            darkBg.withAlpha(153), // 0.6 * 255
          ],
        ),
        borderGradient: LinearGradient(colors: [richGold, bronze]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", true),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavingSchemeScreen(),
                  ),
                );
              },
              child: _navItem(Icons.account_balance_wallet, "Wallet", false),
            ),
            _buildTryOnButton(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveGoldPage(),
                  ),
                );
              },
              child: _navItem(Icons.trending_up, "Live", false),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              child: _navItem(Icons.settings, "settings", false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? richGold : textSubdued),
        TranslatedText(label,
            style: TextStyle(
                fontSize: 10, color: active ? richGold : textSubdued)),
      ],
    );
  }

  Widget _buildTryOnButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TryOnScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bronze, richGold]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 5),
            TranslatedText(
              "Try-On",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            )
          ],
        ),
      ),
    );
  }




  // --- MISSING COMPONENTS RESTORED ---

  Widget _buildMainProductCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TranslatedText(
                "Our Collection",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, "/explore"),
                child: TranslatedText("View All",
                    style: TextStyle(color: richGold)),
              ),
            ],
          ),
        ),
        StreamBuilder<double>(
          stream: GoldRateService.goldRateStream(),
          builder: (context, rateSnapshot) {
            final double currentRate = rateSnapshot.data ?? rate24;
            
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .limit(4)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data?.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList() ??
                    [];
                if (items.isEmpty) {
                  return const Center(
                      child: TranslatedText("No products",
                          style: TextStyle(color: Colors.white70)));
                }
                return _buildProductGrid(items, currentRate);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<Map<String, dynamic>> items, double rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          
          // Calculate dynamic price: weight * rate * 1.15 markup
          double weight = 0.0;
          if (item['weight'] != null) {
            weight = double.tryParse(item['weight'].toString()) ?? 0.0;
          }
          final dynamicPrice = (weight * rate * 1.15).toStringAsFixed(0);
          return _buildPremiumProductCard(item, dynamicPrice, weight, rate);
        },
      ),
    );
  }

  Widget _buildPremiumProductCard(Map<String, dynamic> item, String dynamicPrice, double weight, double rate) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                name: item['name'] ?? 'Jewellery',
                price: "₹$dynamicPrice",
                image: item['imageUrl'] ?? item['image'] ?? 'assets/auth/ring.png',
                rating: "4.8",
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        item["imageUrl"] ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Icon(Icons.image, color: Colors.white24)),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${weight}g",
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  children: [
                    Text(item["name"] ?? "",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    const SizedBox(height: 2),
                    const SizedBox(height: 4),
                    Text("₹$dynamicPrice",
                        style: TextStyle(color: richGold, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExclusiveCollections() {
    final List<Map<String, String>> collections = [
      {"name": "Bridal Collection", "image": "assets/auth/nacklace6.jpeg"},
      {"name": "Festive Special", "image": "assets/auth/ring6.jpeg"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: TranslatedText("Exclusive Collections",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: collections.length + 1,
            itemBuilder: (context, index) {
              if (index == collections.length) {
                return GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, "/exclusive-collections"),
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: surfaceDark,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: richGold.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            color: richGold, size: 40),
                        const SizedBox(height: 10),
                        TranslatedText("View More",
                            style: TextStyle(color: richGold)),
                      ],
                    )),
                  ),
                );
              }
              final col = collections[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                      image: AssetImage(col['image']!), fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7)
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  alignment: Alignment.bottomLeft,
                  child: TranslatedText(col['name']!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),

                ),
              );
            },
          ),
        ),
      ],
    );
  }

}

class GemziCarousel extends StatefulWidget {
  const GemziCarousel({super.key});
  @override
  State<GemziCarousel> createState() => _GemziCarouselState();
}

class _GemziCarouselState extends State<GemziCarousel> {
  final PageController _adController = PageController();
  int _currentAdPage = 0;
  final Color richGold = const Color(0xFFD4AF37);
  final Color bronze = const Color(0xFFB8962E);

  @override
  void initState() {
    super.initState();
    _startAdScroll();
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  void _startAdScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      if (_adController.hasClients) {
        int nextPage = (_adController.page?.toInt() ?? 0) + 1;
        if (nextPage >= 2) nextPage = 0;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
      _startAdScroll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').snapshots(),
      builder: (context, snapshot) {
        List<Map<String, String>> ads = [];
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          ads = [
            {"title": "Saving Schemes", "subtitle": "Get 10% Extra Gold", "image": "assets/auth/gold2.png"},
            {"title": "New Arrivals", "subtitle": "Check latest Rings", "image": "assets/auth/ring1.jpeg"},
          ];
        } else {
          ads = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              "title": data['title']?.toString() ?? "Special Offer",
              "subtitle": data['description']?.toString() ?? "Exclusive Deals",
              "image": data['imageUrl']?.toString() ?? ""
            };
          }).toList();
        }

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _adController,
                onPageChanged: (idx) => setState(() => _currentAdPage = idx),
                itemCount: ads.length,
                itemBuilder: (context, i) {
                  final ad = ads[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: (ad['image'] != null && ad['image']!.trim().isNotEmpty)
                          ? DecorationImage(
                              image: ad['image']!.startsWith('assets')
                                  ? AssetImage(ad['image']!) as ImageProvider
                                  : NetworkImage(ad['image']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken))
                          : null,
                      gradient: (ad['image'] == null || ad['image']!.trim().isEmpty)
                          ? LinearGradient(colors: [richGold, bronze])
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TranslatedText(ad['title']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TranslatedText(ad['subtitle']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(ads.length, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentAdPage == i ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _currentAdPage == i ? richGold : Colors.white24),
              )),
            ),
          ],
        );
      },
    );
  }

}
