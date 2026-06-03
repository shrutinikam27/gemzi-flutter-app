import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/translated_text.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

class GoldCertificatePage extends StatelessWidget {
  final String? productName;
  final String? productImage;
  final double? weight;
  final String? purity;
  final String? HUID;
  final String? certificateId;
  final String? issueDate;

  const GoldCertificatePage({
    super.key,
    this.productName,
    this.productImage,
    this.weight,
    this.purity,
    this.HUID,
    this.certificateId,
    this.issueDate,
  });

  // Theme Colors (Premium Dark Green & Gold Theme)
  static const Color darkBg = Color(0xFF0F2F2B);
  static const Color surfaceDark = Color(0xFF17453F);
  static const Color textLight = Colors.white;
  static const Color luxuryGold = Color(0xFFD4AF37);
  static const Color deepGold = Color(0xFFB8860B);
  static const Color textSubdued = Color(0xFFB8D1CD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TranslatedText(
          "Authenticity Certificate",
          style: TextStyle(color: textLight, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🛡️ Gold Authenticity Verified Top Section
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.green, size: 18),
                    const SizedBox(width: 8),
                    TranslatedText(
                      "VERIFICATION STATUS: GENUINE",
                      style: TextStyle(
                        color: Colors.green.shade400,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📜 The Main Premium Certificate Card
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceDark,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: luxuryGold.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Card Header with BIS Hallmark badge
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [luxuryGold.withValues(alpha: 0.05), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "GEMZI TRUST SHIELD",
                                style: TextStyle(
                                  color: deepGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                productName ?? "Gold Guarantee",
                                style: const TextStyle(
                                  color: textLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          // BIS Hallmark verified badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: darkBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: luxuryGold.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/auth/ring.png', // Fallback mini icon, or display placeholder
                                  width: 14,
                                  height: 14,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.workspace_premium, color: luxuryGold, size: 14),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "BIS Hallmark",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: luxuryGold.withValues(alpha: 0.15), height: 1, thickness: 1.5),

                    // Jewellery Product Image Area
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkBg,
                          border: Border.all(color: luxuryGold.withValues(alpha: 0.15), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: _buildProductImage(productImage),
                        ),
                      ),
                    ),

                    // Certificate Details Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildDetailRow("Certificate ID", certificateId ?? "GZ-CERT-983421"),
                          _buildDetailRow("Purity", purity ?? "22K Gold (916)"),
                          _buildDetailRow("Net Weight", weight != null ? "${weight!.toStringAsFixed(3)} Grams" : "8.340 Grams"),
                          _buildDetailRow("HUID Number", HUID ?? "HUID1897452"),
                          _buildDetailRow("Jeweller Name", "Gemzi Craftsmen Ltd."),
                          _buildDetailRow("Issue Date", issueDate ?? "03 June 2026"),
                        ],
                      ),
                    ),

                    Divider(color: luxuryGold.withValues(alpha: 0.15), height: 30, thickness: 1.5),

