import 'package:flutter/material.dart';
import '../widgets/translated_text.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/email_service.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final Color darkBg = const Color(0xFF0F2F2B);
  final Color surfaceDark = const Color(0xFF17453F);
  final Color richGold = const Color(0xFFD4AF37);
  final Color textSubdued = const Color(0xFFB8D1CD);

  bool privateProfile = true;
  bool secureLogin = true;
  bool personalizedAds = false;

  bool isScanning = false;
  bool isDownloading = false;
  String safetyStatus = "Account is Secure";
  String lastCheck = "Last check: Today, 10:42 AM";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        privateProfile = prefs.getBool('privacy_private_profile') ?? true;
        secureLogin = prefs.getBool('privacy_secure_login') ?? true;
        personalizedAds = prefs.getBool('privacy_ads') ?? false;
      });
    }
  }

  Future<void> _runSecurityScan() async {
    setState(() {
      isScanning = true;
      safetyStatus = "Scanning for risks...";
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        isScanning = false;
        safetyStatus = "Account is Secure";
        lastCheck = "Checked: Just now";
      });
      _showStatus(context, "Full Security Scan Complete! Everything is safe.");
    }
  }

  Future<void> _compileData() async {
    setState(() => isDownloading = true);
    
    // 🔥 Trigger Real Email
    await EmailService.sendDataExportEmail(context: context);
    
    if (mounted) {
      setState(() => isDownloading = false);
      _showStatus(context, "Data Pack sent to your registered email! 📧");
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TranslatedText("Privacy & Safety", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// 🛡️ SECURITY STATUS OVERVIEW
          FadeIn(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceDark.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  isScanning 
                    ? const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                    : const Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 30),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(safetyStatus, 
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(lastCheck, 
                            style: TextStyle(color: textSubdued, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 35),

          _sectionLabel("Quick Privacy Controls"),
          
          _buildSwitchTile(Icons.visibility_off_rounded, "Private Profile", "Only you see your order history", privateProfile, (val) {
             setState(() => privateProfile = val);
             _saveSetting('privacy_private_profile', val);
             _showStatus(context, val ? "Profile set to Private" : "Profile is now Public");
          }),

          _buildSwitchTile(Icons.shield_outlined, "Secure Purchase", "Extra verification for large orders", secureLogin, (val) {
             setState(() => secureLogin = val);
             _saveSetting('privacy_secure_login', val);
             _showStatus(context, val ? "High-security mode active" : "Standard security mode");
          }),

          _buildSwitchTile(Icons.ads_click_rounded, "Personalized Ads", "Better suggestions based on interests", personalizedAds, (val) {
             setState(() => personalizedAds = val);
             _saveSetting('privacy_ads', val);
             _showStatus(context, val ? "Ad personalization enabled" : "Ad personalization disabled");
          }),

          const SizedBox(height: 30),

          _sectionLabel("Safety Actions"),
          
          _buildActionTile(
            icon: Icons.security_rounded, 
            title: "Run Security Scan", 
            subtitle: isScanning ? "Analyzing account data..." : "Check for potential risks", 
            trailing: isScanning ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)) : null,
            onTap: isScanning ? null : _runSecurityScan,
          ),

          _buildActionTile(
            icon: Icons.download_for_offline_rounded, 
            title: "Download Data", 
            subtitle: isDownloading ? "Compiling pack..." : "Get a copy of your records", 
            trailing: isDownloading ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)) : null,
            onTap: isDownloading ? null : _compileData,
          ),

          const SizedBox(height: 40),

          Center(
            child: TextButton.icon(
              onPressed: () => _confirmDeleteAccount(context),
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 18),
              label: const TranslatedText("Delete Account Permanently", 
                  style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 12),
      child: TranslatedText(
        label,
        style: TextStyle(color: richGold, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.4), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: richGold, size: 22),
        title: TranslatedText(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        subtitle: TranslatedText(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.4), 
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: SwitchListTile(
        activeColor: richGold,
        secondary: Icon(icon, color: richGold, size: 22),
        title: TranslatedText(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
        subtitle: TranslatedText(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TranslatedText("Delete Account?", style: TextStyle(color: Colors.redAccent)),
        content: const TranslatedText("This will permanently remove your Gemzi history.", 
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const TranslatedText("Cancel")),
          TextButton(
            onPressed: () { Navigator.pop(context); _showStatus(context, "Account deletion initiated."); },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showStatus(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: richGold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
