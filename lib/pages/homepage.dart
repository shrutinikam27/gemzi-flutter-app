import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/products/rings_page.dart' as rings_page;
import '../screens/products/product_detail_page.dart';
import '../screens/products/necklaces_page.dart' as necklaces_page;
import '../screens/products/bangles_page.dart' as bangles_page;
import '../screens/products/earrings_page.dart' as earrings_page;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/gold_rate_service.dart';
import 'live_gold_page.dart';
import 'dart:async';

class GemziHome extends StatefulWidget {
  const GemziHome({super.key});

  @override
  State<GemziHome> createState() => _GemziHomeState();
}

class _GemziHomeState extends State<GemziHome> with TickerProviderStateMixin {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color bronze = const Color(0xFFB8962E);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);
  final Color white = Colors.white;
  String userName = "User";
  String selectedLanguage = "EN";
  final PageController _adController = PageController();
  int _currentAdPage = 0;
  double rate24 = 0;
  double rate22 = 0;

  double prev24 = 0;
  double prev22 = 0;

  Future<void> loadGoldRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> history = prefs.getStringList("gold_history") ?? [];

      if (history.isNotEmpty) {
        var todayData = history.last.split("|");

        setState(() {
          rate24 = double.parse(todayData[1]);
          rate22 = double.parse(todayData[2]);
        });
      } else {
        // fallback if no data yet
        double rate = await GoldRateService.getGoldRate();

        setState(() {
          rate24 = rate;
          rate22 = rate * (22 / 24);
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
>>>>>>> 86ffeac0b104d7b114aef97b9a275a77154f2d7b
    }
  }
=======
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
=======
  Future<void> loadGoldRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      List<String> history = prefs.getStringList("gold_history") ?? [];

      if (history.isNotEmpty) {
        var todayData = history.last.split("|");

        setState(() {
          rate24 = double.parse(todayData[1]);
          rate22 = double.parse(todayData[2]);
        });
      } else {
        // fallback if no data yet
        double rate = await GoldRateService.getGoldRate();

        setState(() {
          rate24 = rate;
          rate22 = rate * (22 / 24);
        });
      }
    } catch (e) {
      debugPrint("ERROR: $e");
>>>>>>> 86ffeac0b104d7b114aef97b9a275a77154f2d7b
    }
  }

  @override
  void initState() {
    super.initState();

    // Start gold rate fetch
    loadGoldRate();

    // Start ads carousel
    _startAdScroll();

    Future.microtask(() => _loadUserName()); // 🔥 FIX
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

        if (data != null && data.containsKey('name')) {
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

  void _startAdScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      int nextPage = (_currentAdPage + 1) % 3;

      _adController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      setState(() {
        _currentAdPage = nextPage;
      });

      _startAdScroll();
    });
  }

  @override
  void dispose() {
    _adController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildSideDrawer(),
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
                  _buildTopHeader(),
                  _buildSearchBar(),
                  const SizedBox(height: 15),
                  _buildSavingAdsCarousel(),
                  _buildCategoryList(),
                  _buildLiveGoldRate(),
                  _buildCollectionTitle(),
                  _buildTrendingItems(),
                  _buildARSection(),
                ],
              ),
            ),
          ),
          _buildFloatingNavBar(),
        ],
      ),
    );
  }

  Widget buildSideDrawer() {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // 🔴 CLOSE BUTTON
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 🔥 TOP CARD (LOGIN / PROFILE)
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

          // 📂 MENU LIST
          Expanded(
            child: ListView(
              children: [
                _menuItem(Icons.all_inbox, "All Jewellery"),
                _menuItem(Icons.circle, "Gold"),
                _menuItem(Icons.diamond, "Diamond"),
                _menuItem(Icons.earbuds, "Earrings"),
                _menuItem(Icons.circle_outlined, "Rings"),
                _menuItem(Icons.watch, "Daily Wear"),
                _menuItem(Icons.collections, "Collections"),
                _menuItem(Icons.favorite, "Wedding"),
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
              const Text(
                "Flat Rs. 500 off",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("on your first order"),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: const Text("LOGIN",
                        style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 10),
                  const Text("|"),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/signup");
                    },
                    child: const Text("SIGN UP",
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
                    child: const Text(
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

  Widget _menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
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

  // ✅ HEADER UPDATED
  Widget _buildTopHeader() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Icon(Icons.menu, color: richGold),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Gemzi",
              style: TextStyle(
                color: richGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Icons.shopping_cart_outlined, color: textLight),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 16,
              backgroundColor: surfaceDark,
              child: Icon(Icons.person_outline, color: richGold),
            ),
          ],
        ),
      ),
    );
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search categories...",
              hintStyle: TextStyle(color: textSubdued),
              prefixIcon: Icon(Icons.search, color: textSubdued),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavingAdsCarousel() {
    List<Map<String, String>> ads = [
      {"title": "Saving Schemes", "subtitle": "Get 10% Extra Gold"},
      {"title": "Refer Friend", "subtitle": "Earn Cashback"},
      {"title": "Festive Offer", "subtitle": "Free Making Charge"},
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _adController,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [richGold, bronze]),
                ),
                child: Center(
                  child: Text(
                    "${ads[index]["title"]}\n${ads[index]["subtitle"]}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentAdPage == index ? richGold : textSubdued,
              ),
            );
          }),
        )
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
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
                              color: richGold.withValues(alpha: 0.4),
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
                      Text(
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
            border: Border.all(color: richGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.show_chart, color: Colors.green),
              const SizedBox(width: 10),
              Text("Gold Rate Live", style: TextStyle(color: textLight)),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate24 == 0
                        ? "Loading..."
                        : "24K: ₹${rate24.toStringAsFixed(2)} / gm",
                    style:
                        TextStyle(color: richGold, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    rate22 == 0
                        ? ""
                        : "22K: ₹${rate22.toStringAsFixed(2)} / gm",
                    style: TextStyle(color: textSubdued),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 15, bottom: 10),
      child: Text(
        "Our Collection",
        style: TextStyle(
            color: textLight, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildTrendingItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trendingItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          final item = trendingItems[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(
                    name: item["name"] ?? "",
                    price: item["price"] ?? "",
                    image: item["image"] ?? "",
                    rating: "4.5",
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.asset(
                      item["image"] ?? "",
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(item["name"] ?? "",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(item["price"] ?? "",
                            style: TextStyle(
                                color: richGold, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildARSection() {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [surfaceDark, darkBg]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: richGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Try Jewellery in AR",
                    style: TextStyle(
                        color: richGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [richGold, bronze]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      "Try Now",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.camera_alt_outlined,
              size: 60,
              color: richGold.withValues(alpha: 0.5),
            ),
          ],
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
            surfaceDark.withValues(alpha: 0.9),
            darkBg.withValues(alpha: 0.6)
          ],
        ),
        borderGradient: LinearGradient(colors: [richGold, bronze]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Home", true),
            _navItem(Icons.account_balance_wallet, "Wallet", false),
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
            _navItem(Icons.settings, "Setting", false),
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
        Text(label,
            style: TextStyle(
                fontSize: 10, color: active ? richGold : textSubdued)),
      ],
    );
  }

  Widget _buildTryOnButton() {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bronze, richGold]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 5),
            Text(
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
}
