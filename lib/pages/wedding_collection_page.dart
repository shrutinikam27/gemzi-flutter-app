import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../screens/products/product_detail_page.dart';
import '../widgets/translated_text.dart';

class WeddingCollectionPage extends StatelessWidget {
  const WeddingCollectionPage({super.key});

  final List<Map<String, String>> bridalItems = const [
    {
      "name": "Royal Polki Set",
      "price": "₹1,45,000",
      "image": "https://images.unsplash.com/photo-1549439602-43ebca2327af?q=80&w=1000",
      "rating": "5.0"
    },
    {
      "name": "Diamond Bloom Necklace",
      "price": "₹3,20,000",
      "image": "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000",
      "rating": "4.9"
    },
    {
      "name": "Temple Gold Haram",
      "price": "₹2,10,000",
      "image": "https://images.unsplash.com/photo-1610992015732-2449b0c26670?q=80&w=1000",
      "rating": "5.0"
    },
    {
      "name": "Bridal Emerald Choker",
      "price": "₹1,85,000",
      "image": "https://images.unsplash.com/photo-1589128777073-263566ae5e4d?q=80&w=1000",
      "rating": "4.8"
    }
  ];

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
                  Image.network(
                    "https://images.unsplash.com/photo-1549439602-43ebca2327af?q=80&w=1000",
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(
                          name: item['name']!,
                          price: item['price']!,
                          image: item['image']!,
                          rating: item['rating']!,
                        )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                                child: Image.network(item['image']!, width: double.infinity, fit: BoxFit.cover),
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
                                      Text(item['price']!, style: const TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 16)),
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
