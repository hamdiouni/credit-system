import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';

/// WORKING Arabic PDF Service - Simple and Direct
/// This service focuses on actually working, not complex solutions
class WorkingArabicPdf {
  
  static Future<void> generateReport({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
  }) async {
    
    print('🚀 [WorkingArabicPdf] Starting WORKING Arabic PDF generation...');
    
    try {
      final pdf = pw.Document();
      
      // Load fonts - simple approach
      pw.Font arabicFont;
      pw.Font regularFont;
      
      try {
        arabicFont = await PdfGoogleFonts.notoNaskhArabicRegular();
        regularFont = await PdfGoogleFonts.notoSansRegular();
        print('✅ [WorkingArabicPdf] Fonts loaded successfully');
      } catch (e) {
        print('⚠️ [WorkingArabicPdf] Using fallback fonts: $e');
        arabicFont = pw.Font.helvetica();
        regularFont = pw.Font.helvetica();
      }
      
      // Calculate totals
      double totalCredit = 0;
      double totalPayment = 0;
      
      for (final txn in transactions) {
        if (txn.type == TransactionType.CREDIT) {
          totalCredit += txn.amount;
        } else if (txn.type == TransactionType.PAYMENT) {
          totalPayment += txn.amount;
        }
      }
      
      final debt = totalCredit - totalPayment;
      
      // WORKING Arabic text - no complex processing
      final arabicTexts = {
        'title': language == 'ar' ? 'مدير الائتمان' : 'Credit Manager',
        'report': language == 'ar' ? 'تقرير العميل' : 'Customer Report',
        'customerInfo': language == 'ar' ? 'معلومات العميل' : 'Customer Information',
        'name': language == 'ar' ? 'الاسم' : 'Name',
        'phone': language == 'ar' ? 'الهاتف' : 'Phone',
        'date': language == 'ar' ? 'التاريخ' : 'Date',
        'summary': language == 'ar' ? 'الملخص المالي' : 'Financial Summary',
        'totalCredit': language == 'ar' ? 'إجمالي الائتمان' : 'Total Credit',
        'totalPayment': language == 'ar' ? 'إجمالي المدفوعات' : 'Total Payments',
        'debt': language == 'ar' ? 'الدين الحالي' : 'Current Debt',
        'transactions': language == 'ar' ? 'سجل العمليات' : 'Transaction History',
      };
      
      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          textDirection: language == 'ar' ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          build: (context) => [
            
            // Header
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.only(bottom: 20),
              decoration: pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue, width: 2)),
              ),
              child: pw.Column(
                crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end :