import 'package:flutter/material.dart';
import 'users.dart';
import 'schemes.dart';
import 'payments.dart';
import 'gold_rate.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),

      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [

          dashboardCard(context, "Users", Icons.people, UsersScreen()),
          dashboardCard(context, "Schemes", Icons.account_balance, SchemesScreen()),
          dashboardCard(context, "Payments", Icons.payment, PaymentsScreen()),
          dashboardCard(context, "Gold Rate", Icons.monetization_on, GoldRateScreen()),

        ],
      ),
    );
  }

  Widget dashboardCard(BuildContext context, String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