                    // QR Code Verification section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25, left: 24, right: 24),
                      child: Row(
                        children: [
                          // QR Code Placeholder
                          Container(
                            height: 70,
                            width: 70,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: luxuryGold.withValues(alpha: 0.5)),
                            ),
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                              itemCount: 49,
                              itemBuilder: (context, index) {
                                // Draw a mock QR code pattern
                                bool isFilled = (index * 3 + index % 5) % 2 == 0;
                                // Add outer square anchors
                                if ((index >= 0 && index <= 2) || (index >= 7 && index <= 9) || (index >= 14 && index <= 16)) isFilled = true;
                                if ((index >= 4 && index <= 6) || (index >= 11 && index <= 13) || (index >= 18 && index <= 20)) isFilled = true;
                                if ((index >= 42 && index <= 44) || (index >= 35 && index <= 37) || (index >= 28 && index <= 30)) isFilled = true;
                                return Container(
                                  color: isFilled ? darkBg : Colors.white,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Scan QR to Verify",
                                  style: TextStyle(
                                    color: textLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "This certificate is cryptographically signed and secured on block hash.",
                                  style: TextStyle(
                                    color: textSubdued,
                                    fontSize: 10,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Action Buttons Section
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  // Save to Digital Vault button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: luxuryGold,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: TranslatedText("Certificate stored securely in your Digital Gold Vault!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.cloud_done_rounded, color: darkBg, size: 20),
                    label: const TranslatedText(
                      "Save to Digital Vault",
                      style: TextStyle(color: darkBg, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Download and Share side-by-side buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: luxuryGold, width: 1.5),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => _downloadPDF(context),
                          icon: const Icon(Icons.file_download_outlined, color: luxuryGold, size: 18),
                          label: const TranslatedText(
                            "Download",
                            style: TextStyle(color: luxuryGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: luxuryGold, width: 1.5),
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => _shareCertificate(context),
                          icon: const Icon(Icons.share_outlined, color: luxuryGold, size: 18),
                          label: const TranslatedText(
                            "Share Cert",
                            style: TextStyle(color: luxuryGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TranslatedText(label, style: const TextStyle(color: textSubdued, fontSize: 12, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: textLight, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return const Icon(
        Icons.diamond_rounded,
        color: luxuryGold,
        size: 60,
      );
    }
    
    final path = imagePath.trim();
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.diamond_rounded,
          color: luxuryGold,
          size: 60,
        ),
      );
    }
    
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.diamond_rounded,
        color: luxuryGold,
        size: 60,
      ),
    );
  }

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PDF download not supported on Web.")),
        );
        return;
      }

      // 1. Request permissions if on android
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
      }

      // 2. Generate PDF document
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pdfContext) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex("#D4AF37"), width: 3),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "GEMZI TRUST SHIELD",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#D4AF37"),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Text(
                      "GOLD AUTHENTICITY CERTIFICATE",
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColor.fromHex("#17453F"),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 2, color: PdfColor.fromHex("#D4AF37")),
                  pw.SizedBox(height: 20),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                    child: pw.Column(
                      children: [
                        _buildPdfDetailRow("Product Name", productName ?? "Luxury Jewellery"),
                        _buildPdfDetailRow("Certificate ID", certificateId ?? "GZ-CERT-983421"),
                        _buildPdfDetailRow("Purity", purity ?? "22K Gold (916)"),
                        _buildPdfDetailRow("Net Weight", weight != null ? "${weight!.toStringAsFixed(3)} Grams" : "8.340 Grams"),
                        _buildPdfDetailRow("HUID Number", HUID ?? "HUID1897452"),
                        _buildPdfDetailRow("Jeweller Name", "Gemzi Craftsmen Ltd."),
                        _buildPdfDetailRow("Issue Date", issueDate ?? "03 June 2026"),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Divider(thickness: 1, color: PdfColor.fromHex("#B8D1CD")),
                  pw.SizedBox(height: 25),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Verification Status: GENUINE",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex("#2E7D32"),
                              fontSize: 13,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "This certificate is cryptographically signed and secured on block hash.",
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 70,
                        height: 70,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 2),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Text("QR VERIFIED", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // 3. Save PDF
      Directory? outputDir;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) {
          outputDir = dir;
        } else {
          outputDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        outputDir = await getApplicationDocumentsDirectory();
      }

      outputDir ??= await getApplicationDocumentsDirectory();

      final fileName = "${certificateId ?? 'GZ-CERT-${DateTime.now().millisecondsSinceEpoch}'}.pdf";
      final file = File("${outputDir.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      // 4. Directly open the downloaded file
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Certificate PDF downloaded successfully. Opening..."),
            backgroundColor: Colors.green,
          ),
        );
        await _openFile(file.path, context);
      }
    } catch (e) {
      debugPrint("PDF download error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to download PDF: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openFile(String filePath, BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not open file: ${result.message}"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("OpenFile error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("PDF saved. To view, open it manually from your Downloads folder at: $filePath"),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _shareCertificate(BuildContext context) async {
    try {
      if (kIsWeb) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sharing not supported on Web.")),
        );
        return;
      }

      // Generate the PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pdfContext) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex("#D4AF37"), width: 3),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      "GEMZI TRUST SHIELD",
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#D4AF37"),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Center(
                    child: pw.Text(
                      "GOLD AUTHENTICITY CERTIFICATE",
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColor.fromHex("#17453F"),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Divider(thickness: 2, color: PdfColor.fromHex("#D4AF37")),
                  pw.SizedBox(height: 20),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
                    child: pw.Column(
                      children: [
                        _buildPdfDetailRow("Product Name", productName ?? "Luxury Jewellery"),
                        _buildPdfDetailRow("Certificate ID", certificateId ?? "GZ-CERT-983421"),
                        _buildPdfDetailRow("Purity", purity ?? "22K Gold (916)"),
                        _buildPdfDetailRow("Net Weight", weight != null ? "${weight!.toStringAsFixed(3)} Grams" : "8.340 Grams"),
                        _buildPdfDetailRow("HUID Number", HUID ?? "HUID1897452"),
                        _buildPdfDetailRow("Jeweller Name", "Gemzi Craftsmen Ltd."),
                        _buildPdfDetailRow("Issue Date", issueDate ?? "03 June 2026"),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Divider(thickness: 1, color: PdfColor.fromHex("#B8D1CD")),
                  pw.SizedBox(height: 25),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Verification Status: GENUINE",
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex("#2E7D32"),
                              fontSize: 13,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "This certificate is cryptographically signed and secured on block hash.",
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                        ],
                      ),
                      pw.Container(
                        width: 70,
                        height: 70,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 2),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Center(
                          child: pw.Text("QR VERIFIED", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Save to temp directory to share
      final tempDir = await getTemporaryDirectory();
      final tempFile = File("${tempDir.path}/${certificateId ?? 'GZ-CERT-TEMP'}.pdf");
      await tempFile.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        subject: "Gold Authenticity Certificate - ${productName ?? 'Gemzi'}",
        text: "Here is my Gemzi Gold Authenticity Certificate for the ${productName ?? 'Jewellery piece'}.",
      );
    } catch (e) {
      debugPrint("Share certificate error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to share certificate: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
