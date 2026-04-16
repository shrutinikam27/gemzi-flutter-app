import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BanglesPage extends StatefulWidget {
  const BanglesPage({super.key});

  @override
  State<BanglesPage> createState() => _BanglesPageState();
}

class _BanglesPageState extends State<BanglesPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  List<Map<String, String>> necklace = [
    {
      "name": "Straight Bangle",
      "price": "₹50,000",
      "image": "assets/auth/starlightbangles.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Royal Pearl Bangle",
      "price": "₹70,500",
      "image": "assets/auth/royalpearlset.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Pearl Blossom Bangle",
      "price": "₹65,200",
      "image": "assets/auth/pearlblossombangles.jpeg",
      "rating": "4.7"
    },
    {
      "name": "Temple Carved Bangle",
      "price": "₹60,000",
      "image": "assets/auth/templecarvedbangles.jpeg",
      "rating": "4.9"
    },
    {
      "name": "Leaf Gold Bangles",
      "price": "₹85,000",
      "image": "assets/auth/leafgoldbangles.jpeg",
      "rating": "4.5"
    },
    {
      "name": "Slim Pattern Bangles",
      "price": "₹70,000",
      "image": "assets/auth/slimpatternbangles.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Crystal Bridal Bangles",
      "price": "₹75,000",
      "image": "assets/auth/crystalbridalbangles.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Kundan Kada",
      "price": "₹70,000",
      "image": "assets/auth/kundankada.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Classic Gold Bangles",
      "price": "₹60,000",
      "image": "assets/auth/classicgoldbangles.jpeg",
      "rating": "4.8"
    },
  ];

  late List<bool> isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = List.generate(necklace.length, (index) => false);
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
            "Bangles",
            style: TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontSize: 22,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: 'Bangles')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No bangles found",
                      style: TextStyle(color: Colors.white70)));
            }
            final docs = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final name = data['name'] ?? 'Unnamed';
                final price = data['price'] ?? 0;
                final image = data['imageUrl'] ?? data['image'] ?? '';
                final rating = data['rating']?.toString() ?? '4.5';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          name: name,
                          price: "₹$price",
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
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: _buildImage(image),
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
                                "₹$price",
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    final cleanPath = path.trim();
    if (cleanPath.isEmpty) return _buildPlaceholder();
    
    if (cleanPath.toLowerCase().startsWith('http')) {
      return Image.network(
        cleanPath,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return Image.asset(
      cleanPath.startsWith('assets/') ? cleanPath : "assets/auth/ring.png",
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: const Color(0xFF17453F),
      child: const Center(
        child: Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 40),
      ),
    );
  }
}
