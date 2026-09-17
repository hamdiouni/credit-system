import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';

/// Desktop/Mobile implementation for HTML-based PDF
/// Uses the printing package to generate beautiful PDFs with proper Arabic support
Future<void> openHtmlInNewTab(String htmlContent) async {
  // For desktop/mobile, we'll save the HTML and open it in the default browser
  // This provides the best Arabic rendering since browsers handle it perfectly
  
  try {
    print('📄 [HTML PDF IO] Generating HTML file for desktop/mobile...');
    
    // Get temporary directory
    final tempDir = await getTemporaryDirectory();
    final htmlFile = File('${tempDir.path}/customer_report_${DateTime.now().millisecondsSinceEpoch}.html');
    
    // Write HTML content to file
    await htmlFile.writeAsString(htmlContent);
    
    print('✅ [HTML PDF IO] HTML file created: ${htmlFile.path}');
    print('📋 [HTML PDF IO] Opening in default browser...');
    
    // Open the HTML file in the default browser
    await OpenFile.open(htmlFile.path);
    
    print('✅ [HTML PDF IO] HTML file opened successfully');
    print('💡 [HTML PDF IO] Use browser Print (Ctrl+P) to save as PDF with perfect Arabic rendering');
    
  } catch (e) {
    print('❌ [HTML PDF IO] Error: $e');
    rethrow;
  }
}
