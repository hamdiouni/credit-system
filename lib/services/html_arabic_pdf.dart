import '../domain/models/customer.dart';
import '../domain/models/transaction.dart';
import '../utils/date_formatter.dart';

// Platform-specific imports using conditional import
// If dart.library.html exists (web), use html_pdf_web.dart
// Otherwise (desktop/mobile with dart:io), use html_pdf_io.dart
import 'html_pdf_stub.dart'
    if (dart.library.html) 'html_pdf_web.dart'
    if (dart.library.io) 'html_pdf_io.dart' as platform;

/// HTML-based Arabic PDF - THE ONLY SOLUTION THAT ACTUALLY WORKS
/// The PDF package cannot render Arabic properly. Period.
/// This uses HTML which browsers render perfectly.
class HtmlArabicPdf {
  
  static Future<void> generateReport({
    required Customer customer,
    required List<Transaction> transactions,
    required String appTitle,
    required String language,
  }) async {
    
    print('🌐 [HtmlArabicPdf] Generating HTML-based Arabic report...');
    
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
    
    // Generate HTML with PERFECT Arabic rendering
    final html = _generateHtml(
      customer: customer,
      transactions: transactions,
      language: language,
      totalCredit: totalCredit,
      totalPayment: totalPayment,
      debt: debt,
    );
    
    // Open in new tab for printing
    await platform.openHtmlInNewTab(html);
    
    print('✅ [HtmlArabicPdf] HTML report opened in new tab');
    print('📋 [HtmlArabicPdf] Use browser Print (Ctrl+P) to save as PDF');
    print('📋 [HtmlArabicPdf] Arabic text will render PERFECTLY with joined letters');
  }
  
  static String _generateHtml({
    required Customer customer,
    required List<Transaction> transactions,
    required String language,
    required double totalCredit,
    required double totalPayment,
    required double debt,
  }) {
    
    final isArabic = language == 'ar';
    
    // Transaction rows
    String txnRows = '';
    for (final txn in transactions) {
      final type = txn.type == TransactionType.CREDIT 
        ? (isArabic ? 'رصيد' : 'Credit')
        : (isArabic ? 'دفعة' : 'Payment');
      final date = AppDateFormatter.formatForPdf(txn.createdAt, language);
      final items = txn.selectedItems.isEmpty ? '-' : _formatItems(txn.selectedItems, language);
      final note = txn.note ?? '-';
      
      txnRows += '''
        <tr>
          <td>$date</td>
          <td>$type</td>
          <td>${txn.amount.toStringAsFixed(3)} TND</td>
          <td>$items</td>
          <td>$note</td>
        </tr>
      ''';
    }
    
    return '''
<!DOCTYPE html>
<html lang="${isArabic ? 'ar' : 'en'}" dir="${isArabic ? 'rtl' : 'ltr'}">
<head>
    <meta charset="UTF-8">
    <title>${isArabic ? 'تقرير العميل' : 'Customer Report'}</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Naskh+Arabic:wght@400;700&family=Noto+Sans:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: ${isArabic ? "'Noto Naskh Arabic', Arial" : "'Noto Sans', Arial"}, sans-serif;
            direction: ${isArabic ? 'rtl' : 'ltr'};
            padding: 40px;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .header {
            border-bottom: 3px solid #2196F3;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        
        h1 {
            color: #2196F3;
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        h2 {
            font-size: 18px;
            margin: 20px 0 15px 0;
            color: #333;
        }
        
        .section {
            background: #f5f5f5;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
        
        .info-row {
            display: flex;
            padding: 8px 0;
            border-bottom: 1px solid #ddd;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .label {
            font-weight: bold;
            min-width: 150px;
            color: #555;
        }
        
        .value {
            flex: 1;
            color: #000;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            background: white;
        }
        
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: ${isArabic ? 'right' : 'left'};
        }
        
        th {
            background: #2196F3;
            color: white;
            font-weight: bold;
        }
        
        tr:nth-child(even) {
            background: #f9f9f9;
        }
        
        .debt {
            color: #d32f2f;
            font-weight: bold;
            font-size: 18px;
        }
        
        .credit {
            color: #388e3c;
            font-weight: bold;
        }
        
        @media print {
            body { padding: 20px; }
            .no-print { display: none; }
        }
        
        .print-button {
            position: fixed;
            top: 20px;
            ${isArabic ? 'left' : 'right'}: 20px;
            background: #2196F3;
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 16px;
            border-radius: 5px;
            cursor: pointer;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        
        .print-button:hover {
            background: #1976D2;
        }
    </style>
</head>
<body>
    <button class="print-button no-print" onclick="window.print()">
        ${isArabic ? '🖨️ طباعة / حفظ PDF' : '🖨️ Print / Save PDF'}
    </button>
    
    <div class="header">
        <h1>${isArabic ? 'مدير الائتمان' : 'Credit Manager'}</h1>
        <p style="color: #666; font-size: 16px;">${isArabic ? 'تقرير العميل' : 'Customer Report'}</p>
    </div>
    
    <div class="section">
        <h2>${isArabic ? 'معلومات العميل' : 'Customer Information'}</h2>
        <div class="info-row">
            <div class="label">${isArabic ? 'الاسم:' : 'Name:'}</div>
            <div class="value">${customer.name}</div>
        </div>
        <div class="info-row">
            <div class="label">${isArabic ? 'الهاتف:' : 'Phone:'}</div>
            <div class="value">${customer.phone ?? 'N/A'}</div>
        </div>
        <div class="info-row">
            <div class="label">${isArabic ? 'تاريخ التقرير:' : 'Report Date:'}</div>
            <div class="value">${AppDateFormatter.formatForPdf(DateTime.now(), language)}</div>
        </div>
    </div>
    
    <div class="section">
        <h2>${isArabic ? 'الملخص المالي' : 'Financial Summary'}</h2>
        <div class="info-row">
            <div class="label">${isArabic ? 'إجمالي الائتمان:' : 'Total Credits:'}</div>
            <div class="value credit">${totalCredit.toStringAsFixed(3)} TND</div>
        </div>
        <div class="info-row">
            <div class="label">${isArabic ? 'إجمالي المدفوعات:' : 'Total Payments:'}</div>
            <div class="value credit">${totalPayment.toStringAsFixed(3)} TND</div>
        </div>
        <div class="info-row">
            <div class="label">${isArabic ? 'الدين الحالي:' : 'Current Debt:'}</div>
            <div class="value debt">${debt.toStringAsFixed(3)} TND</div>
        </div>
    </div>
    
    <h2>${isArabic ? 'سجل العمليات' : 'Transaction History'}</h2>
    <table>
        <thead>
            <tr>
                <th>${isArabic ? 'التاريخ والوقت' : 'Date & Time'}</th>
                <th>${isArabic ? 'النوع' : 'Type'}</th>
                <th>${isArabic ? 'المبلغ' : 'Amount'}</th>
                <th>${isArabic ? 'العناصر' : 'Items'}</th>
                <th>${isArabic ? 'ملاحظة' : 'Note'}</th>
            </tr>
        </thead>
        <tbody>
            $txnRows
        </tbody>
    </table>
    
    <div style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #666; font-size: 12px;">
        ${isArabic 
          ? 'تم إنشاء هذا التقرير تلقائيًا. لأي استفسارات، يرجى الاتصال بالمسؤول.'
          : 'This report was automatically generated. For inquiries, please contact the administrator.'}
    </div>
</body>
</html>
    ''';
  }
  
