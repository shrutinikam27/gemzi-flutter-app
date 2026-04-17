import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/translated_text.dart';
import 'collection_detail_page.dart';

class ExclusiveCollectionsPage extends StatelessWidget {
  const ExclusiveCollectionsPage({super.key});

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const TranslatedText(
          "Exclusive Collections",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('collections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
          }

          // Combined list: Default local collections + Firestore collections
          List<Map<String, String>> collections = [
            {"name": "Bridal Collection", "image": "assets/auth/nacklace6.jpeg", "desc": "Make your special day more sparkle."},
            {"name": "Festive Special", "image": "assets/auth/ring6.jpeg", "desc": "Celebrate moments with high-end gold."},
            {"name": "Royal Pearl Set", "image": "assets/auth/royalpearlset.jpeg", "desc": "Elegant pearls for a timeless look."},
            {"name": "Temple Jewellery", "image": "assets/auth/templejhumka.jpeg", "desc": "Traditional heritage pieces."},
            {"name": "Luxury Rings", "image": "assets/auth/luxuryring.jpeg", "desc": "Exclusive diamond and gold bands."},
            {"name": "Classic Bangles", "image": "assets/auth/bangles.jpeg", "desc": "Traditional gold bangles collection."},
            {"name": "Diamond Studs", "image": "assets/auth/crystalstuds.jpeg", "desc": "Sparkle every day with diamond studs."},
          ];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              collections.add({
                "name": data['name']?.toString() ?? "Collection",
                "image": data['imageUrl']?.toString() ?? "",
                "desc": data['description']?.toString() ?? "Explore our finest pieces."
              });
            }
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              final col = collections[index];
              return FadeInUp(
                delay: Duration(milliseconds: 100 * (index % 5)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailPage(
                          collectionName: col['name']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: _buildDecorationImage(col['image']),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8)
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            col['name']!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          const SizedBox(height: 5),
                          TranslatedText(
                            col['desc']!,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DecorationImage? _buildDecorationImage(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final cleanPath = path.trim();
    
    ImageProvider provider;
    if (cleanPath.toLowerCase().startsWith('http')) {
      provider = NetworkImage(cleanPath);
    } else {
      provider = AssetImage(cleanPath.startsWith('assets/') ? cleanPath : "assets/auth/ring.png");
    }

    return DecorationImage(
      image: provider,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
    );
  }
}
