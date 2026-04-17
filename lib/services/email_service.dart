import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    // Determine the user's email; use a fallback for testing if not signed in
    final user = FirebaseAuth.instance.currentUser;
    final String targetEmail = user?.email ?? 'test@example.com';
    final String targetName = user?.displayName ?? 'Valued Customer';

    // If _username hasn't been set by you yet, bypass to avoid crashing
    if (_username == 'YOUR_EMAIL@gmail.com') {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('EMAIL NOT SENT: Missing Credentials in EmailService')));
      }
      debugPrint('EMAIL NOT SENT: Please configure your Gmail and App Password in EmailService first.');
      return;
    }

    final smtpServer = gmail(_username, _password);

    // Build the items table rows
    String itemsHtml = '';
    for (var item in items) {
      String name = item['name'] ?? 'Item';
      int qty = item['quantity'] ?? 1;
      double price = (item['price'] is String) 
          ? double.tryParse(item['price']) ?? 0.0 
          : (item['price'] as num).toDouble();
      
      itemsHtml += '''
        <tr>
          <td style="padding: 12px; border-bottom: 1px solid #eee;">
            <div style="width: 40px; height: 40px; background-color: #0F2F2B; color: #D4AF37; text-align: center; line-height: 40px; border-radius: 4px; font-weight: bold; font-family: monospace; font-size: 18px;">
              ${name.isNotEmpty ? name[0].toUpperCase() : 'G'}
            </div>
          </td>
          <td style="padding: 12px; border-bottom: 1px solid #eee;">
            <span style="font-weight: bold; color: #0F2F2B;">$name</span><br>
            <span style="font-size: 12px; color: #666;">Gemzi Premium Collection</span>
          </td>
          <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: center; color: #555;">x$qty</td>
          <td style="padding: 12px; border-bottom: 1px solid #eee; text-align: right; font-weight: bold; color: #0F2F2B;">
            ₹${price.toStringAsFixed(2)}
          </td>
        </tr>
      ''';
    }

    final message = Message()
      ..from = Address(_username, 'Gemzi Store')
      ..recipients.add(targetEmail)
      ..subject = 'Payment Confirmed: Order #$paymentId'
      ..html = '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background-color: #ffffff; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 10px rgba(0,0,0,0.05);">
          <!-- Header -->
          <div style="background-color: #0F2F2B; padding: 30px; text-align: center;">
            <h1 style="color: #D4AF37; margin: 0; font-size: 28px; letter-spacing: 1px;">Gemzi</h1>
            <p style="color: #D4AF37; margin: 8px 0 0 0; font-size: 14px; opacity: 0.9;">Premium Digital Gold & Jewellery</p>
          </div>
          
          <!-- Body -->
          <div style="padding: 30px;">
            <h2 style="color: #0F2F2B; text-align: center; font-size: 24px; margin-top: 0;">🎉 Order Successful! 🎉</h2>
            <p style="color: #333; font-size: 16px;">Hi <strong>$targetName</strong>,</p>
            <p style="color: #555; font-size: 15px; line-height: 1.6;">Your payment was securely processed and your order #<strong>$paymentId</strong> is officially confirmed. Enjoy your premium selection!</p>
            
            <!-- Status Box -->
            <div style="background-color: rgba(212, 175, 55, 0.1); border-left: 4px solid #D4AF37; padding: 15px; margin: 25px 0; border-radius: 4px;">
              <p style="margin: 0; color: #0F2F2B; font-size: 15px;">
                <strong>Order ID:</strong> #$paymentId <span style="margin: 0 10px; color: #ccc;">|</span>
                <strong>Status:</strong> <span style="color: #2e7d32; font-weight: bold;">Payment Verified</span>
              </p>
            </div>
            
            <!-- Items Table -->
            <h3 style="color: #0F2F2B; font-size: 16px; border-bottom: 2px solid #f0f0f0; padding-bottom: 10px; margin-top: 30px;">🛍️ Items Ordered</h3>
            <table style="width: 100%; border-collapse: collapse; margin-bottom: 25px;">
              <thead>
                <tr style="background-color: #fcfcfc;">
                  <th style="padding: 12px 10px; text-align: left; color: #888; font-size: 11px; letter-spacing: 1px; text-transform: uppercase;">Photo</th>
                  <th style="padding: 12px 10px; text-align: left; color: #888; font-size: 11px; letter-spacing: 1px; text-transform: uppercase;">Product</th>
                  <th style="padding: 12px 10px; text-align: center; color: #888; font-size: 11px; letter-spacing: 1px; text-transform: uppercase;">Qty</th>
                  <th style="padding: 12px 10px; text-align: right; color: #888; font-size: 11px; letter-spacing: 1px; text-transform: uppercase;">Price</th>
                </tr>
              </thead>
              <tbody>
                $itemsHtml
                <tr style="background-color: rgba(15, 47, 43, 0.03);">
                  <td colspan="3" style="padding: 20px 15px; text-align: right; font-weight: bold; color: #0F2F2B; font-size: 15px;">Order Total</td>
                  <td style="padding: 20px 15px; text-align: right; font-weight: bold; color: #0F2F2B; font-size: 18px;">₹${totalAmount.toStringAsFixed(2)}</td>
                </tr>
              </tbody>
            </table>
            
            <p style="color: #555; font-size: 14px; text-align: center; margin-top: 30px;">✨ Thank you for choosing Gemzi. We hope you love your premium quality jewellery! ✨</p>
            <p style="color: #aaa; font-size: 11px; text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #eee;">This is an automated notification from Gemzi. Please do not reply to this email.</p>
          </div>
        </div>
      ''';

    try {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending confirmation email...')));
      }
      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent successfully to target');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sent successfully! 📧'), backgroundColor: Colors.green));
      }
    } on MailerException catch (e) {
      debugPrint('Message not sent. \${e.message}');
      for (var p in e.problems) {
        debugPrint('Problem: \${p.code}: \${p.msg}');
      }
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email error: \${e.message}'), backgroundColor: Colors.red));
      }
    } catch (e) {
       if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e'), backgroundColor: Colors.red));
      }
    }
  }
}
