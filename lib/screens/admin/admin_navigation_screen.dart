import 'package:flutter/material.dart';
import '../../themes/admin_theme.dart';
import 'jewellery_management_screen.dart';
import 'dashboard_screen.dart'; // We'll create this next

class AdminNavigationScreen extends StatefulWidget {
  const AdminNavigationScreen({super.key});

  @override
  State<AdminNavigationScreen> createState() => _AdminNavigationScreenState();
}

class _AdminNavigationScreenState extends State<AdminNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const JewelleryManagementScreen(),
    // We can add order_management_screen, etc here later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AdminTheme.surfaceGreen,
        selectedItemColor: AdminTheme.emerald,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.diamond), label: "Jewellery"),
        ],
      ),
    );
  }
}
