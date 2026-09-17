import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../domain/services/debt_calculator_service.dart';
import '../utils/date_formatter.dart';

/// Unified PDF Service - Platform-Independent PDF Generation
/// Works on: Android, iOS, Windows, macOS, Linux, Web
/// Features: Arabic RTL support, embedded fonts, platform-agnostic file operations
class UnifiedPdfService {
  static pw.Font? _arabicFont;
  static pw.Font? _regularFont;
  static bool _fontsInitialized = false;

  /// Initialize fonts (call once at app startup)
  static Future<void> initialize() async {
    if (_fontsInitialized) return;
    
    try {
      print('📦 [UnifiedPdfService] Loading fonts...');
      
      // Try to load Arabic font from Google Fonts (works on all platforms)
      try {
        // Use Noto Naskh Arabic which is more reliable
        _arabicFont = await PdfGoogleFonts.notoNaskhArabicRegular();
        print('✅ [UnifiedPdfService] Arabic font loaded (Noto Naskh Arabic)');
      } catch (e) {
        print('⚠️ [UnifiedPdfService] Google Fonts failed, using Helvetica: $e');
        // Fallback to Helvetica if Google Fonts fails
        _arabicFont = pw.Font.helvetica();
      }
      
      // Load regular font
      try {
        _regularFont = await PdfGoogleFonts.notoSansRegular();
        print('✅ [UnifiedPdfService] Regular font loaded');
      } catch (e) {
        print('⚠️ [UnifiedPdfService] Regular font failed, using Helvetica: $e');
        _regularFont = pw.Font.helvetica();
      }
      
      _fontsInitialized = true;
      print('✅ [UnifiedPdfService] Fonts initialized successfully');
    } catch (e) {
      print('❌ [UnifiedPdfService] Font initialization failed: $e');
      // Use fallback fonts
      _arabicFont = pw.Font.helvetica();
      _regularFont = pw.Font.helvetica();
      _fontsInitialized = true;
    }
  }

  /// Process Arabic text for PDF (reshape for letter joining)
  static String _processArabicText(String text, String language) {
    if (language != 'ar' || text.isEmpty) return text;
    
    try {
      // Apply Arabic reshaping for letter joining
      // This converts isolated Arabic letters to their connected forms
      final reshaped = ArabicReshaper.instance.reshape(text);
      
      // Note: We don't reverse here as it can cause issues with mixed content
      // The RTL layout is handled by the container alignment
      return reshaped;
    } catch (e) {
      print('⚠️ [UnifiedPdfService] Arabic reshaping failed: $e');
      return text;
    }
  }

