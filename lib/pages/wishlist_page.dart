import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/wishlist_service.dart';
import '../widgets/translated_text.dart';
import '../screens/products/product_detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color textLight = Colors.white;
  static const Color textSubdued = Color(0xFFB8D1CD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TranslatedText(
          'My Wishlist',
          style: TextStyle(
            color: richGold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Consumer<WishlistService>(
            builder: (context, wishlist, _) {
              if (wishlist.itemCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: surfaceDark,
                      title: const TranslatedText('Clear Wishlist',
                          style: TextStyle(color: textLight)),
                      content: const TranslatedText(
                          'Remove all items from wishlist?',
                          style: TextStyle(color: textSubdued)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const TranslatedText('Cancel',
                              style: TextStyle(color: textSubdued)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const TranslatedText('Clear',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await wishlist.clearWishlist();
                  }
                },
                child: const TranslatedText('Clear',
                    style: TextStyle(color: Colors.redAccent)),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<WishlistService>(
        builder: (context, wishlist, _) {
          if (wishlist.itemCount == 0) {
            return _buildEmptyState(context);
          }
          return _buildWishlistGrid(context, wishlist);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: surfaceDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: richGold.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_border,
              color: richGold,
              size: 56,
            ),
          ),
          const SizedBox(height: 28),
          const TranslatedText(
            'Your Wishlist is Empty',
            style: TextStyle(
              color: textLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: TranslatedText(
              'Save your favourite jewellery pieces here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSubdued, fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [richGold, Color(0xFFB8860B)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: richGold.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const TranslatedText(
                'Explore Collection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistGrid(BuildContext context, WishlistService wishlist) {
    final items = wishlist.items;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _WishlistCard(item: item);
      },
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItem item;

  const _WishlistCard({required this.item});

  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color textLight = Colors.white;
  static const Color textSubdued = Color(0xFFB8D1CD);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: item.name,
              price: item.price,
              image: item.image,
              rating: item.rating,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
                    child: item.image.startsWith('http')
                        ? Image.network(
                            item.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: darkBg,
                              child: const Center(
                                child: Icon(Icons.diamond_outlined,
                                    color: richGold, size: 36),
                              ),
                            ),
                          )
                        : Image.asset(
                            item.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: darkBg,
                              child: const Center(
                                child: Icon(Icons.diamond_outlined,
                                    color: richGold, size: 36),
                              ),
                            ),
                          ),
                  ),
                  // Remove button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistService>(
                      builder: (context, wishlist, _) => GestureDetector(
                        onTap: () {
                          wishlist.removeItem(item.name);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: TranslatedText('Removed from Wishlist'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: darkBg.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      color: textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.price.startsWith('₹')
                        ? item.price
                        : '₹${item.price}',
                    style: const TextStyle(
                      color: richGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
