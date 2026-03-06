import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';

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
  final Color textLight = const Color(0xFFFFFFFF);
  final Color textSubdued = const Color(0xFFB8D1CD);
  final Color white = Colors.white;

  final PageController _adController = PageController();
  int _currentAdPage = 0;

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

  final List<Map<String, String>> trendingItems = [
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
  void initState() {
    super.initState();
    _initAdCarousel();
  }

  void _initAdCarousel() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _adController.addListener(() {
          setState(() {
            _currentAdPage = _adController.page?.round() ?? 0;
          });
        });
        _startAdScroll();
      }
    });
  }

  void _startAdScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        final nextPage = (_currentAdPage + 1) % 3;
        _adController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAdScroll();
      }
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
      backgroundColor: darkBg,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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

  Widget _buildTopHeader() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              "Gemzi",
              style: TextStyle(
                color: richGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Text("Hello", style: TextStyle(color: textSubdued)),
            const Spacer(),
            Icon(Icons.shopping_cart_outlined, color: textLight),
            const SizedBox(width: 15),
            CircleAvatar(
              radius: 16,
              backgroundColor: surfaceDark,
              child: Icon(Icons.person_outline, color: richGold),
            ),
            const SizedBox(width: 15),
            Row(
              children: [
                Icon(Icons.translate, color: textLight, size: 18),
                const Icon(Icons.keyboard_arrow_down,
                    size: 14, color: Colors.white),
              ],
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

    return FadeInRight(
      child: Column(
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
                      "${ads[index]['title']}\n${ads[index]['subtitle']}",
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
          ),
        ],
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
              return Container(
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
                            color: richGold.withOpacity(0.4),
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
                      style: TextStyle(color: textLight, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollectionTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 15, bottom: 10),
      child: Text(
        "Our Collection",
        style: TextStyle(
          color: textLight,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
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

          return Container(
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
                    item["image"]!,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        item["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item["price"]!,
                        style: TextStyle(
                          color: richGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLiveGoldRate() {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: richGold.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.show_chart, color: Colors.green),
            const SizedBox(width: 10),
            Text("Gold Rate Live", style: TextStyle(color: textLight)),
            const Spacer(),
            Text("₹6,840/gm",
                style: TextStyle(color: richGold, fontWeight: FontWeight.bold)),
          ],
        ),
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
          border: Border.all(color: richGold.withOpacity(0.3)),
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
                  GestureDetector(
                    onTap: () => HapticFeedback.mediumImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                  ),
                ],
              ),
            ),
            Icon(
              Icons.camera_alt_outlined,
              size: 60,
              color: richGold.withOpacity(0.5),
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
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [surfaceDark.withOpacity(0.9), darkBg.withOpacity(0.6)],
        ),
        borderGradient: LinearGradient(colors: [richGold, bronze]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_filled, "Home", true),
            _navItem(Icons.account_balance_wallet, "Wallet", false),
            _buildTryOnButton(),
            _navItem(Icons.trending_up, "Live", false),
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
        Text(
          label,
          style: TextStyle(
              fontSize: 10,
              color: active ? richGold : textSubdued,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTryOnButton() {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bronze, richGold]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              "Try-On",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
