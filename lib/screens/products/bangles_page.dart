import 'package:flutter/material.dart';
import 'product_detail_page.dart'; // ✅ fixed import path

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

  /// ✅ fixed so length always matches rings
  late List<bool> isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = List.generate(necklace.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Bangles",
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: necklace.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final ring = necklace[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    name: ring["name"]!,
                    price: ring["price"]!,
                    image: ring["image"]!,
                    rating: ring["rating"]!,
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
                  /// Image + Like Button
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.asset(
                          ring["image"]!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// Like Button
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isLiked[index] = !isLiked[index];
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isLiked[index]
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color:
                                    isLiked[index] ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Ring Name
                        Text(
                          ring["name"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 4),

                        /// Rating
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              ring["rating"]!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        /// Price
                        Text(
                          ring["price"]!,
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
    );
  }
}
