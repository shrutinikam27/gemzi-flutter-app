import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          (_scrollController.offset + 1) %
              _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: AppColors.lightBeige,
        elevation: 0,
        title: Text(
          "Gemzi",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.titleBrown,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.titleBrown,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.titleBrown,
              ),
            ),
            const SizedBox(height: 10),
            _buildAutoScrollCategories(),
            const SizedBox(height: 30),
            Text(
              "Trending Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.titleBrown,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  TrendingCard(
                      img: "assets/auth/1.png",
                      name: "Diamond Ring",
                      price: "₹ 50,000"),
                  TrendingCard(
                      img: "assets/auth/earring.png",
                      name: "Emerald Earrings",
                      price: "₹ 35,000"),
                  TrendingCard(
                      img: "assets/auth/necklace.png",
                      name: "Gold Necklace",
                      price: "₹ 95,000"),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Try Jewellery in AR",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.titleBrown,
              ),
            ),
            const SizedBox(height: 12),
            _arTryOnCard(),
          ],
        ),
      ),
    );
  }

  // 🔥 AUTO-SCROLL CATEGORY CARDS
  Widget _buildAutoScrollCategories() {
    final categories = [
      {"name": "Rings", "img": "assets/auth/1.png"},
      {"name": "Necklaces", "img": "assets/auth/necklace.png"},
      {"name": "Earrings", "img": "assets/auth/earring.png"},
      {"name": "Bangles", "img": "assets/auth/bangle.png"},
      {"name": "Coins", "img": "assets/auth/coin.png"},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _categoryCard(
            name: cat["name"]!,
            img: cat["img"]!,
          );
        },
      ),
    );
  }

  // ---------- CATEGORY CARD ----------
  Widget _categoryCard({required String name, required String img}) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(img, height: 60, width: 60, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: AppColors.subtitleBrown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- AR TRY ON CARD ----------
  Widget _arTryOnCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.camera_alt,
              size: 32,
              color: AppColors.roseGold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Use AR camera to try Rings, Earrings & Necklaces virtually.",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.subtitleBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Try Now",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

// ---------- TRENDING CARD ----------
class TrendingCard extends StatelessWidget {
  final String img;
  final String name;
  final String price;

  const TrendingCard(
      {super.key, required this.img, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.softShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              img,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.titleBrown,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: AppColors.subtitleBrown,
            ),
          ),
        ],
      ),
    );
  }
}
