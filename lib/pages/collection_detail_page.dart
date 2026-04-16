import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/translated_text.dart';
import '../services/gold_rate_service.dart';
import 'individual_item_page.dart';

class CollectionDetailPage extends StatefulWidget {
  final String collectionName;

  const CollectionDetailPage({super.key, required this.collectionName});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  double goldRate = 0.0;
  bool isLoading = true;

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  // Section-wise Mock Data
  final Map<String, List<Map<String, dynamic>>> collectionData = {
    "Bridal Collection": [
      {"name": "Royal Bridal Necklace", "image": "assets/auth/nacklace6.jpeg", "weight": 45.0, "desc": "Exquisite 22K gold bridal necklace featuring intricate Kundan work and handcrafted floral motifs."},
      {"name": "Heritage Gold Haram", "image": "assets/auth/heritagegoldharam.png", "weight": 58.5, "desc": "Traditional long South Indian temple haram with antique gold finish and divine craftsmanship."},
      {"name": "Wedding Bangle Set", "image": "assets/auth/bangles.jpeg", "weight": 34.0, "desc": "Set of handcrafted traditional gold bangles with intricate filigree patterns and ruby accents."},
      {"name": "Temple Bridal Set", "image": "assets/auth/templejhumka.jpeg", "weight": 72.0, "desc": "Complete bridal set featuring goddess Lakshmi earrings and matching temple style pendant."},
    ],
    "Festive Special": [
      {"name": "Kundan Festive Set", "image": "assets/auth/nacklace6.jpeg", "weight": 28.5, "desc": "Vibrant festive necklace set with premium Kundan stones and gold plating."},
      {"name": "Gold Flower Ring", "image": "assets/auth/ring6.jpeg", "weight": 8.2, "desc": "Elegant 22K gold ring in a blooming flower design, perfect for celebratory moments."},
      {"name": "Meenakari Jhumkas", "image": "assets/auth/crystalstuds.jpeg", "weight": 14.5, "desc": "Traditional Jhumkas featuring colorful Meenakari enamel work and gold beads."},
      {"name": "Choker Necklace", "image": "assets/auth/jewellery1.jpeg", "weight": 22.0, "desc": "Contemporary gold choker with geometric patterns and a polished finish."},
    ],
    "Temple Jewellery": [
      {"name": "Antique Lakshmi Haram", "image": "assets/auth/temple.jpeg", "weight": 65.0, "desc": "Traditional antique gold Haram featuring heavy Lakshmi coin work and premium craftsmanship."},
      {"name": "Temple Jhumkas", "image": "assets/auth/templejhumka.jpeg", "weight": 18.5, "desc": "Classic South Indian temple jhumkas with ruby and emerald stone settings."},
      {"name": "Divine Idol Pendant", "image": "assets/auth/jewellery1.jpeg", "weight": 12.0, "desc": "Handcrafted gold pendant featuring Lord Ganesha in a traditional heritage style."},
      {"name": "Bridal Temple Set", "image": "assets/auth/nacklace6.jpeg", "weight": 85.0, "desc": "Magnificent full bridal set with heavy temple motifs and handcrafted gold beads."},
    ],
    "Royal Pearl Set": [
      {"name": "Creamy Pearl Necklace", "image": "assets/auth/pearlnecklace.jpeg", "weight": 15.0, "desc": "Elegant single layer necklace featuring premium saltwater pearls and gold clasp."},
      {"name": "Pearl Drop Earrings", "image": "assets/auth/crystalstuds.jpeg", "weight": 6.5, "desc": "Simple yet royal pearl drop earrings set in 18K gold."},
      {"name": "Royal Pearl Choker", "image": "assets/auth/royalpearlset.jpeg", "weight": 24.0, "desc": "Multi-layered pearl choker with a central gold motif encrusted with semi-precious stones."},
      {"name": "Pearl Gold Bracelet", "image": "assets/auth/bangles.jpeg", "weight": 12.5, "desc": "Flexible gold bracelet woven with fine seed pearls for a sophisticated look."},
    ],
    "Luxury Rings": [
      {"name": "Diamond Gold Band", "image": "assets/auth/luxuryring.jpeg", "weight": 6.8, "desc": "Minimalist premium gold band with pavé set diamonds for ultimate luxury."},
      {"name": "Ruby Center Ring", "image": "assets/auth/ring6.jpeg", "weight": 7.5, "desc": "Exquisite 22K gold ring featuring a deep red heart-cut ruby at its center."},
      {"name": "Infinity Diamond Ring", "image": "assets/auth/luxuryring.jpeg", "weight": 5.2, "desc": "Sleek gold ring featuring the infinity symbol encrusted with fine diamonds."},
      {"name": "Royal Signet Ring", "image": "assets/auth/ring6.jpeg", "weight": 9.0, "desc": "Heavy gold signet ring with traditional emblem engraving and matte finish."},
    ],
    "Classic Bangles": [
      {"name": "Gold Kada Pair", "image": "assets/auth/bangles.jpeg", "weight": 42.0, "desc": "Traditional heavy gold Kadas with intricate carving and secure screw locking."},
      {"name": "Antique Leaf Bangles", "image": "assets/auth/bangles.jpeg", "weight": 28.5, "desc": "Handcrafted leaf-patterned bangles with a vintage antique gold polish."},
      {"name": "Bridal Gold Churi", "image": "assets/auth/jewellery1.jpeg", "weight": 55.0, "desc": "Complete set of bridal bangles featuring heavy crafting and gold bead work."},
      {"name": "Filigree Work Bangles", "image": "assets/auth/bangles.jpeg", "weight": 31.0, "desc": "Exquisitely designed bangles featuring the ancient art of gold filigree."},
    ],
    "Diamond Studs": [
      {"name": "Solitaire Studs", "image": "assets/auth/crystalstuds.jpeg", "weight": 4.5, "desc": "Timeless solitaire diamond studs set in 18K white gold prongs."},
      {"name": "Flower Diamond Studs", "image": "assets/auth/crystalstuds.jpeg", "weight": 3.2, "desc": "Charming flower-shaped studs featuring central diamonds and gold petals."},
      {"name": "Cluster Diamond Earrings", "image": "assets/auth/crystalstuds.jpeg", "weight": 5.8, "desc": "Brilliant cluster set diamond studs that capture light from every angle."},
      {"name": "Daily Wear Studs", "image": "assets/auth/crystalstuds.jpeg", "weight": 2.5, "desc": "Compact and sturdy diamond studs designed for everyday elegance."},
    ],
  };

