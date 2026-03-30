import 'package:flutter/material.dart';

class GoldRateScreen extends StatelessWidget {
  const GoldRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gold Rate")),
      body: const Center(child: Text("Update Gold Rate Here")),
    );
  }
}
