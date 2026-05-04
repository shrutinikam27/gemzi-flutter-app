import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'live_chat_page.dart';
import '../widgets/translated_text.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  // 📞 Call Action
  Future<void> _makeCall() async {
    final Uri url = Uri.parse('tel:+919876543210');
    if (!await launchUrl(url)) {
      debugPrint("Could not launch dialer");
    }
  }

  // 📧 Email Action
  Future<void> _sendEmail() async {
    final Uri url = Uri.parse('mailto:support@gemzi.com?subject=Inquiry from Gemzi Botique&body=Hi Gemzi Team,');
    if (!await launchUrl(url)) {
       debugPrint("Could not launch email app");
    }
  }

  // 💬 Live Support Simulation
  void _showLiveChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Icon(Icons.chat_bubble_outline_rounded, color: richGold, size: 50),
            const SizedBox(height: 15),
            const TranslatedText("Gemzi Live Concierge", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const TranslatedText("Our experts are online and ready to help.", style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const LiveChatPage())
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: richGold, foregroundColor: darkBg, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const TranslatedText("Start Chat Now"),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TranslatedText("Help & Support", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 💎 TOP INFO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: richGold.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    "How can we help you?",
                    style: TextStyle(color: richGold, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TranslatedText(
                    "Whether it's an order query or gold rate info, our boutique team is on standby.",
                    style: TextStyle(color: textSubdued, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            _sectionLabel("Contact Channels"),

            _contactCard(
              icon: Icons.call_rounded,
              title: "Customer Helpline",
              subtitle: "+91 98765 43210",
              onTap: _makeCall,
            ),

            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.email_outlined,
              title: "Email Assistance",
              subtitle: "support@gemzi.com",
              onTap: _sendEmail,
            ),

            const SizedBox(height: 12),

            _contactCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: "Live Concierge",
              subtitle: "Instant chat with an expert",
              onTap: () => _showLiveChat(context),
            ),

            const Spacer(),
            Center(
              child: TranslatedText("Gemzi Boutique Support v1.0", style: TextStyle(color: textSubdued, fontSize: 10)),
            )
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: TranslatedText(
        label,
        style: TextStyle(color: richGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: richGold.withValues(alpha: 0.1),
          child: Icon(icon, color: richGold, size: 20),
        ),
        title: TranslatedText(title, style: TextStyle(color: textLight, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: textSubdued, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
        onTap: onTap,
      ),
    );
  }
}
