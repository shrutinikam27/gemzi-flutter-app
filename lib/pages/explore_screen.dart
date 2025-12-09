import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBeige,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundBeige,
        title: Text(
          "Explore Collections",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.titleBrown,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _categoryHeader("New Arrivals"),
          const SizedBox(height: 12),
          _productCard("assets/auth/1.png", "Rose Gold Heart Ring"),
          const SizedBox(height: 16),
          _productCard("assets/auth/2.png", "Swirl Cross Over Ring"),
          const SizedBox(height: 16),
          _productCard("assets/auth/3.png", "Classic Solitaire Ring"),
        ],
      ),
    );
  }

  Widget _categoryHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.titleBrown,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _productCard(String img, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.floatingShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Image.asset(
              img,
              key: UniqueKey(),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleBrown,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(
                    5,
                    (i) => const Icon(
                      Icons.star,
                      size: 20,
                      color: Color(0xFFD8A45B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
