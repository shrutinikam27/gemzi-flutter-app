import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../screens/products/product_detail_page.dart';
import '../widgets/translated_text.dart';
import '../services/gold_rate_service.dart';

class WeddingCollectionPage extends StatelessWidget {
  const WeddingCollectionPage({super.key});

  final List<Map<String, dynamic>> bridalItems = const [
    {
      "name": "Royal Polki Set",
      "weight": 17.5,
      "image": "assets/auth/royalpearlset.jpeg",
      "rating": "5.0"
    },
    {
      "name": "Diamond Bloom Necklace",
      "weight": 38.0,
      "image": "assets/auth/necklacenew2.png",
      "rating": "4.9"
    },
    {
      "name": "Temple Gold Haram",
      "weight": 25.0,
      "image": "assets/auth/heritagegoldharam.png",
      "rating": "5.0"
    },
    {
      "name": "Bridal Emerald Choker",
      "weight": 22.0,
      "image": "assets/auth/nacklace3.jpeg",
      "rating": "4.8"
    }
  ];

  String _calculatePrice(double weight) {
    double rate = GoldRateService.currentRate;
    return "₹${(weight * rate * 1.15).toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF0F2F2B);
    const Color surfaceDark = Color(0xFF17453F);
    const Color richGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: darkBg,
      body: CustomScrollView(
        slivers: [
          // 🎥 CINEMATIC APP BAR
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: surfaceDark,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("ROYAL BRIDAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/auth/nacklace6.jpeg",
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [darkBg, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 💎 COLLECTION INTRO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                   FadeInUp(
                     child: const TranslatedText(
                      "Crafted for Eternal Moments",
                      style: TextStyle(color: richGold, fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                   ),
                   const SizedBox(height: 10),
                   const TranslatedText(
                      "Explore our most exclusive bridal sets, handcrafted for the queen in you.",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                      textAlign: TextAlign.center,
                   ),
                ],
              ),
            ),
          ),

          // 🎁 BRIDAL GALLERY
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // 🔥 LARGE CARDS FOR IMPACT
                mainAxisSpacing: 20,
                childAspectRatio: 1.2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = bridalItems[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: GestureDetector(
                      onTap: () {
                        final calculatedPrice = _calculatePrice(item['weight'] ?? 0.0);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(
                          name: item['name']!,
                          price: calculatedPrice,
                          image: item['image']!,
                          rating: item['rating']!,
                        )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                                child: item['image']!.startsWith('http')
                                    ? Image.network(item['image']!, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: surfaceDark, child: const Icon(Icons.diamond_outlined, color: richGold, size: 50)))
                                    : Image.asset(item['image']!, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(color: surfaceDark, child: const Icon(Icons.diamond_outlined, color: richGold, size: 50))),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                      Text(_calculatePrice(item['weight'] ?? 0.0), style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: richGold, borderRadius: BorderRadius.circular(10)),
                                    child: const Text("VIEW DETAILS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: bridalItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
