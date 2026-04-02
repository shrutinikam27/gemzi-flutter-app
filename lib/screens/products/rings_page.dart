import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';

class RingsPage extends StatefulWidget {
  const RingsPage({super.key});

  @override
  State<RingsPage> createState() => _RingsPageState();
}

class _RingsPageState extends State<RingsPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  List<Map<String, String>> rings = [
    {
      "name": "Diamond Ring",
      "price": "₹52,000",
      "image": "assets/auth/ring1.jpeg",
      "rating": "4.8"
    },
    {
      "name": "Gold Ring",
      "price": "₹38,500",
      "image": "assets/auth/ring6.jpeg",
      "rating": "4.6"
    },
    {
      "name": "Wedding Ring",
      "price": "₹45,200",
      "image": "assets/auth/ring2.jpeg",
      "rating": "4.7"
    },
    {
      "name": "Diamond Ring",
      "price": "₹85,000",
      "image": "assets/auth/ring5.jpeg",
      "rating": "4.9"
    },
    {
      "name": "Gold Ring",
      "price": "₹61,000",
      "image": "assets/auth/ring4.jpeg",
      "rating": "4.5"
    },
    {
      "name": "Engagement Ring",
      "price": "₹72,000",
      "image": "assets/auth/ring3.jpeg",
      "rating": "4.8"
    },
  ];

  late List<bool> isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = List.generate(rings.length, (index) => false);
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
            "Rings",
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
              .where('category', isEqualTo: 'Ring')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No rings found",
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
                final image = data['imageUrl'] ?? '';
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
                        /// Image from Network
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          child: image.isNotEmpty
                              ? Image.network(
                                  image,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                                )
                              : Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image),
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
}
