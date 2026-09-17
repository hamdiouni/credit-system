import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../utils/date_formatter.dart';
import 'unified_pdf_service.dart';
import 'arabic_pdf_service.dart';

/// PDF Service Selector - intelligently selects the best PDF generation method
/// - For Arabic: Uses HTML-based PDF for PERFECT letter joining and RTL
/// - For other languages: Uses standard PDF with embedded fonts
/// Works on ALL platforms: Android, iOS, Windows, macOS, Linux, Web
class PdfServiceSelector {
  
  /// Generate customer report using the best method for the language
  /// Platform-independent with proper Arabic support
  static Future<void> generateCustomerReport({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
  }) async {
    
    print('📄 [PdfServiceSelector] Generating PDF report...');
    print('🌍 [PdfServiceSelector] Language: $language');
    
    // For Arabic, use HTML-based PDF for perfect rendering
    if (language == 'ar') {
      print('🔤 [PdfServiceSelector] Using HTML-based PDF for Arabic (perfect letter joining)');
      try {
        await ArabicPdfService.generateArabicCustomerReport(
          customer: customer,
          transactions: transactions,
          appTitle: appTitle,
          language: language,
        );
        return;
      } catch (e) {
        print('⚠️ [PdfServiceSelector] HTML-based PDF failed, falling back to standard PDF: $e');
        // Fall through to standard PDF
      }
    }
    
    // For other languages or if HTML-based PDF fails, use standard PDF
    print('📄 [PdfServiceSelector] Using standard PDF service');
    
    // Generate PDF bytes using unified service
    final pdfBytes = await UnifiedPdfService.generateCustomerReportBytes(
      customer: customer,
      transactions: transactions,
      appTitle: appTitle,
      language: language,
    );
    
    // On desktop, show print/save dialog with preview
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      print('🖨️ [PdfServiceSelector] Showing print dialog for desktop');
      await Printing.layoutPdf(
        onLayout: (format) async => Uint8List.fromList(pdfBytes),
        name: 'customer_${customer.name}_report.pdf',
      );
    } else {
      // On mobile/web, use the original method
      await UnifiedPdfService.generateCustomerReport(
        customer: customer,
        transactions: transactions,
        appTitle: appTitle,
        language: language,
      );
    }
  }
}