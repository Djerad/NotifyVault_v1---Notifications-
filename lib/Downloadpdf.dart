import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PDFDownloadScreen extends StatefulWidget {
  const PDFDownloadScreen({Key? key}) : super(key: key);

  @override
  State<PDFDownloadScreen> createState() => _PDFDownloadScreenState();
}

class _PDFDownloadScreenState extends State<PDFDownloadScreen> {
  bool isLoading = false;
  String? downloadPath;
  final TextEditingController textController = TextEditingController(
    text: 'opsoesgjsdogjsgdodsjgpgponssopdsop',
  );

  Future<void> downloadPDF() async {
    setState(() => isLoading = true);

    try {
      print('🔍 Starting PDF download...');

      // Request storage permission
      print('📱 Requesting storage permission...');
      PermissionStatus status = await Permission.storage.request();
      
      print('📱 Permission status: $status');

      if (status.isDenied) {
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Storage permission denied'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() => isLoading = false);
        if (!mounted) return;
        openAppSettings();
        return;
      }

      print('✅ Permission granted');

      final text = textController.text;

      // Create PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Downloaded Text',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    text,
                    style: const pw.TextStyle(fontSize: 16),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Get Downloads directory using path_provider
      print('📁 Getting Downloads directory...');
      Directory? dir;
      
      // Try to get external storage directory (downloads)
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          // Fallback to documents directory
          dir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      }

      if (dir == null) {
        throw Exception('Could not get Downloads directory');
      }

      print('📁 Downloads directory: ${dir.path}');

      String fileName = 'downloaded_text.pdf';
      String filePath = '${dir.path}/$fileName';

      print('💾 Saving to: $filePath');

      // Save PDF
      final file = File(filePath);
      final bytes = await pdf.save();
      
      print('💾 PDF bytes generated: ${bytes.length} bytes');
      
      await file.writeAsBytes(bytes);
      
      print('💾 File written successfully');

      // Verify file was created
      await Future.delayed(const Duration(milliseconds: 500));

      bool fileExists = await file.exists();
      print('📄 File exists: $fileExists');

      if (fileExists) {
        final fileSize = await file.length();
        print('📄 File size: $fileSize bytes');
      }

      setState(() {
        downloadPath = filePath;
        isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PDF saved successfully!\n$filePath'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Download completed successfully');
    } catch (e) {
      print('❌ Exception: $e');
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Download'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter text to download as PDF:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Enter your text here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : downloadPDF,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(isLoading ? 'Downloading...' : 'Download as PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              if (downloadPath != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Download Successful!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'File saved:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        downloadPath!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        '📱 How to find your file:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Open Files app on your phone\n2. Navigate to the Download folder\n3. Find downloaded_text.pdf',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}