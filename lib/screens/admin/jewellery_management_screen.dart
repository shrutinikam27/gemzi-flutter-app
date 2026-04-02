import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../themes/admin_theme.dart';
import 'add_product_screen.dart';

class JewelleryManagementScreen extends StatelessWidget {
  const JewelleryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminTheme.primaryGreen,
      appBar: AppBar(
        title: const Text("Jewellery Management", style: TextStyle(color: Colors.white)),
        backgroundColor: AdminTheme.surfaceGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AdminTheme.emerald),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AdminTheme.emerald));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No products found. Add one!",
                style: TextStyle(color: AdminTheme.textBody, fontSize: 18),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Unnamed';
              final price = data['price'] ?? 0;
              final category = data['category'] ?? 'General';
              final imageUrl = data['imageUrl'] ?? '';
              
              return _buildProductCard(context, docs[index].id, name, price, category, imageUrl);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, String id, String name, num price, String category, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: AdminTheme.surfaceGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl.isNotEmpty 
                  ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      color: AdminTheme.primaryGreen,
                      child: const Center(child: Icon(Icons.image_not_supported, color: AdminTheme.textBody)),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  category,
                  style: const TextStyle(color: AdminTheme.emerald, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹$price",
                      style: const TextStyle(color: AdminTheme.goldAccent, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    InkWell(
                      onTap: () {
                        // Show delete confirmation
                        _deleteProduct(context, id);
                      },
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _deleteProduct(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AdminTheme.surfaceGreen,
        title: const Text("Delete Product", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this product?", style: TextStyle(color: AdminTheme.textBody)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
