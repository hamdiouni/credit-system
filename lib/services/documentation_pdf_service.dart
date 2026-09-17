import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';

class DocumentationPdfService {
  static pw.Font? _arabicFont;
  static pw.Font? _regularFont;

  static Future<void> generateDocumentation(String language) async {
    try {
      print('📄 [DocumentationPDF] Generating documentation in $language...');
      
      // Load fonts - always use Noto fonts to avoid Helvetica warnings
      try {
        _arabicFont = await PdfGoogleFonts.notoNaskhArabicRegular();
        _regularFont = await PdfGoogleFonts.notoSansRegular();
        print('✅ [DocumentationPDF] Fonts loaded successfully');
      } catch (e) {
        print('⚠️ [DocumentationPDF] Failed to load fonts: $e');
        _arabicFont = await PdfGoogleFonts.notoSansRegular();
        _regularFont = await PdfGoogleFonts.notoSansRegular();
      }
      
      final pdf = pw.Document();
      final isRtl = language == 'ar' || language == 'tn';
      
      print('📝 [DocumentationPDF] Building PDF pages...');
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Cover page
                _buildCover(language, isRtl),
                pw.SizedBox(height: 40),
                
                // Getting Started
                _buildSection(
                  _getText('gettingStarted', language),
                  _getText('gettingStartedContent', language),
                  language,
                  isRtl,
                ),
                _buildStepsDiagram(_getSteps('workflow', language), language, isRtl),
              ],
            );
          },
        ),
      );
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Add Customer
                _buildSection(
                  _getText('addCustomer', language),
                  _getText('addCustomerContent', language),
                  language,
                  isRtl,
                ),
                _buildStepsDiagram(_getSteps('add_customer', language), language, isRtl),
                pw.SizedBox(height: 20),
                
                // Add Credit
                _buildSection(
                  _getText('addCredit', language),
                  _getText('addCreditContent', language),
                  language,
                  isRtl,
                ),
                _buildStepsDiagram(_getSteps('add_credit', language), language, isRtl),
              ],
            );
          },
        ),
      );
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Add Payment
                _buildSection(
                  _getText('addPayment', language),
                  _getText('addPaymentContent', language),
                  language,
                  isRtl,
                ),
                _buildStepsDiagram(_getSteps('add_payment', language), language, isRtl),
                pw.SizedBox(height: 20),
                
                // Balance Credit
                _buildSection(
                  _getText('balanceCredit', language),
                  _getText('balanceCreditContent', language),
                  language,
                  isRtl,
                ),
                _buildStepsDiagram(_getSteps('balance_credit', language), language, isRtl),
              ],
            );
          },
        ),
      );
      
      print('💾 [DocumentationPDF] Saving PDF...');
      
      // Save and share - Web compatible
      await _savePdf(pdf, 'credit_system_documentation_$language.pdf');
      
      print('✅ [DocumentationPDF] Documentation generated successfully');
    } catch (e, stackTrace) {
      print('❌ [DocumentationPDF] Error generating documentation: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static pw.Widget _buildCover(String language, bool isRtl) {
    return pw.Container(
      height: 200,
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColor.fromInt(0xFF2196F3), PdfColor.fromInt(0xFF1976D2)],
        ),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _buildText(
              _getText('appTitle', language),
              language,
              fontSize: 32,
              color: PdfColors.white,
            ),
            pw.SizedBox(height: 12),
            _buildText(
              _getText('userGuide', language),
              language,
              fontSize: 20,
              color: PdfColors.white,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSection(String title, String content, String language, bool isRtl) {
    return pw.Column(
      crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFE3F2FD),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: _buildText(
            title,
            language,
            fontSize: 20,
            color: PdfColor.fromInt(0xFF1976D2),
          ),
        ),
        pw.SizedBox(height: 12),
        _buildText(content, language, fontSize: 14),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget _buildStepsDiagram(List<String> steps, String language, bool isRtl) {
    return pw.Container(
      padding: pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFBDBDBD)),
      ),
      child: pw.Column(
        crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final widgets = <pw.Widget>[
            pw.Row(
              mainAxisAlignment: isRtl ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
              children: isRtl ? [
                pw.Expanded(
                  child: _buildText(steps[index], language, fontSize: 12),
                ),
                pw.SizedBox(width: 12),
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF2196F3),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${index + 1}',
                      style: pw.TextStyle(
                        font: _regularFont ?? pw.Font.helvetica(),
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ] : [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF2196F3),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${index + 1}',
                      style: pw.TextStyle(
                        font: _regularFont ?? pw.Font.helvetica(),
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: _buildText(steps[index], language, fontSize: 12),
                ),
              ],
            ),
          ];
          
          if (index < steps.length - 1) {
            widgets.add(
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: isRtl ? 0 : 12,
                  right: isRtl ? 12 : 0,
                  top: 4,
                  bottom: 4,
                ),
                child: pw.Container(
                  width: 2,
                  height: 16,
                  color: PdfColor.fromInt(0xFF2196F3),
                ),
              ),
            );
          }
          
          return pw.Column(children: widgets);
        }),
      ),
    );
  }

  static pw.Widget _buildText(
    String text,
    String language, {
    double? fontSize,
    PdfColor? color,
  }) {
    final isRtl = language == 'ar' || language == 'tn';
    String processedText = text;
    
    if (isRtl) {
      try {
        processedText = ArabicReshaper.instance.reshape(text);
      } catch (e) {
        processedText = text;
      }
    }
    
    // Always use loaded fonts, never fall back to Helvetica
    final font = isRtl 
        ? (_arabicFont ?? _regularFont ?? pw.Font.helvetica())
        : (_regularFont ?? pw.Font.helvetica());
    
    return pw.Text(
      processedText,
      style: pw.TextStyle(
        font: font,
        fontSize: fontSize ?? 12,
        color: color,
      ),
      textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
    );
  }

  static Future<void> _savePdf(pw.Document pdf, String filename) async {
    try {
      print('💾 [DocumentationPDF] Converting PDF to bytes...');
      final bytes = await pdf.save();
      print('✅ [DocumentationPDF] PDF bytes generated: ${bytes.length} bytes');

      print('📤 [DocumentationPDF] Sharing PDF via Printing.sharePdf...');
      // Always use Printing.sharePdf - works on all platforms
      await Printing.sharePdf(bytes: bytes, filename: filename);
      print('✅ [DocumentationPDF] PDF shared successfully');
    } catch (e, stackTrace) {
      print('❌ [DocumentationPDF] Error saving/sharing PDF: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static List<String> _getSteps(String type, String language) {
    final steps = {
      'workflow': {
        'en': ['Open app and login with PIN', 'View customer list', 'Select customer or add new one', 'Add credit (debt) or payment', 'View updated balance'],
        'ar': ['افتح التطبيق وسجل الدخول بالرمز', 'عرض قائمة العملاء', 'اختر عميل أو أضف جديد', 'أضف رصيد (دين) أو دفعة', 'عرض الرصيد المحدث'],
        'fr': ['Ouvrir l\'app et se connecter avec PIN', 'Voir la liste des clients', 'Sélectionner un client ou en ajouter un nouveau', 'Ajouter crédit (dette) ou paiement', 'Voir le solde mis à jour'],
        'tn': ['احلل الأبليكاسيون و دخل بالكود', 'شوف لستة متع الكليان', 'اختار كليون ولا زيد واحد جديد', 'زيد كريدي (دين) ولا خلاص', 'شوف الباقي المحدث'],
      },
      'add_customer': {
        'en': ['Click + button', 'Enter customer name', 'Enter phone number (optional)', 'Click Save', 'Customer added to list'],
        'ar': ['انقر على زر +', 'أدخل اسم العميل', 'أدخل رقم الهاتف (اختياري)', 'انقر على حفظ', 'تمت إضافة العميل إلى القائمة'],
        'fr': ['Cliquer sur le bouton +', 'Entrer le nom du client', 'Entrer le numéro de téléphone (optionnel)', 'Cliquer sur Enregistrer', 'Client ajouté à la liste'],
        'tn': ['انقر على زر +', 'اكتب اسم الكليون', 'اكتب نمرة التليفون (اختياري)', 'انقر على احفظ', 'الكليون تزاد في اللستة'],
      },
      'add_credit': {
        'en': ['Open customer detail', 'Click "Add Credit"', 'Enter amount', 'Select grocery items (optional)', 'Add note (optional)', 'Click Save'],
        'ar': ['افتح تفاصيل العميل', 'انقر على "إضافة رصيد"', 'أدخل المبلغ', 'اختر عناصر البقالة (اختياري)', 'أضف ملاحظة (اختياري)', 'انقر على حفظ'],
        'fr': ['Ouvrir les détails du client', 'Cliquer sur "Ajouter un Crédit"', 'Entrer le montant', 'Sélectionner les articles (optionnel)', 'Ajouter une note (optionnel)', 'Cliquer sur Enregistrer'],
        'tn': ['احلل تفاصيل الكليون', 'انقر على "زيد كريدي"', 'اكتب المبلغ', 'اختار الحوايج (اختياري)', 'زيد نوتة (اختياري)', 'انقر على احفظ'],
      },
      'add_payment': {
        'en': ['Open customer detail', 'Click "Add Payment"', 'Enter payment amount', 'For overpayment: Check "Allow Overpayment"', 'Add note (optional)', 'Click Save'],
        'ar': ['افتح تفاصيل العميل', 'انقر على "إضافة دفعة"', 'أدخل مبلغ الدفع', 'للدفع الزائد: فعّل "السماح بالدفع الزائد"', 'أضف ملاحظة (اختياري)', 'انقر على حفظ'],
        'fr': ['Ouvrir les détails du client', 'Cliquer sur "Ajouter un Paiement"', 'Entrer le montant du paiement', 'Pour trop-payé: Cocher "Autoriser le trop-payé"', 'Ajouter une note (optionnel)', 'Cliquer sur Enregistrer'],
        'tn': ['احلل تفاصيل الكليون', 'انقر على "زيد خلاص"', 'اكتب مبلغ الخلاص', 'للخلاص الزايد: فعّل "اسمح بالخلاص الزايد"', 'زيد نوتة (اختياري)', 'انقر على احفظ'],
      },
      'balance_credit': {
        'en': ['Customer pays more than debt', 'Check "Allow Overpayment" checkbox', 'Confirm overpayment', 'Balance credit created automatically', 'Balance reduces future debt automatically'],
        'ar': ['العميل يدفع أكثر من الدين', 'فعّل خانة "السماح بالدفع الزائد"', 'تأكيد الدفع الزائد', 'يتم إنشاء رصيد الرصيد تلقائيًا', 'الرصيد يقلل الدين المستقبلي تلقائيًا'],
        'fr': ['Le client paie plus que la dette', 'Cocher "Autoriser le trop-payé"', 'Confirmer le trop-payé', 'Crédit de solde créé automatiquement', 'Le solde réduit la dette future automatiquement'],
        'tn': ['الكليون يخلص أكثر من الدين', 'فعّل "اسمح بالخلاص الزايد"', 'أكد الخلاص الزايد', 'الباقي يتصنع أوتوماتيكيًا', 'الباقي ينقص الدين الجاي أوتوماتيكيًا'],
      },
    };
    
    return steps[type]?[language] ?? steps[type]?['en'] ?? [];
  }

  static String _getText(String key, String language) {
    final texts = {
      'appTitle': {'en': 'Credit System', 'ar': 'نظام الائتمان', 'fr': 'Système de Crédit', 'tn': 'سيستام الكريدي'},
      'userGuide': {'en': 'User Guide', 'ar': 'دليل المستخدم', 'fr': 'Guide de l\'Utilisateur', 'tn': 'دليل الاستخدام'},
      'gettingStarted': {'en': 'Getting Started', 'ar': 'البدء', 'fr': 'Commencer', 'tn': 'البداية'},
      'gettingStartedContent': {'en': 'Welcome to Credit System! This app helps you manage customer credit and payments easily.', 'ar': 'مرحبًا بك في نظام الائتمان! يساعدك هذا التطبيق على إدارة ائتمان العملاء والمدفوعات بسهولة.', 'fr': 'Bienvenue dans le Système de Crédit! Cette application vous aide à gérer facilement le crédit et les paiements des clients.', 'tn': 'مرحبا بيك في سيستام الكريدي! هذا الأبليكاسيون يعاونك باش تجستيوني الكريدي متع الكليان والخلاصات بسهولة.'},
      'addCustomer': {'en': 'Add Customer', 'ar': 'إضافة عميل', 'fr': 'Ajouter un Client', 'tn': 'زيد كليون'},
      'addCustomerContent': {'en': 'Add new customers to track their credit and payments.', 'ar': 'أضف عملاء جدد لتتبع ائتمانهم ومدفوعاتهم.', 'fr': 'Ajoutez de nouveaux clients pour suivre leur crédit et leurs paiements.', 'tn': 'زيد كليان جداد باش تتبع الكريدي والخلاصات متاعهم.'},
      'addCredit': {'en': 'Add Credit (Debt)', 'ar': 'إضافة رصيد (دين)', 'fr': 'Ajouter un Crédit (Dette)', 'tn': 'زيد كريدي (دين)'},
      'addCreditContent': {'en': 'Record when a customer buys items on credit.', 'ar': 'سجل عندما يشتري العميل عناصر بالائتمان.', 'fr': 'Enregistrez lorsqu\'un client achète des articles à crédit.', 'tn': 'سجل كي الكليون يشري حوايج بالكريدي.'},
      'addPayment': {'en': 'Add Payment', 'ar': 'إضافة دفعة', 'fr': 'Ajouter un Paiement', 'tn': 'زيد خلاص'},
      'addPaymentContent': {'en': 'Record customer payments. Enable overpayment for balance credit.', 'ar': 'سجل مدفوعات العملاء. فعّل الدفع الزائد لرصيد الرصيد.', 'fr': 'Enregistrez les paiements. Activez le trop-payé pour le crédit de solde.', 'tn': 'سجل خلاصات الكليان. فعّل الخلاص الزايد للباقي.'},
      'balanceCredit': {'en': 'Balance Credit System', 'ar': 'نظام رصيد الرصيد', 'fr': 'Système de Crédit de Solde', 'tn': 'سيستام الباقي'},
      'balanceCreditContent': {'en': 'Overpayments become balance credit that automatically reduces future debt.', 'ar': 'الدفعات الزائدة تصبح رصيد رصيد يقلل تلقائيًا من الديون المستقبلية.', 'fr': 'Les trop-payés deviennent un crédit de solde qui réduit automatiquement la dette future.', 'tn': 'الخلاصات الزايدة تولي باقي ينقص أوتوماتيكيًا من الدين الجاي.'},
    };
    
    return texts[key]?[language] ?? texts[key]?['en'] ?? key;
  }
}