  /// Build RTL-aware text widget
  static pw.Widget _buildText(
    String text,
    String language, {
    double? fontSize,
    pw.FontWeight? fontWeight,
    PdfColor? color,
    pw.TextAlign? textAlign,
  }) {
    final processedText = _processArabicText(text, language);
    final font = language == 'ar' ? (_arabicFont ?? pw.Font.helvetica()) : (_regularFont ?? pw.Font.helvetica());
    
    final textStyle = pw.TextStyle(
      font: font,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight,
      color: color,
    );
    
    // For Arabic, use right-aligned container
    if (language == 'ar') {
      return pw.Container(
        width: double.infinity,
        child: pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            processedText,
            style: textStyle,
            textAlign: pw.TextAlign.right,
          ),
        ),
      );
    }
    
    return pw.Text(
      processedText,
      style: textStyle,
      textAlign: textAlign ?? pw.TextAlign.left,
    );
  }

  /// Generate customer report PDF
  static Future<void> generateCustomerReport({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
  }) async {
    // Ensure fonts are loaded
    await initialize();
    
    print('📄 [UnifiedPdfService] Generating PDF for ${customer.name}...');
    
    // Calculate totals using DebtCalculator
    final totalCredit = DebtCalculator.calculateTotalCredit(transactions);
    final totalPayment = DebtCalculator.calculateTotalPayments(transactions);
    final balanceCredit = DebtCalculator.calculateBalanceCredit(transactions);
    final debt = DebtCalculator.calculateActualDebt(transactions);

    // Create PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) => [
          // Header
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF2196F3), width: 2),
              ),
            ),
            padding: pw.EdgeInsets.only(bottom: 10),
            child: pw.Column(
              crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  appTitle,
                  language,
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF2196F3),
                ),
                pw.SizedBox(height: 5),
                _buildText(
                  _getText('report', language),
                  language,
                  fontSize: 14,
                  color: PdfColors.grey,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Customer Information
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            padding: pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  _getText('customerInfo', language),
                  language,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                pw.SizedBox(height: 10),
                _buildInfoRow(_getText('name', language), customer.name, language),
                _buildInfoRow(_getText('phone', language), customer.phone ?? 'N/A', language),
                _buildInfoRow(
                  _getText('date', language),
                  AppDateFormatter.formatForPdf(DateTime.now(), language),
                  language,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Financial Summary
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            padding: pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                _buildText(
                  _getText('summary', language),
                  language,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                pw.SizedBox(height: 10),
                _buildSummaryRow(_getText('totalCredit', language), totalCredit, language),
                _buildSummaryRow(_getText('totalPayment', language), totalPayment, language),
                _buildSummaryRow(_getText('debt', language), debt, language, isDebt: true),
                if (balanceCredit > 0)
                  _buildSummaryRow(_getText('balanceCredit', language), balanceCredit, language, isBalance: true),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Transaction History
          if (transactions.isNotEmpty) ...[
            _buildText(
              _getText('transactions', language),
              language,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 10),
            _buildTransactionTable(transactions, language),
          ] else
            _buildText(
              _getText('noTransactions', language),
              language,
              color: PdfColors.grey,
            ),

          pw.SizedBox(height: 40),

          // Footer
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          _buildText(
            _getText('footer', language),
            language,
            fontSize: 10,
            color: PdfColors.grey,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );

    // Save and share PDF (platform-specific)
    await _savePdf(pdf, 'customer-report-${customer.name}.pdf');
    
    print('✅ [UnifiedPdfService] PDF generated successfully');
  }

  /// Build info row (label: value)
  static pw.Widget _buildInfoRow(
    String label,
    String value,
    String language, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: language == 'ar' ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
        children: language == 'ar'
            ? [
                pw.Expanded(
                  child: _buildText(
                    value,
                    language,
                    fontSize: 11,
                    fontWeight: isBold ? pw.FontWeight.bold : null,
                    color: color,
                  ),
                ),
                pw.SizedBox(
                  width: 100,
                  child: _buildText(
                    label,
                    language,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ]
            : [
                pw.SizedBox(
                  width: 100,
                  child: _buildText(
                    label,
                    language,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Expanded(
                  child: _buildText(
                    value,
                    language,
                    fontSize: 11,
                    fontWeight: isBold ? pw.FontWeight.bold : null,
                    color: color,
                  ),
                ),
              ],
      ),
    );
  }

  /// Build summary row (label: amount)
  static pw.Widget _buildSummaryRow(String label, double amount, String language, {bool isDebt = false, bool isBalance = false}) {
    final color = isDebt
        ? PdfColor.fromInt(0xFFD32F2F)
        : isBalance
            ? PdfColor.fromInt(0xFF388E3C)
            : PdfColors.black;

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: language == 'ar' ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
        children: language == 'ar'
            ? [
                pw.Expanded(
                  child: _buildText(
                    '${amount.toStringAsFixed(3)} TND',
                    language,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
                pw.SizedBox(width: 120, child: _buildText(label, language, fontSize: 11)),
              ]
            : [
                pw.SizedBox(width: 120, child: _buildText(label, language, fontSize: 11)),
                pw.Expanded(
                  child: _buildText(
                    '${amount.toStringAsFixed(3)} TND',
                    language,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
      ),
    );
  }

  /// Build transaction table
  static pw.Widget _buildTransactionTable(List<Transaction> transactions, String language) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(2.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F2FD)),
          children: [
            _buildTableCell(_getText('dateTime', language), language, isBold: true),
            _buildTableCell(_getText('type', language), language, isBold: true),
            _buildTableCell(_getText('amount', language), language, isBold: true),
            _buildTableCell(_getText('items', language), language, isBold: true),
            _buildTableCell(_getText('note', language), language, isBold: true),
          ],
        ),
        // Data rows
        ...transactions.map((txn) => pw.TableRow(
          children: [
            _buildTableCell(AppDateFormatter.formatForPdf(txn.createdAt, language), language),
            _buildTableCell(_getTransactionType(txn.type, language), language),
            _buildTableCell('${txn.amount.toStringAsFixed(3)} TND', language),
            _buildTableCell(_formatItems(txn.selectedItems, language), language),
            _buildTableCell(txn.note ?? '-', language),
          ],
        )),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, String language, {bool isBold = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: _buildText(
        text,
        language,
        fontSize: 10,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    );
  }

  /// Save PDF (platform-specific)
  static Future<void> _savePdf(pw.Document pdf, String filename) async {
    final bytes = await pdf.save();

    if (kIsWeb) {
      // Web: trigger download
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } else {
      // Mobile/Desktop: save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);

      // Share on mobile, open on desktop
      if (Platform.isAndroid || Platform.isIOS) {
        await Share.shareXFiles([XFile(file.path)], text: 'Customer Report');
      } else {
        // Desktop: open file
        await OpenFile.open(file.path);
      }
    }
  }

  /// Get localized text
  static String _getText(String key, String language) {
    final texts = {
      'report': {
        'en': 'Customer Report',
        'fr': 'Rapport client',
        'ar': 'تقرير العميل',
      },
      'customerInfo': {
        'en': 'Customer Information',
        'fr': 'Informations client',
        'ar': 'معلومات العميل',
      },
      'name': {
        'en': 'Name:',
        'fr': 'Nom:',
        'ar': 'الاسم:',
      },
      'phone': {
        'en': 'Phone:',
        'fr': 'Téléphone:',
        'ar': 'الهاتف:',
      },
      'date': {
        'en': 'Report Date:',
        'fr': 'Date du rapport:',
        'ar': 'تاريخ التقرير:',
      },
      'summary': {
        'en': 'Financial Summary',
        'fr': 'Résumé financier',
        'ar': 'الملخص المالي',
      },
      'totalCredit': {
        'en': 'Total Credits:',
        'fr': 'Total des crédits:',
        'ar': 'إجمالي الائتمان:',
      },
      'totalPayment': {
        'en': 'Total Payments:',
        'fr': 'Total des paiements:',
        'ar': 'إجمالي المدفوعات:',
      },
      'debt': {
        'en': 'Current Debt:',
        'fr': 'Dette actuelle:',
        'ar': 'الدين الحالي:',
      },
      'remainingDebt': {
        'en': 'Remaining Debt:',
        'fr': 'Dette restante:',
        'ar': 'الدين المتبقي:',
      },
      'balanceCredit': {
        'en': 'Balance Credit:',
        'fr': 'Crédit de solde:',
        'ar': 'رصيد الرصيد:',
      },
      'transactions': {
        'en': 'Transaction History',
        'fr': 'Historique des transactions',
        'ar': 'سجل العمليات',
      },
      'noTransactions': {
        'en': 'No transactions available',
        'fr': 'Aucune transaction disponible',
        'ar': 'لا توجد معاملات',
      },
      'dateTime': {
        'en': 'Date & Time',
        'fr': 'Date & Heure',
        'ar': 'التاريخ والوقت',
      },
      'type': {
        'en': 'Type',
        'fr': 'Type',
        'ar': 'النوع',
      },
      'amount': {
        'en': 'Amount',
        'fr': 'Montant',
        'ar': 'المبلغ',
      },
      'items': {
        'en': 'Items',
        'fr': 'Articles',
        'ar': 'العناصر',
      },
      'note': {
        'en': 'Note',
        'fr': 'Note',
        'ar': 'ملاحظة',
      },
      'generatedOn': {
        'en': 'Generated on:',
        'fr': 'Généré le:',
        'ar': 'تم الإنشاء في:',
      },
      'footer': {
        'en': 'This report was automatically generated. For questions about your account, please contact the administrator.',
        'fr': 'Ce rapport a été généré automatiquement. Pour toute question concernant votre compte, veuillez contacter l\'administrateur.',
        'ar': 'تم إنشاء هذا التقرير تلقائيًا. لأي استفسارات حول حسابك، يرجى الاتصال بالمسؤول.',
      },
    };

    return texts[key]?[language] ?? texts[key]?['en'] ?? key;
  }

  /// Get transaction type text
  static String _getTransactionType(TransactionType type, String language) {
    switch (type) {
      case TransactionType.CREDIT:
        return language == 'fr' ? 'Crédit' : language == 'ar' ? 'رصيد' : 'Credit';
      case TransactionType.PAYMENT:
        return language == 'fr' ? 'Paiement' : language == 'ar' ? 'دفعة' : 'Payment';
      case TransactionType.BALANCE_CREDIT:
        return language == 'fr' ? 'Crédit de Solde' : language == 'ar' ? 'رصيد الرصيد' : 'Balance';
    }
  }

  /// Format items list
  static String _formatItems(List<String> selectedItems, String language) {
    if (selectedItems.isEmpty) return '-';
    
    final itemLabels = {
      'sugar': {'en': 'Sugar', 'fr': 'Sucre', 'ar': 'سكر'},
      'milk': {'en': 'Milk', 'fr': 'Lait', 'ar': 'حليب'},
      'oil': {'en': 'Oil', 'fr': 'Huile', 'ar': 'زيت'},
      'rice': {'en': 'Rice', 'fr': 'Riz', 'ar': 'أرز'},
      'flour': {'en': 'Flour', 'fr': 'Farine', 'ar': 'دقيق'},
      'tea': {'en': 'Tea', 'fr': 'Thé', 'ar': 'شاي'},
      'coffee': {'en': 'Coffee', 'fr': 'Café', 'ar': 'قهوة'},
      'butter': {'en': 'Butter', 'fr': 'Beurre', 'ar': 'زبدة'},
      'cheese': {'en': 'Cheese', 'fr': 'Fromage', 'ar': 'جبن'},
      'eggs': {'en': 'Eggs', 'fr': 'Œufs', 'ar': 'بيض'},
      'salt': {'en': 'Salt', 'fr': 'Sel', 'ar': 'ملح'},
      'detergent': {'en': 'Detergent', 'fr': 'Détergent', 'ar': 'منظف'},
      'soap': {'en': 'Soap', 'fr': 'Savon', 'ar': 'صابون'},
      'chocolate': {'en': 'Chocolate', 'fr': 'Chocolat', 'ar': 'شوكولاتة'},
      'biscuits': {'en': 'Biscuits', 'fr': 'Biscuits', 'ar': 'بسكويت'},
      'tomato': {'en': 'Tomato', 'fr': 'Tomate', 'ar': 'طماطم'},
      'onion': {'en': 'Onion', 'fr': 'Oignon', 'ar': 'بصل'},
      'potato': {'en': 'Potato', 'fr': 'Pomme de terre', 'ar': 'بطاطا'},
      'bread': {'en': 'Bread', 'fr': 'Pain', 'ar': 'خبز'},
    };

    final parts = selectedItems.map((it) {
      final p = it.split(':');
      final key = p[0];
      final qty = p.length > 1 ? p[1] : '1';
      final label = itemLabels[key]?[language] ?? key;
      return '$label x$qty';
    }).toList();

    return parts.join(', ');
  }

  /// Generate customer report PDF and return bytes (for desktop print dialog)
  static Future<List<int>> generateCustomerReportBytes({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
  }) async {
    // Ensure fonts are loaded
    await initialize();
    
    print('📄 [UnifiedPdfService] Generating PDF bytes for ${customer.name}...');
    
    // Calculate totals using DebtCalculator
    final totalCredit = DebtCalculator.calculateTotalCredit(transactions);
    final totalPayment = DebtCalculator.calculateTotalPayments(transactions);
    final balanceCredit = DebtCalculator.calculateBalanceCredit(transactions);
    final debt = DebtCalculator.calculateActualDebt(transactions);

    // Create PDF document (same as generateCustomerReport but return bytes)
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) => _buildPdfContent(
          customer: customer,
          transactions: transactions,
          appTitle: appTitle,
          language: language,
          totalCredit: totalCredit,
          totalPayment: totalPayment,
          balanceCredit: balanceCredit,
          debt: debt,
        ),
      ),
    );

    // Return PDF bytes
    return await pdf.save();
  }

  /// Build PDF content (shared between generateCustomerReport and generateCustomerReportBytes)
  static List<pw.Widget> _buildPdfContent({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
    required double totalCredit,
    required double totalPayment,
    required double balanceCredit,
    required double debt,
  }) {
    return [
      // Header
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF2196F3), width: 2),
          ),
        ),
        padding: pw.EdgeInsets.only(bottom: 10),
        child: pw.Column(
          crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
          children: [
            _buildText(
              appTitle,
              language,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromInt(0xFF2196F3),
            ),
            pw.SizedBox(height: 5),
            _buildText(
              _getText('report', language),
              language,
              fontSize: 14,
              color: PdfColors.grey,
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),

      // Customer Information
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        padding: pw.EdgeInsets.all(15),
        child: pw.Column(
          crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
          children: [
            _buildText(
              _getText('customerInfo', language),
              language,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 10),
            _buildInfoRow(_getText('name', language), customer.name, language),
            _buildInfoRow(_getText('phone', language), customer.phone ?? 'N/A', language),
            _buildInfoRow(
              _getText('date', language),
              AppDateFormatter.formatDate(customer.createdAt, language),
              language,
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),

      // Summary
      pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFF5F5F5),
          borderRadius: pw.BorderRadius.circular(5),
        ),
        padding: pw.EdgeInsets.all(15),
        child: pw.Column(
          crossAxisAlignment: language == 'ar' ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
          children: [
            _buildText(
              _getText('summary', language),
              language,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
            pw.SizedBox(height: 10),
            _buildInfoRow(_getText('totalCredit', language), '${totalCredit.toStringAsFixed(3)} TND', language),
            _buildInfoRow(_getText('totalPayment', language), '${totalPayment.toStringAsFixed(3)} TND', language),
            if (balanceCredit > 0)
              _buildInfoRow(_getText('balanceCredit', language), '${balanceCredit.toStringAsFixed(3)} TND', language),
            pw.Divider(),
            _buildInfoRow(
              _getText('remainingDebt', language),
              '${debt.toStringAsFixed(3)} TND',
              language,
              isBold: true,
              color: debt > 0 ? PdfColor.fromInt(0xFFD32F2F) : PdfColor.fromInt(0xFF388E3C),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),

      // Transactions
      _buildText(
        _getText('transactions', language),
        language,
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      ),
      pw.SizedBox(height: 10),
      
      // Transaction table
      _buildTransactionTable(transactions, language),
      
      // Footer
      pw.SizedBox(height: 30),
      pw.Container(
        alignment: pw.Alignment.center,
        child: _buildText(
          '${_getText('generatedOn', language)} ${AppDateFormatter.formatDateTime(DateTime.now(), language)}',
          language,
          fontSize: 10,
          color: PdfColors.grey,
        ),
      ),
    ];
  }
}

