import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class EmailService {
  // 👉 IMPORTANT: Replace these with your actual Gmail account and 16-character App Password (NOT your normal password)
  static const String _username = 'shreyashinde883@gmail.com'; 
  static const String _password = 'zujcaguefgupegoo';

  static Future<void> sendPurchaseEmail({
    required String paymentId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    BuildContext? context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final String targetEmail = user?.email ?? 'test@example.com';
    final String targetName = user?.displayName ?? 'Valued Customer';

    if (_username == 'YOUR_EMAIL@gmail.com') return;

    final smtpServer = gmail(_username, _password);
    String itemsHtml = '';
    for (var item in items) {
      String name = item['name'] ?? 'Item';
      int qty = item['quantity'] ?? 1;
      double price = (item['price'] is String) ? double.tryParse(item['price']) ?? 0.0 : (item['price'] as num).toDouble();
      itemsHtml += '<tr><td>$name</td><td>x$qty</td><td>₹${price.toStringAsFixed(2)}</td></tr>';
    }

    final message = Message()
      ..from = Address(_username, 'Gemzi Store')
      ..recipients.add(targetEmail)
      ..subject = 'Payment Confirmed: Order #$paymentId'
      ..html = '<h1>Order Confirmed</h1><p>Hi $targetName, your order #$paymentId is confirmed.</p><table>$itemsHtml</table>';

    try {
      await send(message, smtpServer);
    } catch (e) {
      debugPrint('Email error: $e');
    }
  }

  static Future<void> sendDataExportEmail({BuildContext? context}) async {
    final user = FirebaseAuth.instance.currentUser;
    final String targetEmail = user?.email ?? 'test@example.com';
    final String targetName = user?.displayName ?? 'Valued Customer';

    if (_username == 'YOUR_EMAIL@gmail.com') {
      debugPrint('❌ ERROR: SMTP Username not configured');
      return;
    }

    try {
      debugPrint('🚀 [DIAGNOSTIC] Starting Data Export for: $targetEmail');

      // 📄 1. GENERATE PDF
      debugPrint('📄 [DIAGNOSTIC] Generating PDF document...');
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Gemzi Boutique: Account Report'),
              pw.SizedBox(height: 20),
              pw.Text('Report Generated: ${DateTime.now().toString()}'),
              pw.SizedBox(height: 10),
              pw.Bullet(text: 'Customer Name: $targetName'),
              pw.Bullet(text: 'Registered Email: $targetEmail'),
              pw.SizedBox(height: 40),
              pw.Text('This report confirms your profile status at Gemzi Boutique.'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Align(alignment: pw.Alignment.center, child: pw.Text('✨ Thank you for choosing Gemzi ✨')),
            ],
          ),
        ),
      );

      // 📁 2. SAVE PDF LOCALLY
      debugPrint('📁 [DIAGNOSTIC] Locating directory...');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/Gemzi_Report.pdf');
      
      debugPrint('💾 [DIAGNOSTIC] Preserving to path: ${file.path}');
      await file.writeAsBytes(await pdf.save());
      debugPrint('✅ [DIAGNOSTIC] PDF Save Complete.');

      // 📧 3. CREATE EMAIL MESSAGE
      debugPrint('📧 [DIAGNOSTIC] Creating Message object...');
      final smtpServer = gmail(_username, _password);
      final message = Message()
        ..from = Address(_username, 'Gemzi Support')
        ..recipients.add(targetEmail)
        ..subject = 'Gemzi: Your Data Report is Ready'
        ..attachments.add(FileAttachment(file))
        ..html = '<h3>Hi $targetName</h3><p>Your Gemzi Boutique data report is attached as a PDF correctly.</p>';

      debugPrint('📨 [DIAGNOSTIC] Attempting SMTP handshake...');
      final report = await send(message, smtpServer);
      debugPrint('🎊 [DIAGNOSTIC] SUCCESS: Message sent $report');

      if (context != null && context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email Sent Successfully! 📧'), backgroundColor: Colors.green));
      }

    } catch (e) {
      debugPrint('❌ [DIAGNOSTIC] FATAL ERROR IN EMAIL FLOW: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
