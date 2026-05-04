import 'package:flutter/material.dart';
import '../widgets/translated_text.dart';
import 'my_orders_page.dart';


class OrderSuccessPage extends StatefulWidget {
  final String orderId;

  const OrderSuccessPage({super.key, required this.orderId});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color textLight = Colors.white;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: surfaceDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: richGold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const TranslatedText(
                'Order Placed Successfully!',
                style: TextStyle(
                  color: richGold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const TranslatedText(
                'Thank you for your purchase.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: ${widget.orderId}',
                style: const TextStyle(color: textLight, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyOrdersPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: richGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const TranslatedText(
                    'View My Orders',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to the main app root/home page
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: richGold, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const TranslatedText(
                    'Continue Shopping',
                    style: TextStyle(
                      color: richGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
