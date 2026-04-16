import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../themes/app_colors.dart';
import '../screens/products/product_detail_page.dart';
import 'package:animate_do/animate_do.dart';
import '../services/gold_rate_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          "Explore Collections",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          FadeInDown(child: _buildSearchBar()),
          Expanded(
            child: StreamBuilder<double>(
              stream: GoldRateService.goldRateStream(),
              builder: (context, rateSnapshot) {
                final rate = rateSnapshot.data ?? 7200.0;
                
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white70)));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No products found.", style: TextStyle(color: Colors.white70)));
                    }

                    // Filter products based on search
                    final allDocs = snapshot.data!.docs;
                    final filteredDocs = allDocs.where((doc) {
                      final name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? "";
                      return name.contains(searchQuery.toLowerCase());
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(child: Text("No matching products.", style: TextStyle(color: Colors.white70)));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(18),
                      itemCount: filteredDocs.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.65,
                      ),
                      itemBuilder: (context, index) {
                        final data = filteredDocs[index].data() as Map<String, dynamic>;
                        
                        // Dynamic Price Calculation
                        double weight = 0.0;
                        if (data['weight'] != null) {
                          weight = double.tryParse(data['weight'].toString()) ?? 0.0;
                        }
                        final dynamicPrice = (weight * rate * 1.15).toStringAsFixed(0);

                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * (index % 6)),
                          child: _premiumProductCard(context, {
                            ...data,
                            'price': dynamicPrice,
                            'rate': rate,
                            'weightProp': weight,
                          }),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => searchQuery = val),
          onSubmitted: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: "Search collections...",
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            suffixIcon: searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
              : null,
          ),
        ),
      ),
    );
  }

  Widget _premiumProductCard(BuildContext context, Map<String, dynamic> data) {
    final String title = data['name'] ?? "Jewellery";
    final String img = data['imageUrl'] ?? data['image'] ?? "";
    final String price = data['price']?.toString() ?? "0";
    final double weight = data['weightProp'] ?? 0.0;
    final double currentRate = data['rate'] ?? 7200.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(
              name: title,
              price: "₹$price",
              image: img,
              rating: "4.8",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildImage(img),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${weight}g",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
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
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 2),
                  const SizedBox(height: 4),
                    const SizedBox(height: 4),
                    Text(
                      "₹$price",
                      style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.trim().isEmpty) return _buildPlaceholder();
    final cleanPath = path.trim();
    
    if (cleanPath.toLowerCase().startsWith('http')) {
      return Image.network(
        cleanPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return Image.asset(
      cleanPath.startsWith('assets/') ? cleanPath : "assets/auth/ring.png",
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF17453F),
      child: const Center(
        child: Icon(Icons.diamond_outlined, color: Color(0xFFD4AF37), size: 40),
      ),
    );
  }
}
