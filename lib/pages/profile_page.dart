// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../widgets/translated_text.dart';
import 'my_orders_page.dart';
import 'my_investments_page.dart';
import 'payment_methods_page.dart';
import 'wishlist_page.dart';
import 'settings_page.dart';
import 'privacy_security_page.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color richGold = Color(0xFFD4AF37);
  static const Color deepGold = Color(0xFFB8860B);
  static const Color textLight = Colors.white;
  static const Color textSubdued = Color(0xFFB8D1CD);

  String userName = 'Loading...';
  String userEmail = '';
  String userPhone = '';
  double walletBalance = 0.0;
  String? profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          userName = data['name'] ?? 'User';
          userEmail = user.email ?? '';
          userPhone = data['phone'] ?? '';
          walletBalance = (data['walletBalance'] ?? 0.0).toDouble();
          profileImage = data['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          userName = 'User';
          userEmail = user.email ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: darkBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: richGold),
            )
          : user == null
              ? _buildGuestView(context)
              : _buildProfileView(context, user),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: richGold.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(Icons.person_outline, color: richGold, size: 64),
            ),
            const SizedBox(height: 24),
            const TranslatedText(
              'You\'re not logged in',
              style: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const TranslatedText(
              'Sign in to view your profile, orders & wishlist',
              textAlign: TextAlign.center,
              style: TextStyle(color: textSubdued, fontSize: 14),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [richGold, deepGold]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: richGold.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: const TranslatedText(
                  'Login / Sign Up',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, User user) {
    return CustomScrollView(
      slivers: [
        // ── Hero Header ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          backgroundColor: darkBg,
          iconTheme: const IconThemeData(color: textLight),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF17453F), Color(0xFF0F2F2B), Color(0xFF0A1F1D)],
                    ),
                  ),
                ),
                // Gold shimmer overlay
                Positioned(
                  top: -40,
                  right: -40,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: richGold.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                // Profile content
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      // Avatar
                      FadeInDown(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _showPhotoPickerOptions,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [richGold, deepGold]),
                                  shape: BoxShape.circle,
                                ),
                                child: _buildAvatarWidget(profileImage, userName, radius: 40, fontSize: 32),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _showPhotoPickerOptions,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: richGold, shape: BoxShape.circle),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        child: Text(userName,
                            style: const TextStyle(
                                color: textLight,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Text(userEmail,
                            style: const TextStyle(color: textSubdued, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: textLight),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            child: Column(
              children: [
                // ── Stats Row ──────────────────────────────────────────
                FadeInUp(
                  child: Row(
                    children: [
                      _statCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Wallet',
                        value: '₹${walletBalance.toStringAsFixed(0)}',
                      ),
                      const SizedBox(width: 12),
                      Consumer<WishlistService>(
                        builder: (context, wishlist, _) => _statCard(
                          icon: Icons.favorite_border,
                          label: 'Wishlist',
                          value: '${wishlist.itemCount} items',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<CartService>(
                        builder: (context, cart, _) => _statCard(
                          icon: Icons.shopping_cart_outlined,
                          label: 'Cart',
                          value: '${cart.itemCount} items',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Quick Actions ────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _sectionHeader('My Activity'),
                ),
                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _menuTile(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    subtitle: 'Track & view your purchases',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyOrdersPage())),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _menuTile(
                    icon: Icons.favorite_border,
                    title: 'My Wishlist',
                    subtitle: 'Items you\'ve saved for later',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WishlistPage())),
                    trailing: Consumer<WishlistService>(
                      builder: (_, wishlist, __) => wishlist.itemCount > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: richGold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('${wishlist.itemCount}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: _menuTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Saving Schemes',
                    subtitle: 'Track your SIPs & gold investments',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyInvestmentsPage())),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _menuTile(
                    icon: Icons.wallet_membership_rounded,
                    title: 'Payment Methods',
                    subtitle: 'Manage cards & UPI',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PaymentMethodsPage())),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Account Section ──────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: _sectionHeader('Account'),
                ),
                const SizedBox(height: 12),

                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _menuTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your name & details',
                    onTap: _editProfile,
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: _menuTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Privacy & Security',
                    subtitle: 'PIN lock, data & security scan',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrivacySecurityPage())),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _menuTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Notifications, language & more',
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SettingsPage())),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Logout ───────────────────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: GestureDetector(
                    onTap: () => _confirmLogout(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          SizedBox(width: 10),
                          TranslatedText(
                            'Logout',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Gemzi Boutique v1.2.0',
                  style: TextStyle(
                      color: textSubdued.withValues(alpha: 0.4), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
      {required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: richGold.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: richGold, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    color: textLight, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(color: textSubdued, fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            color: richGold,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: richGold.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: richGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: richGold, size: 20),
        ),
        title: TranslatedText(title,
            style: const TextStyle(
                color: textLight, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: TranslatedText(subtitle,
            style: const TextStyle(color: textSubdued, fontSize: 11)),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: richGold, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _editProfile() {
    final nameController = TextEditingController(text: userName);
    final phoneController = TextEditingController(text: userPhone);
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final pincodeController = TextEditingController();
    final bioController = TextEditingController();

    // Pre-load existing data
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          cityController.text = data['city'] ?? '';
          stateController.text = data['state'] ?? '';
          pincodeController.text = data['pincode'] ?? '';
          bioController.text = data['bio'] ?? '';
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.97,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Edit Profile',
                style: TextStyle(
                  color: richGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Update your personal information',
                style: TextStyle(color: textSubdued, fontSize: 12),
              ),
              const Divider(color: Colors.white12, height: 24),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // ── Profile Picture ────────────────────────────
                    _editSection('Profile Picture', Icons.photo_outlined),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showPhotoPickerOptions();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: darkBg.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(colors: [richGold, deepGold]),
                                shape: BoxShape.circle,
                              ),
                              child: _buildAvatarWidget(profileImage, userName, radius: 22, fontSize: 16),
                            ),
                            const SizedBox(width: 16),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Change Photo',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Upload custom photo or pick avatar',
                                  style: TextStyle(color: textSubdued, fontSize: 10),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, color: richGold),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Personal Info ──────────────────────────────
                    _editSection('Personal Information', Icons.person_outline),
                    const SizedBox(height: 12),
                    _editField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.badge_outlined,
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: 12),
                    _editField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      hint: '+91 XXXXXXXXXX',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _editField(
                      controller: bioController,
                      label: 'Bio',
                      icon: Icons.info_outline,
                      hint: 'Tell us a little about yourself…',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 24),

                    // ── Account Info ───────────────────────────────
                    _editSection('Account', Icons.account_circle_outlined),
                    const SizedBox(height: 12),
                    // Email — read only
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: darkBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, color: textSubdued, size: 18),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email Address',
                                  style: TextStyle(color: textSubdued, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                userEmail.isEmpty ? 'Not set' : userEmail,
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: richGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Verified',
                                style: TextStyle(color: richGold, fontSize: 10)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Address ────────────────────────────────────
                    _editSection('Address', Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    _editField(
                      controller: cityController,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      hint: 'e.g. Mumbai',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _editField(
                            controller: stateController,
                            label: 'State',
                            icon: Icons.map_outlined,
                            hint: 'e.g. Maharashtra',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _editField(
                            controller: pincodeController,
                            label: 'Pincode',
                            icon: Icons.pin_drop_outlined,
                            hint: '400001',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // ── Save Button ────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        final newName = nameController.text.trim();
                        final u = FirebaseAuth.instance.currentUser;
                        if (u != null && newName.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(u.uid)
                              .set({
                            'name': newName,
                            'phone': phoneController.text.trim(),
                            'bio': bioController.text.trim(),
                            'city': cityController.text.trim(),
                            'state': stateController.text.trim(),
                            'pincode': pincodeController.text.trim(),
                          }, SetOptions(merge: true));
                          if (mounted) {
                            setState(() {
                              userName = newName;
                              userPhone = phoneController.text.trim();
                            });
                          }
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: TranslatedText('Profile updated successfully!'),
                            backgroundColor: Color(0xFF17453F),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [richGold, deepGold]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: richGold.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Changes',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editSection(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: richGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: richGold, size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: richGold,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _editField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: textLight, fontSize: 14),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: const TextStyle(color: textSubdued, fontSize: 12),
        prefixIcon: Icon(icon, color: richGold, size: 18),
        filled: true,
        fillColor: darkBg.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: richGold, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }



  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const TranslatedText('Logout',
            style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
        content: const TranslatedText('Are you sure you want to sign out?',
            style: TextStyle(color: textSubdued)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const TranslatedText('Cancel',
                  style: TextStyle(color: textSubdued))),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showPhotoPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const TranslatedText(
                'Change Profile Photo',
                style: TextStyle(
                  color: richGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: richGold),
                title: const TranslatedText('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: richGold),
                title: const TranslatedText('Take Photo from Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              if (profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const TranslatedText('Remove Current Photo', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() => _isLoading = true);
        
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final localFile = File('${appDir.path}/$fileName');
        
        await File(pickedFile.path).copy(localFile.path);
        
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'profileImage': localFile.path}, SetOptions(merge: true));
            
        setState(() {
          profileImage = localFile.path;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: TranslatedText('Profile photo updated successfully!'),
            backgroundColor: surfaceDark,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatedText('Error updating photo: \$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }



  Future<void> _removeProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImage': FieldValue.delete()});

      setState(() {
        profileImage = null;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TranslatedText('Profile photo removed'),
          backgroundColor: surfaceDark,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TranslatedText('Error: \$e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildAvatarWidget(String? imagePath, String name, {double radius = 40, double fontSize = 32}) {
    final double size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imagePath != null && imagePath.isNotEmpty
            ? _buildImage(imagePath, name, fontSize)
            : _buildInitials(name, fontSize),
      ),
    );
  }

  Widget _buildImage(String path, String name, double fontSize) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(color: richGold, strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => _buildInitials(name, fontSize),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(name, fontSize),
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(name, fontSize),
      );
    }
  }

  Widget _buildInitials(String name, double fontSize) {
    return Container(
      color: darkBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: TextStyle(
              color: richGold,
              fontSize: fontSize,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

