import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';
import '../../services/gold_rate_service.dart';

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
        body: StreamBuilder<double>(
          stream: GoldRateService.goldRateStream(),
          builder: (context, rateSnapshot) {
            final rate = rateSnapshot.data ?? 7200.0;
            
            return Column(
              children: [
                // 🛰️ Live Market Rate Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: surfaceDark.withValues(alpha: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.show_chart, color: Color(0xFFD4AF37), size: 18),
                          SizedBox(width: 8),
                          TranslatedText("Market Rate (22K)", style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                      Text(
                        "₹${rate.toStringAsFixed(2)}/g",
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('category', whereIn: ['Necklaces', 'necklaces', 'necklace', 'Necklace', 'NECKLACES'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No necklaces found", style: TextStyle(color: Colors.white70)));
                      }
                      final docs = snapshot.data!.docs;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 18,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'Necklace Piece';
                          final image = data['imageUrl'] ?? data['image'] ?? '';
                          
                          double weight = 0.0;
                          if (data['weight'] != null) {
                            weight = double.tryParse(data['weight'].toString()) ?? 0.0;
                          }
                          final dynamicPrice = (weight * rate * 1.15).toStringAsFixed(0);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(
                                    name: name,
                                    price: "₹$dynamicPrice",
                                    image: image,
                                    rating: "4.8",
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: surfaceDark,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                          child: _buildImage(image),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                                            child: Text("${weight}g", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text("₹$dynamicPrice", style: TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
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
