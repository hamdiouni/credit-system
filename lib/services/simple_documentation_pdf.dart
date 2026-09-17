import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';

class SimpleDocumentationPdf {
  static Future<void> generate(String language) async {
    print('[SimpleDocPDF] Generating documentation in $language...');
    
    try {
      // Load fonts
      final regularFont = await PdfGoogleFonts.notoSansRegular();
      final arabicFont = await PdfGoogleFonts.notoNaskhArabicRegular();
      print('[SimpleDocPDF] Fonts loaded');
      
      final isRtl = language == 'ar' || language == 'tn';
      final font = isRtl ? arabicFont : regularFont;
      
      final pdf = pw.Document();
      
      // Colors
      final primaryColor = PdfColor.fromInt(0xFF2196F3);
      final accentColor = PdfColor.fromInt(0xFF1976D2);
      final lightBg = PdfColor.fromInt(0xFFE3F2FD);
      final stepColor = PdfColor.fromInt(0xFF4CAF50);
      
      // Get content
      final content = _getContent(language);
      
      // Page 1: Cover + Getting Started
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Cover Box
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(30),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [primaryColor, accentColor],
                    ),
                    borderRadius: pw.BorderRadius.circular(15),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        _processText(content['title']!, isRtl),
                        style: pw.TextStyle(font: font, fontSize: 28, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        _processText(content['subtitle']!, isRtl),
                        style: pw.TextStyle(font: font, fontSize: 14, color: PdfColors.white),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                
                // Getting Started Section
                _buildSectionHeader(content['section1Title']!, font, isRtl, primaryColor),
                pw.SizedBox(height: 10),
                _buildTextBlock(content['section1Content']!, font, isRtl),
                pw.SizedBox(height: 15),
                
                // Steps Diagram
                _buildStepsDiagram(content['section1Steps']!, font, isRtl, stepColor),
              ],
            );
          },
        ),
      );
      
      // Page 2: Add Customer + Add Credit
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Add Customer Section
                _buildSectionHeader(content['section2Title']!, font, isRtl, primaryColor),
                pw.SizedBox(height: 10),
                _buildTextBlock(content['section2Content']!, font, isRtl),
                pw.SizedBox(height: 15),
                _buildStepsDiagram(content['section2Steps']!, font, isRtl, stepColor),
                pw.SizedBox(height: 25),
                
                // Add Credit Section
                _buildSectionHeader(content['section3Title']!, font, isRtl, primaryColor),
                pw.SizedBox(height: 10),
                _buildTextBlock(content['section3Content']!, font, isRtl),
                pw.SizedBox(height: 15),
                _buildStepsDiagram(content['section3Steps']!, font, isRtl, stepColor),
              ],
            );
          },
        ),
      );
      
      // Page 3: Add Payment + Balance Credit
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
              children: [
                // Add Payment Section
                _buildSectionHeader(content['section4Title']!, font, isRtl, primaryColor),
                pw.SizedBox(height: 10),
                _buildTextBlock(content['section4Content']!, font, isRtl),
                pw.SizedBox(height: 15),
                _buildStepsDiagram(content['section4Steps']!, font, isRtl, stepColor),
                pw.SizedBox(height: 25),
                
                // Balance Credit Section
                _buildSectionHeader(content['section5Title']!, font, isRtl, primaryColor),
                pw.SizedBox(height: 10),
                _buildTextBlock(content['section5Content']!, font, isRtl),
                pw.SizedBox(height: 15),
                _buildInfoBox(content['section5Info']!, font, isRtl, lightBg),
              ],
            );
          },
        ),
      );
      
      print('[SimpleDocPDF] Saving PDF...');
      final bytes = await pdf.save();
      print('[SimpleDocPDF] PDF bytes: ${bytes.length}');
      
      print('[SimpleDocPDF] Sharing PDF...');
      await Printing.sharePdf(bytes: bytes, filename: 'credit_system_guide_$language.pdf');
      print('[SimpleDocPDF] PDF shared successfully!');
      
    } catch (e, stack) {
      print('[SimpleDocPDF] Error: $e');
      print('Stack: $stack');
      rethrow;
    }
  }
  
  static pw.Widget _buildSectionHeader(String text, pw.Font font, bool isRtl, PdfColor color) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE3F2FD),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: isRtl ? pw.MainAxisAlignment.end : pw.MainAxisAlignment.start,
        children: [
          if (!isRtl) pw.Container(
            width: 4,
            height: 20,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          if (!isRtl) pw.SizedBox(width: 8),
          pw.Text(
            _processText(text, isRtl),
            style: pw.TextStyle(font: font, fontSize: 18, color: color),
            textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
          ),
          if (isRtl) pw.SizedBox(width: 8),
          if (isRtl) pw.Container(
            width: 4,
            height: 20,
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTextBlock(String text, pw.Font font, bool isRtl) {
    return pw.Text(
      _processText(text, isRtl),
      style: pw.TextStyle(font: font, fontSize: 12),
      textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
    );
  }
  
  static pw.Widget _buildStepsDiagram(List<String> steps, pw.Font font, bool isRtl, PdfColor color) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF5F5F5),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: isRtl ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          return pw.Padding(
            padding: pw.EdgeInsets.only(bottom: index < steps.length - 1 ? 12 : 0),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: isRtl ? [
                pw.Expanded(
                  child: pw.Text(
                    _processText(steps[index], isRtl),
                    style: pw.TextStyle(font: font, fontSize: 11),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: color,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${index + 1}',
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.white),
                    ),
                  ),
                ),
              ] : [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: color,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${index + 1}',
                      style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.white),
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Text(
                    _processText(steps[index], isRtl),
                    style: pw.TextStyle(font: font, fontSize: 11),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  static pw.Widget _buildInfoBox(String text, pw.Font font, bool isRtl, PdfColor bgColor) {
    return pw.Container(
      width: double.infinity,
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Text(
        _processText(text, isRtl),
        style: pw.TextStyle(font: font, fontSize: 11),
        textAlign: isRtl ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }
  
  static String _processText(String text, bool isRtl) {
    if (isRtl) {
      try {
        return ArabicReshaper.instance.reshape(text);
      } catch (e) {
        return text;
      }
    }
    return text;
  }
  
  static Map<String, dynamic> _getContent(String language) {
    final content = {
      'en': {
        'title': 'Credit System',
        'subtitle': 'Complete User Guide',
        'section1Title': 'Getting Started',
        'section1Content': 'Welcome to Credit System! This app helps you manage customer credit and payments easily.',
        'section1Steps': [
          'Open the app on your device',
          'Login with your 4-digit PIN code',
          'View the customer list on the main screen',
          'Use the + button to add new customers',
        ],
        'section2Title': 'Add New Customer',
        'section2Content': 'Add customers to track their purchases and payments.',
        'section2Steps': [
          'Click the + button at the bottom',
          'Enter customer name (required)',
          'Enter phone number (optional)',
          'Click Save button',
          'Customer appears in the list',
        ],
        'section3Title': 'Add Credit (Debt)',
        'section3Content': 'Record when customers buy items on credit.',
        'section3Steps': [
          'Select a customer from the list',
          'Click "Add Credit" button',
          'Enter the amount',
          'Select grocery items (optional)',
          'Add a note (optional)',
          'Click Save',
        ],
        'section4Title': 'Add Payment',
        'section4Content': 'Record customer payments to reduce their debt.',
        'section4Steps': [
          'Select a customer from the list',
          'Click "Add Payment" button',
          'Enter payment amount',
          'For overpayment: Check "Allow Overpayment"',
          'Add a note (optional)',
          'Click Save',
        ],
        'section5Title': 'Balance Credit System',
        'section5Content': 'When customers pay more than their debt, the extra amount becomes balance credit.',
        'section5Info': 'Balance credit automatically reduces future debt. No need to track overpayments manually. Customers can use their balance for next purchases.',
      },
      'ar': {
        'title': 'نظام الائتمان',
        'subtitle': 'دليل المستخدم الكامل',
        'section1Title': 'البدء',
        'section1Content': 'مرحبا بك في نظام الائتمان! يساعدك هذا التطبيق على إدارة ائتمان العملاء والمدفوعات بسهولة.',
        'section1Steps': [
          'افتح التطبيق على جهازك',
          'سجل الدخول برمز PIN المكون من 4 أرقام',
          'اعرض قائمة العملاء على الشاشة الرئيسية',
          'استخدم زر + لإضافة عملاء جدد',
        ],
        'section2Title': 'إضافة عميل جديد',
        'section2Content': 'أضف عملاء لتتبع مشترياتهم ومدفوعاتهم.',
        'section2Steps': [
          'انقر على زر + في الأسفل',
          'أدخل اسم العميل (مطلوب)',
          'أدخل رقم الهاتف (اختياري)',
          'انقر على زر حفظ',
          'يظهر العميل في القائمة',
        ],
        'section3Title': 'إضافة رصيد (دين)',
        'section3Content': 'سجل عندما يشتري العملاء عناصر بالائتمان.',
        'section3Steps': [
          'اختر عميلا من القائمة',
          'انقر على زر "إضافة رصيد"',
          'أدخل المبلغ',
          'اختر عناصر البقالة (اختياري)',
          'أضف ملاحظة (اختياري)',
          'انقر على حفظ',
        ],
        'section4Title': 'إضافة دفعة',
        'section4Content': 'سجل مدفوعات العملاء لتقليل ديونهم.',
        'section4Steps': [
          'اختر عميلا من القائمة',
          'انقر على زر "إضافة دفعة"',
          'أدخل مبلغ الدفع',
          'للدفع الزائد: فعل "السماح بالدفع الزائد"',
          'أضف ملاحظة (اختياري)',
          'انقر على حفظ',
        ],
        'section5Title': 'نظام رصيد الرصيد',
        'section5Content': 'عندما يدفع العملاء أكثر من ديونهم، يصبح المبلغ الإضافي رصيد رصيد.',
        'section5Info': 'رصيد الرصيد يقلل تلقائيا من الديون المستقبلية. لا حاجة لتتبع الدفعات الزائدة يدويا. يمكن للعملاء استخدام رصيدهم للمشتريات التالية.',
      },
      'fr': {
        'title': 'Système de Crédit',
        'subtitle': 'Guide Utilisateur Complet',
        'section1Title': 'Commencer',
        'section1Content': 'Bienvenue dans le Système de Crédit! Cette application vous aide à gérer facilement le crédit et les paiements des clients.',
        'section1Steps': [
          'Ouvrez l\'application sur votre appareil',
          'Connectez-vous avec votre code PIN à 4 chiffres',
          'Affichez la liste des clients sur l\'écran principal',
          'Utilisez le bouton + pour ajouter de nouveaux clients',
        ],
        'section2Title': 'Ajouter un Nouveau Client',
        'section2Content': 'Ajoutez des clients pour suivre leurs achats et paiements.',
        'section2Steps': [
          'Cliquez sur le bouton + en bas',
          'Entrez le nom du client (requis)',
          'Entrez le numéro de téléphone (optionnel)',
          'Cliquez sur le bouton Enregistrer',
          'Le client apparaît dans la liste',
        ],
        'section3Title': 'Ajouter un Crédit (Dette)',
        'section3Content': 'Enregistrez lorsque les clients achètent des articles à crédit.',
        'section3Steps': [
          'Sélectionnez un client dans la liste',
          'Cliquez sur le bouton "Ajouter un Crédit"',
          'Entrez le montant',
          'Sélectionnez les articles d\'épicerie (optionnel)',
          'Ajoutez une note (optionnel)',
          'Cliquez sur Enregistrer',
        ],
        'section4Title': 'Ajouter un Paiement',
        'section4Content': 'Enregistrez les paiements des clients pour réduire leur dette.',
        'section4Steps': [
          'Sélectionnez un client dans la liste',
          'Cliquez sur le bouton "Ajouter un Paiement"',
          'Entrez le montant du paiement',
          'Pour trop-payé: Cochez "Autoriser le trop-payé"',
          'Ajoutez une note (optionnel)',
          'Cliquez sur Enregistrer',
        ],
        'section5Title': 'Système de Crédit de Solde',
        'section5Content': 'Lorsque les clients paient plus que leur dette, le montant supplémentaire devient un crédit de solde.',
        'section5Info': 'Le crédit de solde réduit automatiquement la dette future. Pas besoin de suivre les trop-payés manuellement. Les clients peuvent utiliser leur solde pour les prochains achats.',
      },
      'tn': {
        'title': 'سيستام الكريدي',
        'subtitle': 'دليل الاستخدام الكامل',
        'section1Title': 'البداية',
        'section1Content': 'مرحبا بيك في سيستام الكريدي! هذا الأبليكاسيون يعاونك باش تجستيوني الكريدي والخلاصات متع الكليان بسهولة.',
        'section1Steps': [
          'احلل الأبليكاسيون على التليفون متاعك',
          'دخل بالكود متاعك (4 أرقام)',
          'شوف لستة الكليان على الشاشة الرئيسية',
          'استعمل زر + باش تزيد كليان جداد',
        ],
        'section2Title': 'زيد كليون جديد',
        'section2Content': 'زيد كليان باش تتبع الشراءات والخلاصات متاعهم.',
        'section2Steps': [
          'انقر على زر + في الأسفل',
          'اكتب اسم الكليون (لازم)',
          'اكتب نمرة التليفون (اختياري)',
          'انقر على زر احفظ',
          'الكليون يظهر في اللستة',
        ],
        'section3Title': 'زيد كريدي (دين)',
        'section3Content': 'سجل كي الكليون يشري حوايج بالكريدي.',
        'section3Steps': [
          'اختار كليون من اللستة',
          'انقر على زر "زيد كريدي"',
          'اكتب المبلغ',
          'اختار الحوايج (اختياري)',
          'زيد نوتة (اختياري)',
          'انقر على احفظ',
        ],
        'section4Title': 'زيد خلاص',
        'section4Content': 'سجل خلاصات الكليان باش ينقص الدين متاعهم.',
        'section4Steps': [
          'اختار كليون من اللستة',
          'انقر على زر "زيد خلاص"',
          'اكتب مبلغ الخلاص',
          'للخلاص الزايد: فعل "اسمح بالخلاص الزايد"',
          'زيد نوتة (اختياري)',
          'انقر على احفظ',
        ],
        'section5Title': 'سيستام الباقي',
        'section5Content': 'كي الكليون يخلص أكثر من الدين متاعو، المبلغ الزايد يولي باقي.',
        'section5Info': 'الباقي ينقص أوتوماتيكيا من الدين الجاي. ما تحتاجش تتبع الخلاصات الزايدة يدويا. الكليان ينجمو يستعملو الباقي متاعهم للشراءات الجاية.',
      },
    };
    
    return content[language] ?? content['en']!;
  }
}
