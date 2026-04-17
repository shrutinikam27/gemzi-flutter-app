import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';


class NecklacesPage extends StatefulWidget {
  const NecklacesPage({super.key});

  @override
  State<NecklacesPage> createState() => _NecklacesPageState();
}

class _NecklacesPageState extends State<NecklacesPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  List<Map<String, String>> necklace = [
    {
      "name": "Pearl Necklace",
      "price": "₹55,000",
      "image": "assets/auth/nacklace1.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Pearl Necklace",
      "price": "₹65,500",
      "image": "assets/auth/nacklace2.jpeg",
      "rating": "4.6"
    },
    {
      "name": "Royal Necklace",
      "price": "₹80,200",
      "image": "assets/auth/nacklace3.jpeg",
      "rating": "4.7"
    },
    {
      "name": "Authentic Necklace",
      "price": "₹60,000",
      "image": "assets/auth/nacklace4.jpeg",
      "rating": "4.9"
    },
    {
      "name": "Authentic Necklace",
      "price": "₹61,000",
      "image": "assets/auth/nacklace5.jpeg",
      "rating": "4.5"
    },
    {
      "name": "Diamond Necklace",
      "price": "₹90,000",
      "image": "assets/auth/nacklace6.jpeg",
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
            "Necklaces",
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
              .where('category', isEqualTo: 'Necklaces')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No necklaces found",
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
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Image from Network
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
      cleanPath.startsWith('assets/') ? cleanPath : "assets/auth/necklace.png",
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
