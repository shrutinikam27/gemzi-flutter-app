import 'package:flutter/material.dart';
import 'product_detail_page.dart';
import '../../utils/translator_service.dart';
import '../../widgets/translated_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoinsPage extends StatefulWidget {
  const CoinsPage({super.key});

  @override
  State<CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<CoinsPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(TranslatorService.currentLang),
      child: Scaffold(
        backgroundColor: darkBg,
        appBar: AppBar(
          backgroundColor: surfaceDark,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const TranslatedText(
            "Gold & Silver Coins",
            style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 18),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: 'Coins')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No coins available yet", style: TextStyle(color: Colors.white70)));
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
                final name = data['name'] ?? 'Gold Coin';
                final price = data['price'] ?? 0;
                final image = data['imageUrl'] ?? data['image'] ?? '';
                final rating = data['rating']?.toString() ?? '5.0';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(name: name, price: "₹$price", image: image, rating: rating)));
                  },
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: _buildImage(image),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text("₹$price", style: TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 16)),
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
      cleanPath.startsWith('assets/') ? cleanPath : "assets/auth/coin.jpeg",
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
