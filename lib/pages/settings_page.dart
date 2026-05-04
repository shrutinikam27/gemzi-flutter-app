// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/translated_text.dart';
import '../utils/translator_service.dart';
import 'help_support_page.dart';
import 'payment_methods_page.dart';
import 'privacy_security_page.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';
import 'my_investments_page.dart';

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
  String userName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications = prefs.getBool('push_notifications') ?? true;
    });
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? "User";
        });
      } else {
        setState(() => userName = "User");
      }
    } catch (e) {
      if (mounted) setState(() => userName = "User");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TranslatedText("Settings",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 PREMIUM PROFILE SECTION
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [surfaceDark, surfaceDark.withValues(alpha: 0.6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: richGold.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: darkBg,
                        child: Icon(Icons.person, color: richGold, size: 35),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? "Guest User",
                            style: TextStyle(
                              color: textSubdued,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_note, color: richGold),
                      onPressed: _editProfile,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            _sectionLabel("App Preferences"),
            
            /// 🌐 LANGUAGE
            _buildSettingTile(
              icon: Icons.translate_rounded,
              title: "Display Language",
              subtitle: _getLangName(TranslatorService.currentLang),
              onTap: () => _showLanguagePicker(context),
            ),

            /// 🔔 NOTIFICATIONS
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: "Push Notifications",
              value: notifications,
              onChanged: (val) async {
                if (val) {
                  // 🛡️ Request system permission (Required for Android 13+)
                  var status = await Permission.notification.request();
                  if (status.isDenied) {
                    _showNotImplemented(context); // Shows SnackBar explaining
                    return;
                  }
                }

                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('push_notifications', val);

                setState(() => notifications = val);

                NotificationService.showNotification(
                  val ? "Gemzi Alerts Active 🔔" : "Notifications Paused ❌",
                  val ? "Great! You will now receive live gold rates and order updates." : "You've successfully disabled push updates.",
                );
              },
            ),

            const SizedBox(height: 25),
            _sectionLabel("Account & Security"),

            _buildSettingTile(
              icon: Icons.wallet_membership_rounded,
              title: "Payment Methods",
              subtitle: "Saved cards & UPI",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
                );
              },
            ),

            _buildSettingTile(
              icon: Icons.workspace_premium_outlined,
              title: "My Saving Schemes",
              subtitle: "Track your SIPs & Gold",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyInvestmentsPage()),
                );
              },
            ),

            _buildSettingTile(
              icon: Icons.verified_user_outlined,
              title: "Privacy & Security",
              subtitle: "Manage your data",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacySecurityPage()),
                );
              },
            ),

            _buildSettingTile(
              icon: Icons.help_center_outlined,
              title: "Support Center",
              subtitle: "Contact us & FAQ",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpSupportPage()),
                );
              },
            ),

            const SizedBox(height: 40),

            /// 🚪 LOGOUT
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const TranslatedText(
                  "Logout Account",
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _confirmLogout(context),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                "Gemzi Boutique v1.2.0",
                style: TextStyle(color: textSubdued.withValues(alpha: 0.5), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: TranslatedText(
        label,
        style: TextStyle(color: richGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: richGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: richGold, size: 20),
        ),
        title: TranslatedText(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        subtitle: TranslatedText(subtitle, style: TextStyle(color: textSubdued, fontSize: 11)),
        trailing: Icon(Icons.chevron_right_rounded, color: textSubdued, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        activeColor: richGold,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: richGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: richGold, size: 20),
        ),
        title: TranslatedText(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TranslatedText("Select Language 🌐", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _langItem("en", "🇺🇸", "English"),
              _langItem("hi", "🇮🇳", "Hindi (हिंदी)"),
              _langItem("mr", "🇮🇳", "Marathi (मराठी)"),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _langItem(String code, String emoji, String name) {
    bool isSelected = TranslatorService.currentLang == code;
    return GestureDetector(
      onTap: () async {
        await TranslatorService.saveLanguage(code);
        setState(() => TranslatorService.currentLang = code);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected ? richGold.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? richGold : Colors.white12),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 15),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle_rounded, color: richGold),
          ],
        ),
      ),
    );
  }

  String _getLangName(String code) {
    switch (code) {
      case "hi": return "Hindi (हिंदी)";
      case "mr": return "Marathi (मराठी)";
      default: return "English";
    }
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: TranslatedText("This feature is coming soon to Gemzi Boutique!")),
    );
  }

  void _editProfile() {
    final TextEditingController nameController = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceDark,
          title: const TranslatedText("Edit Profile", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(color: textSubdued),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: richGold.withValues(alpha: 0.5))),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: richGold)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TranslatedText("Cancel", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
                      'name': newName,
                    }, SetOptions(merge: true));
                    setState(() {
                      userName = newName;
                    });
                  }
                }
                Navigator.pop(context);
              },
              child: Text("Save", style: TextStyle(color: richGold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const TranslatedText("Logout", style: TextStyle(color: Colors.white)),
        content: const TranslatedText("Are you sure you want to sign out?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }
}