  List<Map<String, dynamic>> _getItems() {
    for (var key in collectionData.keys) {
      if (widget.collectionName.contains(key) || key.contains(widget.collectionName)) {
        return collectionData[key]!;
      }
    }
    return collectionData["Bridal Collection"]!;
  }

  @override
  void initState() {
    super.initState();
    _fetchRate();
  }

  Future<void> _fetchRate() async {
    try {
      final rate = await GoldRateService.getGoldRate();
      if (mounted) {
        setState(() {
          goldRate = rate;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  double _calculatePrice(double weight) {
    if (goldRate == 0) return 0;
    return weight * goldRate * 1.15;
  }

  @override
  Widget build(BuildContext context) {
    final currentItems = _getItems();
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: TranslatedText(widget.collectionName),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: richGold))
          : Column(
              children: [
                /* if (goldRate > 0)
                  FadeInDown(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: richGold.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.trending_up, color: richGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Today's Gold Rate: ₹${goldRate.toStringAsFixed(2)} / gm",
                            style: TextStyle(color: richGold, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ), */
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: currentItems.length,
                    itemBuilder: (context, index) {
                      final item = currentItems[index];
                      final price = _calculatePrice(item['weight']);
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => IndividualItemPage(
                                  item: item,
                                  currentGoldRate: goldRate,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: surfaceDark,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    child: Image.asset(
                                      item['image'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${item['weight']} gm",
                                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goldRate > 0 ? "₹${price.toStringAsFixed(0)}" : "Price on call",
                                        style: TextStyle(color: richGold, fontWeight: FontWeight.bold, fontSize: 14),
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
                  ),
                ),
              ],
            ),
    );
  }
}