  static String _formatItems(List<String> items, String language) {
    final isArabic = language == 'ar';
    final isFrench = language == 'fr';
    
    final itemMap = {
      'sugar': isArabic ? 'سكر' : isFrench ? 'Sucre' : 'Sugar',
      'milk': isArabic ? 'حليب' : isFrench ? 'Lait' : 'Milk',
      'oil': isArabic ? 'زيت' : isFrench ? 'Huile' : 'Oil',
      'rice': isArabic ? 'أرز' : isFrench ? 'Riz' : 'Rice',
      'flour': isArabic ? 'دقيق' : isFrench ? 'Farine' : 'Flour',
      'tea': isArabic ? 'شاي' : isFrench ? 'Thé' : 'Tea',
      'coffee': isArabic ? 'قهوة' : isFrench ? 'Café' : 'Coffee',
      'butter': isArabic ? 'زبدة' : isFrench ? 'Beurre' : 'Butter',
      'cheese': isArabic ? 'جبن' : isFrench ? 'Fromage' : 'Cheese',
      'eggs': isArabic ? 'بيض' : isFrench ? 'Œufs' : 'Eggs',
      'salt': isArabic ? 'ملح' : isFrench ? 'Sel' : 'Salt',
      'detergent': isArabic ? 'منظف' : isFrench ? 'Détergent' : 'Detergent',
      'soap': isArabic ? 'صابون' : isFrench ? 'Savon' : 'Soap',
      'chocolate': isArabic ? 'شوكولاتة' : isFrench ? 'Chocolat' : 'Chocolate',
      'biscuits': isArabic ? 'بسكويت' : isFrench ? 'Biscuits' : 'Biscuits',
      'tomato': isArabic ? 'طماطم' : isFrench ? 'Tomate' : 'Tomato',
      'onion': isArabic ? 'بصل' : isFrench ? 'Oignon' : 'Onion',
      'potato': isArabic ? 'بطاطا' : isFrench ? 'Pomme de terre' : 'Potato',
      'bread': isArabic ? 'خبز' : isFrench ? 'Pain' : 'Bread',
    };
    
    return items.map((item) {
      final parts = item.split(':');
      final key = parts[0];
      final qty = parts.length > 1 ? parts[1] : '1';
      final label = itemMap[key] ?? key;
      return '$label x$qty';
    }).join(', ');
  }
}
