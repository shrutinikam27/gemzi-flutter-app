import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/translated_text.dart';
import '../utils/translator_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textLight = Colors.white;
  final Color textSubdued = const Color(0xFFB8D1CD);

  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: surfaceDark,
        title: const TranslatedText("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 👤 PROFILE CARD
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.email ?? "User",
                      style: TextStyle(color: textLight),
                    ),
                    Text(
                      "Premium Member",
                      style: TextStyle(color: textSubdued, fontSize: 12),
                    )
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 🌐 LANGUAGE
          _tile(
            icon: Icons.language,
            title: "Language",
            onTap: () => _showLanguageDialog(context),
          ),

          /// 🔔 NOTIFICATIONS
          SwitchListTile(
            value: notifications,
            onChanged: (val) {
              setState(() => notifications = val);
            },
            activeColor: richGold,
            title: const TranslatedText("Notifications"),
            secondary: Icon(Icons.notifications, color: richGold),
          ),

          /// 🌙 DARK MODE (future use)
          _tile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            onTap: () {},
          ),

          /// 📍 ADDRESS
          _tile(
            icon: Icons.location_on,
            title: "Manage Address",
            onTap: () {},
          ),

          /// 💳 PAYMENTS
          _tile(
            icon: Icons.payment,
            title: "Payment Methods",
            onTap: () {},
          ),

          /// 🔐 PRIVACY
          _tile(
            icon: Icons.lock,
            title: "Privacy & Security",
            onTap: () {},
          ),

          /// ❓ HELP
          _tile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {},
          ),

          const SizedBox(height: 20),

          /// 🚪 LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const TranslatedText(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, "/login");
            },
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: richGold),
      title: TranslatedText(title, style: TextStyle(color: textLight)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("English"),
              onTap: () => _changeLang("en"),
            ),
            ListTile(
              title: const Text("हिंदी"),
              onTap: () => _changeLang("hi"),
            ),
            ListTile(
              title: const Text("मराठी"),
              onTap: () => _changeLang("mr"),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLang(String code) async {
    await TranslatorService.saveLanguage(code);
    setState(() {
      TranslatorService.currentLang = code;
    });
    Navigator.pop(context);
  }
}