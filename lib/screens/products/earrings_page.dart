import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EarringsPage extends StatefulWidget {
  const EarringsPage({super.key});

  @override
  State<EarringsPage> createState() => _EarringsPageState();
}

class _EarringsPageState extends State<EarringsPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  List<Map<String, String>> earrings = [
    {
      "name": "Crystal Drops",
      "price": "₹50,000",
      "image": "assets/auth/earringnew.png",
      "rating": "4.8"
    },
    {
      "name": "Pearl Bow Earrings",
      "price": "₹65,200",
      "image": "assets/auth/pearlbowerrings.png",
      "rating": "4.7"
    },
    {
      "name": "Pearl Rose Earrings",
      "price": "₹60,000",
      "image": "assets/auth/pearlroseearrings.png",
      "rating": "4.9"
    },
    {
      "name": "Crystal Studs",
      "price": "₹60,000",
      "image": "assets/auth/crystalstuds.png",
      "rating": "4.8"
    },
    {
      "name": "Golden Loop Drops",
      "price": "₹85,000",
      "image": "assets/auth/goldenloopdrops.png",
      "rating": "4.5"
    },
    {
      "name": "Sapphire Jhumka",
      "price": "₹70,000",
      "image": "assets/auth/sapphirejhumka.png",
      "rating": "4.8"
    },
    {
      "name": "Lotus Jhumka",
      "price": "₹60,000",
      "image": "assets/auth/lotusjhumka.png",
      "rating": "4.8"
    },
    {
      "name": "Temple Jhumka",
      "price": "₹75,000",
      "image": "assets/auth/templejhumka.png",
      "rating": "4.8"
    },
    {
      "name": "Royal Leaf Chandbali",
      "price": "₹70,000",
      "image": "assets/auth/royalleafchandbali.png",
      "rating": "4.8"
    },
  ];

  late List<bool> isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = List.generate(earrings.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: surfaceDark,
          iconTheme: const IconThemeData(color: Colors.white),

          // ✅ translated title
          title: const TranslatedText(
            "Earrings",
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 22,
            ),
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: earrings.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final data = earrings[index];
            final name = data['name'] ?? 'Unnamed';
            final price = data['price'] ?? '₹0';
            final image = data['image'] ?? '';
            final rating = data['rating'] ?? '4.5';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      name: name,
                      price: price,
                      image: image,
                      rating: rating,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: Image.asset(
                        image,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.orange),
                              const SizedBox(width: 3),
                              Text(rating, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            price,
                            style: TextStyle(
                              color: richGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
