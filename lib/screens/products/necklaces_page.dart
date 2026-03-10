import 'package:flutter/material.dart';
import 'product_detail_page.dart'; // ✅ fixed import path

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

  /// ✅ fixed so length always matches rings
  late List<bool> isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = List.generate(rings.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Rings",
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontSize: 22,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final ring = rings[index];

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
                    color: Colors.black.withOpacity(0.08),
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
