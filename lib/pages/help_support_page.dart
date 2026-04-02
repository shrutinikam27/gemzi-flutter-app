import 'package:flutter/material.dart';
import '../widgets/translated_text.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        title: const TranslatedText("Help & Support"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 💎 TOP INFO (VERY IMPORTANT FOR PRESENTATION)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: richGold.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    "Need Help?",
                    style: TextStyle(
                      color: richGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TranslatedText(
                    "Our team is here to assist you with orders, payments, and gold rates.",
                    style: TextStyle(color: textSubdued),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 📞 CONTACT OPTIONS
            TranslatedText(
              "Contact Support",
              style: TextStyle(
                color: richGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _contactCard(
              icon: Icons.call,
              title: "Call Us",
              subtitle: "+91 98765 43210",
              onTap: () {
                _showMessage(context, "Calling support...");
              },
            ),

            const SizedBox(height: 15),

            _contactCard(
              icon: Icons.email,
              title: "Email Us",
              subtitle: "support@gemzi.com",
              onTap: () {
                _showMessage(context, "Opening email...");
              },
            ),

            const SizedBox(height: 15),

            _contactCard(
              icon: Icons.chat,
              title: "Live Support",
              subtitle: "Chat with us instantly",
              onTap: () {
                _showMessage(context, "Chat coming soon...");
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 CONTACT CARD (Premium Look)
  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: richGold.withAlpha(40),
          child: Icon(icon, color: richGold),
        ),
        title: TranslatedText(
          title,
          style: TextStyle(color: textLight, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: textSubdued),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  /// 🔹 SNACKBAR
  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: richGold,
      ),
    );
  }
}