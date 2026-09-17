import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/localization_provider.dart';
import '../../services/simple_documentation_pdf.dart';

class HelpDocumentationScreen extends StatelessWidget {
  const HelpDocumentationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocalizationProvider>(context).languageCode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('title', locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: _getText('exportPdf', locale),
            onPressed: () => _exportDocumentation(context, locale),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              _getText('gettingStarted', locale),
              _getText('gettingStartedContent', locale),
              Icons.rocket_launch,
            ),
            _buildDiagram(context, 'workflow', locale),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              _getText('addCustomer', locale),
              _getText('addCustomerContent', locale),
              Icons.person_add,
            ),
            _buildDiagram(context, 'add_customer', locale),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              _getText('addCredit', locale),
              _getText('addCreditContent', locale),
              Icons.add_shopping_cart,
            ),
            _buildDiagram(context, 'add_credit', locale),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              _getText('addPayment', locale),
              _getText('addPaymentContent', locale),
              Icons.payment,
            ),
            _buildDiagram(context, 'add_payment', locale),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              _getText('balanceCredit', locale),
              _getText('balanceCreditContent', locale),
              Icons.account_balance_wallet,
            ),
            _buildDiagram(context, 'balance_credit', locale),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              _getText('exportData', locale),
              _getText('exportDataContent', locale),
              Icons.file_download,
            ),
            
            _buildSection(
              context,
              _getText('backup', locale),
              _getText('backupContent', locale),
              Icons.backup,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagram(BuildContext context, String type, String locale) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: _getDiagramSteps(type, locale),
      ),
    );
  }

  List<Widget> _getDiagramSteps(String type, String locale) {
    final steps = _getSteps(type, locale);
    final widgets = <Widget>[];
    
    for (int i = 0; i < steps.length; i++) {
      widgets.add(
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${i + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                steps[i],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
      
      if (i < steps.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            child: Container(
              width: 2,
              height: 20,
              color: Colors.blue.shade300,
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  List<String> _getSteps(String type, String locale) {
    final steps = {
      'workflow': {
        'en': [
          'Open app and login with PIN',
          'View customer list',
          'Select customer or add new one',
          'Add credit (debt) or payment',
          'View updated balance',
        ],
        'ar': [
          'افتح التطبيق وسجل الدخول بالرمز',
          'عرض قائمة العملاء',
          'اختر عميل أو أضف جديد',
          'أضف رصيد (دين) أو دفعة',
          'عرض الرصيد المحدث',
        ],
        'fr': [
          'Ouvrir l\'app et se connecter avec PIN',
          'Voir la liste des clients',
          'Sélectionner un client ou en ajouter un nouveau',
          'Ajouter crédit (dette) ou paiement',
          'Voir le solde mis à jour',
        ],
        'tn': [
          'احلل الأبليكاسيون و دخل بالكود',
          'شوف لستة متع الكليان',
          'اختار كليون ولا زيد واحد جديد',
          'زيد كريدي (دين) ولا خلاص',
          'شوف الباقي المحدث',
        ],
      },
      'add_customer': {
        'en': [
          'Click + button',
          'Enter customer name',
          'Enter phone number (optional)',
          'Click Save',
          'Customer added to list',
        ],
        'ar': [
          'انقر على زر +',
          'أدخل اسم العميل',
          'أدخل رقم الهاتف (اختياري)',
          'انقر على حفظ',
          'تمت إضافة العميل إلى القائمة',
        ],
        'fr': [
          'Cliquer sur le bouton +',
          'Entrer le nom du client',
          'Entrer le numéro de téléphone (optionnel)',
          'Cliquer sur Enregistrer',
          'Client ajouté à la liste',
        ],
        'tn': [
          'انقر على زر +',
          'اكتب اسم الكليون',
          'اكتب نمرة التليفون (اختياري)',
          'انقر على احفظ',
          'الكليون تزاد في اللستة',
        ],
      },
      'add_credit': {
        'en': [
          'Open customer detail',
          'Click "Add Credit"',
          'Enter amount',
          'Select grocery items (optional)',
          'Add note (optional)',
          'Click Save',
        ],
        'ar': [
          'افتح تفاصيل العميل',
          'انقر على "إضافة رصيد"',
          'أدخل المبلغ',
          'اختر عناصر البقالة (اختياري)',
          'أضف ملاحظة (اختياري)',
          'انقر على حفظ',
        ],
        'fr': [
          'Ouvrir les détails du client',
          'Cliquer sur "Ajouter un Crédit"',
          'Entrer le montant',
          'Sélectionner les articles (optionnel)',
          'Ajouter une note (optionnel)',
          'Cliquer sur Enregistrer',
        ],
        'tn': [
          'احلل تفاصيل الكليون',
          'انقر على "زيد كريدي"',
          'اكتب المبلغ',
          'اختار الحوايج (اختياري)',
          'زيد نوتة (اختياري)',
          'انقر على احفظ',
        ],
      },
      'add_payment': {
        'en': [
          'Open customer detail',
          'Click "Add Payment"',
          'Enter payment amount',
          'For overpayment: Check "Allow Overpayment"',
          'Add note (optional)',
          'Click Save',
        ],
        'ar': [
          'افتح تفاصيل العميل',
          'انقر على "إضافة دفعة"',
          'أدخل مبلغ الدفع',
          'للدفع الزائد: فعّل "السماح بالدفع الزائد"',
          'أضف ملاحظة (اختياري)',
          'انقر على حفظ',
        ],
        'fr': [
          'Ouvrir les détails du client',
          'Cliquer sur "Ajouter un Paiement"',
          'Entrer le montant du paiement',
          'Pour trop-payé: Cocher "Autoriser le trop-payé"',
          'Ajouter une note (optionnel)',
          'Cliquer sur Enregistrer',
        ],
        'tn': [
          'احلل تفاصيل الكليون',
          'انقر على "زيد خلاص"',
          'اكتب مبلغ الخلاص',
          'للخلاص الزايد: فعّل "اسمح بالخلاص الزايد"',
          'زيد نوتة (اختياري)',
          'انقر على احفظ',
        ],
      },
      'balance_credit': {
        'en': [
          'Customer pays more than debt',
          'Check "Allow Overpayment" checkbox',
          'Confirm overpayment',
          'Balance credit created automatically',
          'Balance reduces future debt automatically',
        ],
        'ar': [
          'العميل يدفع أكثر من الدين',
          'فعّل خانة "السماح بالدفع الزائد"',
          'تأكيد الدفع الزائد',
          'يتم إنشاء رصيد الرصيد تلقائيًا',
          'الرصيد يقلل الدين المستقبلي تلقائيًا',
        ],
        'fr': [
          'Le client paie plus que la dette',
          'Cocher "Autoriser le trop-payé"',
          'Confirmer le trop-payé',
          'Crédit de solde créé automatiquement',
          'Le solde réduit la dette future automatiquement',
        ],
        'tn': [
          'الكليون يخلص أكثر من الدين',
          'فعّل "اسمح بالخلاص الزايد"',
          'أكد الخلاص الزايد',
          'الباقي يتصنع أوتوماتيكيًا',
          'الباقي ينقص الدين الجاي أوتوماتيكيًا',
        ],
      },
    };
    
    return steps[type]?[locale] ?? steps[type]?['en'] ?? [];
  }

  Future<void> _exportDocumentation(BuildContext context, String locale) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getText('generatingPdf', locale)),
          duration: const Duration(seconds: 2),
        ),
      );
      
      await SimpleDocumentationPdf.generate(locale);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(_getText('pdfExported', locale))),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getText('error', locale)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getText(String key, String locale) {
    final texts = {
      'title': {
        'en': 'Help & Documentation',
        'ar': 'المساعدة والتوثيق',
        'fr': 'Aide & Documentation',
        'tn': 'المساعدة والتوثيق',
      },
      'exportPdf': {
        'en': 'Export PDF',
        'ar': 'تصدير PDF',
        'fr': 'Exporter PDF',
        'tn': 'اكسبورتي PDF',
      },
      'gettingStarted': {
        'en': 'Getting Started',
        'ar': 'البدء',
        'fr': 'Commencer',
        'tn': 'البداية',
      },
      'gettingStartedContent': {
        'en': 'Welcome to Credit System! This app helps you manage customer credit and payments easily. Follow the workflow below to get started.',
        'ar': 'مرحبًا بك في نظام الائتمان! يساعدك هذا التطبيق على إدارة ائتمان العملاء والمدفوعات بسهولة. اتبع سير العمل أدناه للبدء.',
        'fr': 'Bienvenue dans le Système de Crédit! Cette application vous aide à gérer facilement le crédit et les paiements des clients. Suivez le flux de travail ci-dessous pour commencer.',
        'tn': 'مرحبا بيك في سيستام الكريدي! هذا الأبليكاسيون يعاونك باش تجستيوني الكريدي متع الكليان والخلاصات بسهولة. اتبع الخطوات لتحت باش تبدا.',
      },
      'addCustomer': {
        'en': 'Add Customer',
        'ar': 'إضافة عميل',
        'fr': 'Ajouter un Client',
        'tn': 'زيد كليون',
      },
      'addCustomerContent': {
        'en': 'Add new customers to track their credit and payments. You can add their name and phone number for easy identification.',
        'ar': 'أضف عملاء جدد لتتبع ائتمانهم ومدفوعاتهم. يمكنك إضافة اسمهم ورقم هاتفهم لسهولة التعريف.',
        'fr': 'Ajoutez de nouveaux clients pour suivre leur crédit et leurs paiements. Vous pouvez ajouter leur nom et numéro de téléphone pour une identification facile.',
        'tn': 'زيد كليان جداد باش تتبع الكريدي والخلاصات متاعهم. تنجم تزيد اسمهم ونمرة التليفون باش تعرفهم بسهولة.',
      },
      'addCredit': {
        'en': 'Add Credit (Debt)',
        'ar': 'إضافة رصيد (دين)',
        'fr': 'Ajouter un Crédit (Dette)',
        'tn': 'زيد كريدي (دين)',
      },
      'addCreditContent': {
        'en': 'Record when a customer buys items on credit. You can select grocery items and add notes for reference.',
        'ar': 'سجل عندما يشتري العميل عناصر بالائتمان. يمكنك اختيار عناصر البقالة وإضافة ملاحظات للرجوع إليها.',
        'fr': 'Enregistrez lorsqu\'un client achète des articles à crédit. Vous pouvez sélectionner des articles d\'épicerie et ajouter des notes pour référence.',
        'tn': 'سجل كي الكليون يشري حوايج بالكريدي. تنجم تختار الحوايج وتزيد نوتات للرجوع.',
      },
      'addPayment': {
        'en': 'Add Payment',
        'ar': 'إضافة دفعة',
        'fr': 'Ajouter un Paiement',
        'tn': 'زيد خلاص',
      },
      'addPaymentContent': {
        'en': 'Record customer payments. If payment exceeds debt, enable "Allow Overpayment" to create balance credit.',
        'ar': 'سجل مدفوعات العملاء. إذا تجاوز الدفع الدين، فعّل "السماح بالدفع الزائد" لإنشاء رصيد الرصيد.',
        'fr': 'Enregistrez les paiements des clients. Si le paiement dépasse la dette, activez "Autoriser le trop-payé" pour créer un crédit de solde.',
        'tn': 'سجل خلاصات الكليان. كان الخلاص أكثر من الدين، فعّل "اسمح بالخلاص الزايد" باش تصنع باقي.',
      },
      'balanceCredit': {
        'en': 'Balance Credit System',
        'ar': 'نظام رصيد الرصيد',
        'fr': 'Système de Crédit de Solde',
        'tn': 'سيستام الباقي',
      },
      'balanceCreditContent': {
        'en': 'When customers overpay, the extra amount becomes balance credit. This balance automatically reduces their next debt.',
        'ar': 'عندما يدفع العملاء أكثر من اللازم، يصبح المبلغ الإضافي رصيد رصيد. يقلل هذا الرصيد تلقائيًا من ديونهم التالية.',
        'fr': 'Lorsque les clients paient trop, le montant supplémentaire devient un crédit de solde. Ce solde réduit automatiquement leur prochaine dette.',
        'tn': 'كي الكليان يخلص أكثر، المبلغ الزايد يولي باقي. هذا الباقي ينقص أوتوماتيكيًا من الدين الجاي.',
      },
      'exportData': {
        'en': 'Export Data',
        'ar': 'تصدير البيانات',
        'fr': 'Exporter les Données',
        'tn': 'اكسبورتي البيانات',
      },
      'exportDataContent': {
        'en': 'Export customer reports as PDF or CSV. PDFs include all transaction details in your selected language.',
        'ar': 'صدّر تقارير العملاء بصيغة PDF أو CSV. تتضمن ملفات PDF جميع تفاصيل المعاملات باللغة المحددة.',
        'fr': 'Exportez les rapports clients en PDF ou CSV. Les PDF incluent tous les détails des transactions dans votre langue sélectionnée.',
        'tn': 'اكسبورتي تقارير الكليان كيما PDF ولا CSV. الPDF فيه كل تفاصيل المعاملات باللغة اللي اخترتها.',
      },
      'backup': {
        'en': 'Backup & Restore',
        'ar': 'النسخ الاحتياطي والاستعادة',
        'fr': 'Sauvegarde & Restauration',
        'tn': 'الباكاب والريستور',
      },
      'backupContent': {
        'en': 'Create backups of all your data. Download backup files to your device for safekeeping.',
        'ar': 'أنشئ نسخًا احتياطية من جميع بياناتك. قم بتنزيل ملفات النسخ الاحتياطي على جهازك للحفظ الآمن.',
        'fr': 'Créez des sauvegardes de toutes vos données. Téléchargez les fichiers de sauvegarde sur votre appareil pour les conserver en sécurité.',
        'tn': 'اصنع باكاب لكل البيانات متاعك. نزّل ملفات الباكاب على الجهاز متاعك باش تحفظهم.',
      },
      'generatingPdf': {
        'en': 'Generating PDF...',
        'ar': 'جاري إنشاء PDF...',
        'fr': 'Génération du PDF...',
        'tn': 'قاعد نصنع PDF...',
      },
      'pdfExported': {
        'en': 'Documentation exported successfully',
        'ar': 'تم تصدير التوثيق بنجاح',
        'fr': 'Documentation exportée avec succès',
        'tn': 'التوثيق تاكسبورتا بنجاح',
      },
      'error': {
        'en': 'Error',
        'ar': 'خطأ',
        'fr': 'Erreur',
        'tn': 'غلطة',
      },
    };
    
    return texts[key]?[locale] ?? texts[key]?['en'] ?? key;
  }
}
