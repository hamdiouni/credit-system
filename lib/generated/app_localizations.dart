import 'dart:async';
import 'package:flutter/material.dart';

// ignore_for_file: non_constant_identifier_names

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  static const AppLocalizationsDelegate delegate = AppLocalizationsDelegate();

  String get appTitle => _translate('appTitle');
  String get customers => _translate('customers');
  String get addCustomer => _translate('addCustomer');
  String get addCredit => _translate('addCredit');
  String get addPayment => _translate('addPayment');
  String get customerName => _translate('customerName');
  String get phone => _translate('phone');
  String get balance => _translate('balance');
  String get amount => _translate('amount');
  String get date => _translate('date');
  String get notes => _translate('notes');
  String get search => _translate('search');
  String get noCustomers => _translate('noCustomers');
  String get noTransactions => _translate('noTransactions');
  String get deleteCustomer => _translate('deleteCustomer');
  String get deleteCustomerWarning => _translate('deleteCustomerWarning');
  String get confirmDelete => _translate('confirmDelete');
  String get yes => _translate('yes');
  String get no => _translate('no');
  String get success => _translate('success');
  String get error => _translate('error');
  String get back => _translate('back');
  String get save => _translate('save');
  String get cancel => _translate('cancel');
  String get selectItems => _translate('selectItems');
  String get sugar => _translate('sugar');
  String get milk => _translate('milk');
  String get oil => _translate('oil');
  String get rice => _translate('rice');
  String get flour => _translate('flour');
  String get tea => _translate('tea');
  String get coffee => _translate('coffee');
  String get butter => _translate('butter');
  String get cheese => _translate('cheese');
  String get eggs => _translate('eggs');
  String get salt => _translate('salt');
  String get detergent => _translate('detergent');
  String get soap => _translate('soap');
  String get chocolate => _translate('chocolate');
  String get biscuits => _translate('biscuits');
  String get tomato => _translate('tomato');
  String get onion => _translate('onion');
  String get potato => _translate('potato');
  String get bread => _translate('bread');
  String get optionalComment => _translate('optionalComment');
  String get creditAdded => _translate('creditAdded');
  String get paymentAdded => _translate('paymentAdded');
  String get customerAdded => _translate('customerAdded');
  String get phoneInUse => _translate('phoneInUse');
  String get language => _translate('language');
  String get arabic => _translate('arabic');
  String get french => _translate('french');
  String get english => _translate('english');
  String get settings => _translate('settings');
  String get credit => _translate('credit');
  String get payment => _translate('payment');
  String get transactions => _translate('transactions');
  String get customerDetails => _translate('customerDetails');
  String get paid => _translate('paid');
  String get createdDate => _translate('createdDate');
  String get items => _translate('items');
  String get allowOverpayment => _translate('allowOverpayment');
  String get allowOverpaymentSubtitle => _translate('allowOverpaymentSubtitle');
  String get balanceCreditLabel => _translate('balanceCreditLabel');
  String get balanceLabel => _translate('balanceLabel');
  String get exportingPdf => _translate('exportingPdf');
  String get exportPdf => _translate('exportPdf');
  String get customerNotFound => _translate('customerNotFound');
  String get quantity => _translate('quantity');

  String debt(String amount) => _translate('balance') + ': $amount';
  String selectedItems(int count) => _translate('selectedItems').replaceAll('{count}', count.toString());
  String paymentAddedWithBalance(String amount) => _translate('paymentAddedWithBalance').replaceAll('{amount}', amount);
  String overpaymentError(String payment, String debt) => _translate('overpaymentError').replaceAll('{payment}', payment).replaceAll('{debt}', debt);

  String _translate(String key) {
    final lang = locale.languageCode;
    
    final Map<String, Map<String, String>> translations = {
      'en': {
        'appTitle': 'Credit Manager',
        'customers': 'Customers',
        'addCustomer': 'Add Customer',
        'addCredit': 'Add Credit',
        'addPayment': 'Add Payment',
        'customerName': 'Customer Name',
        'phone': 'Phone',
        'balance': 'Remaining Debt',
        'amount': 'Amount',
        'date': 'Date',
        'notes': 'Notes',
        'search': 'Search customers...',
        'noCustomers': 'No customers yet',
        'noTransactions': 'No transactions yet',
        'deleteCustomer': 'Delete Customer',
        'deleteCustomerWarning': 'Customer has transactions. Cannot delete.',
        'confirmDelete': 'Are you sure?',
        'yes': 'Yes',
        'no': 'No',
        'success': 'Success',
        'error': 'Error',
        'back': 'Back',
        'save': 'Save',
        'cancel': 'Cancel',
        'selectItems': 'Select grocery items:',
        'sugar': 'Sugar',
        'milk': 'Milk',
        'oil': 'Oil',
        'rice': 'Rice',
        'flour': 'Flour',
        'tea': 'Tea',
        'coffee': 'Coffee',
        'butter': 'Butter',
        'cheese': 'Cheese',
        'eggs': 'Eggs',
        'salt': 'Salt',
        'detergent': 'Detergent',
        'soap': 'Soap',
        'chocolate': 'Chocolate',
        'biscuits': 'Biscuits',
        'tomato': 'Tomato',
        'onion': 'Onion',
        'potato': 'Potato',
        'bread': 'Bread',
        'optionalComment': 'Optional comment',
        'selectedItems': 'Selected items: {count}',
        'creditAdded': 'Credit added successfully',
        'paymentAdded': 'Payment added successfully',
        'customerAdded': 'Customer added successfully',
        'phoneInUse': 'Phone number already in use',
        'language': 'Language',
        'arabic': 'العربية',
        'french': 'Français',
        'english': 'English',
        'settings': 'Settings',
        'credit': 'Credit',
        'payment': 'Payment',
        'transactions': 'Transaction History',
        'customerDetails': 'Customer Details',
        'paid': 'Paid',
        'createdDate': 'Created',
        'items': 'Items',
        'allowOverpayment': 'Allow Overpayment',
        'allowOverpaymentSubtitle': 'Keep extra payment as balance credit',
        'balanceCreditLabel': 'Balance Credit',
        'balanceLabel': 'Balance',
        'exportingPdf': 'Exporting...',
        'exportPdf': 'Export PDF',
        'paymentAddedWithBalance': 'Payment added. Balance credit: {amount} TND',
        'overpaymentError': 'Payment ({payment} TND) exceeds current debt ({debt} TND). Enable \'Allow Overpayment\' to continue.',
        'customerNotFound': 'Customer not found',
        'quantity': 'Qty',
      },
      'ar': {
        'appTitle': 'مدير الائتمان',
        'customers': 'العملاء',
        'addCustomer': 'إضافة عميل',
        'addCredit': 'إضافة ائتمان',
        'addPayment': 'إضافة دفعة',
        'customerName': 'اسم العميل',
        'phone': 'رقم الهاتف',
        'balance': 'الدين المتبقي',
        'amount': 'المبلغ',
        'date': 'التاريخ',
        'notes': 'ملاحظات',
        'search': 'ابحث عن العملاء...',
        'noCustomers': 'لا توجد عملاء حتى الآن',
        'noTransactions': 'لا توجد معاملات حتى الآن',
        'deleteCustomer': 'حذف العميل',
        'deleteCustomerWarning': 'العميل لديه معاملات. لا يمكن الحذف.',
        'confirmDelete': 'هل أنت متأكد؟',
        'yes': 'نعم',
        'no': 'لا',
        'success': 'نجاح',
        'error': 'خطأ',
        'back': 'رجوع',
        'save': 'حفظ',
        'cancel': 'إلغاء',
        'selectItems': 'اختر عناصر البقالة:',
        'sugar': 'سكر',
        'milk': 'حليب',
        'oil': 'زيت',
        'rice': 'أرز',
        'flour': 'دقيق',
        'tea': 'شاي',
        'coffee': 'قهوة',
        'butter': 'زبدة',
        'cheese': 'جبن',
        'eggs': 'بيض',
        'salt': 'ملح',
        'detergent': 'منظف',
        'soap': 'صابون',
        'chocolate': 'شكولاتة',
        'biscuits': 'بسكويت',
        'tomato': 'طماطم',
        'onion': 'بصل',
        'potato': 'بطاطا',
        'bread': 'خبز',
        'optionalComment': 'تعليق اختياري',
        'selectedItems': 'العناصر المختارة: {count}',
        'creditAdded': 'تم إضافة الائتمان بنجاح',
        'paymentAdded': 'تمت إضافة الدفعة بنجاح',
        'customerAdded': 'تم إضافة العميل بنجاح',
        'phoneInUse': 'رقم الهاتف مستخدم بالفعل',
        'language': 'اللغة',
        'arabic': 'العربية',
        'french': 'Français',
        'english': 'English',
        'settings': 'الإعدادات',
        'credit': 'رصيد',
        'payment': 'دفعة',
        'transactions': 'سجل العمليات',
        'customerDetails': 'تفاصيل العميل',
        'paid': 'مدفوع',
        'createdDate': 'تاريخ الإنشاء',
        'items': 'العناصر',
        'allowOverpayment': 'السماح بالدفع الزائد',
        'allowOverpaymentSubtitle': 'الاحتفاظ بالدفع الزائد كرصيد',
        'balanceCreditLabel': 'رصيد الرصيد',
        'balanceLabel': 'الرصيد',
        'exportingPdf': 'جاري التصدير...',
        'exportPdf': 'تصدير PDF',
        'paymentAddedWithBalance': 'تمت إضافة الدفعة. رصيد الرصيد: {amount} TND',
        'overpaymentError': 'الدفعة ({payment} TND) تتجاوز الدين الحالي ({debt} TND). قم بتفعيل \'السماح بالدفع الزائد\' للمتابعة.',
        'customerNotFound': 'العميل غير موجود',
        'quantity': 'الكمية',
      },
      'fr': {
        'appTitle': 'Gestionnaire de Crédit',
        'customers': 'Clients',
        'addCustomer': 'Ajouter un client',
        'addCredit': 'Ajouter un crédit',
        'addPayment': 'Ajouter un paiement',
        'customerName': 'Nom du client',
        'phone': 'Téléphone',
        'balance': 'Dette restante',
        'amount': 'Montant',
        'date': 'Date',
        'notes': 'Notes',
        'search': 'Rechercher les clients...',
        'noCustomers': 'Aucun client pour le moment',
        'noTransactions': 'Pas de transactions pour le moment',
        'deleteCustomer': 'Supprimer le client',
        'deleteCustomerWarning': 'Le client a des transactions. Impossible de supprimer.',
        'confirmDelete': 'Êtes-vous sûr?',
        'yes': 'Oui',
        'no': 'Non',
        'success': 'Succès',
        'error': 'Erreur',
        'back': 'Retour',
        'save': 'Enregistrer',
        'cancel': 'Annuler',
        'selectItems': 'Sélectionner les articles d\'épicerie:',
        'sugar': 'Sucre',
        'milk': 'Lait',
        'oil': 'Huile',
        'rice': 'Riz',
        'flour': 'Farine',
        'tea': 'Thé',
        'coffee': 'Café',
        'butter': 'Beurre',
        'cheese': 'Fromage',
        'eggs': 'Œufs',
        'salt': 'Sel',
        'detergent': 'Détergent',
        'soap': 'Savon',
        'chocolate': 'Chocolat',
        'biscuits': 'Biscuits',
        'tomato': 'Tomate',
        'onion': 'Oignon',
        'potato': 'Pomme de terre',
        'bread': 'Pain',
        'optionalComment': 'Commentaire facultatif',
        'selectedItems': 'Articles sélectionnés: {count}',
        'creditAdded': 'Crédit ajouté avec succès',
        'paymentAdded': 'Paiement ajouté avec succès',
        'customerAdded': 'Client ajouté avec succès',
        'phoneInUse': 'Numéro de téléphone déjà utilisé',
        'language': 'Langue',
        'arabic': 'العربية',
        'french': 'Français',
        'english': 'English',
        'settings': 'Paramètres',
        'credit': 'Crédit',
        'payment': 'Paiement',
        'transactions': 'Historique des transactions',
        'customerDetails': 'Détails du client',
        'paid': 'Payé',
        'createdDate': 'Créé',
        'items': 'Articles',
        'allowOverpayment': 'Autoriser le trop-payé',
        'allowOverpaymentSubtitle': 'Conserver le trop-payé comme crédit de solde',
        'balanceCreditLabel': 'Crédit de Solde',
        'balanceLabel': 'Solde',
        'exportingPdf': 'Exportation...',
        'exportPdf': 'Exporter PDF',
        'paymentAddedWithBalance': 'Paiement ajouté. Crédit de solde: {amount} TND',
        'overpaymentError': 'Le paiement ({payment} TND) dépasse la dette actuelle ({debt} TND). Activez \'Autoriser le trop-payé\' pour continuer.',
        'customerNotFound': 'Client introuvable',
        'quantity': 'Qté',
      },
      'tn': {
        'appTitle': 'برنامج الدين',
        'customers': 'الزباين',
        'addCustomer': 'زيد زبون',
        'addCredit': 'زيد دين',
        'addPayment': 'زيد خلاص',
        'customerName': 'اسم الزبون',
        'phone': 'نمرة التليفون',
        'balance': 'الباقي',
        'amount': 'المبلغ',
        'date': 'التاريخ',
        'notes': 'ملاحظات',
        'search': 'قلب على الزباين...',
        'noCustomers': 'ما عندكش زباين باهي',
        'noTransactions': 'ما عندكش معاملات باهي',
        'deleteCustomer': 'فسخ الزبون',
        'deleteCustomerWarning': 'الزبون عندو معاملات. ما تنجمش تفسخو.',
        'confirmDelete': 'انت متأكد؟',
        'yes': 'إي',
        'no': 'لا',
        'success': 'نجح',
        'error': 'غلطة',
        'back': 'ارجع',
        'save': 'سجل',
        'cancel': 'الغي',
        'selectItems': 'اختار الحوايج:',
        'sugar': 'سكر',
        'milk': 'حليب',
        'oil': 'زيت',
        'rice': 'روز',
        'flour': 'فرينة',
        'tea': 'أتاي',
        'coffee': 'قهوة',
        'butter': 'زبدة',
        'cheese': 'جبن',
        'eggs': 'بيض',
        'salt': 'ملح',
        'detergent': 'صابون غسيل',
        'soap': 'صابون',
        'chocolate': 'شكلاطة',
        'biscuits': 'بسكوي',
        'tomato': 'طماطم',
        'onion': 'بصلة',
        'potato': 'بطاطا',
        'bread': 'خبز',
        'optionalComment': 'تعليق اختياري',
        'selectedItems': 'الحوايج المختارة: {count}',
        'creditAdded': 'تزاد الدين بالنجاح',
        'paymentAdded': 'تزاد الخلاص بالنجاح',
        'customerAdded': 'تزاد الزبون بالنجاح',
        'phoneInUse': 'النمرة مستعملة',
        'language': 'اللغة',
        'arabic': 'العربية',
        'french': 'Français',
        'english': 'English',
        'settings': 'الإعدادات',
        'credit': 'دين',
        'payment': 'خلاص',
        'transactions': 'سجل المعاملات',
        'customerDetails': 'تفاصيل الزبون',
        'paid': 'مخلص',
        'createdDate': 'تاريخ الإنشاء',
        'items': 'الحوايج',
        'allowOverpayment': 'اسمح بالخلاص الزايد',
        'allowOverpaymentSubtitle': 'احفظ الخلاص الزايد كرصيد',
        'balanceCreditLabel': 'رصيد الرصيد',
        'balanceLabel': 'الرصيد',
        'exportingPdf': 'قاعد يصدر...',
        'exportPdf': 'صدر PDF',
        'paymentAddedWithBalance': 'تزاد الخلاص. رصيد الرصيد: {amount} دينار',
        'overpaymentError': 'الخلاص ({payment} دينار) أكثر من الدين ({debt} دينار). فعل \'اسمح بالخلاص الزايد\' باش تكمل.',
        'customerNotFound': 'الزبون ما لقيناهش',
        'quantity': 'الكمية',
      }
    };

    return translations[lang]?[key] ?? translations['en']?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr', 'tn'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
