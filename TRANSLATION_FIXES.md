# Translation Fixes - Quick Implementation Guide

## Files to Update

### 1. Add New Localization Keys

Add these keys to all three localization files:

#### `lib/l10n/app_en.arb`
```json
{
  "allowOverpayment": "Allow Overpayment",
  "allowOverpaymentSubtitle": "Keep extra payment as balance credit",
  "balanceCreditLabel": "Balance Credit",
  "balanceLabel": "Balance",
  "exportingPdf": "Exporting...",
  "exportPdf": "Export PDF",
  "paymentAddedWithBalance": "Payment added. Balance credit: {amount} TND",
  "@paymentAddedWithBalance": {
    "placeholders": {
      "amount": {
        "type": "String"
      }
    }
  },
  "overpaymentError": "Payment ({payment} TND) exceeds current debt ({debt} TND). Enable 'Allow Overpayment' to continue.",
  "@overpaymentError": {
    "placeholders": {
      "payment": {
        "type": "String"
      },
      "debt": {
        "type": "String"
      }
    }
  },
  "paid": "Paid",
  "createdDate": "Created"
}
```

#### `lib/l10n/app_ar.arb`
```json
{
  "allowOverpayment": "السماح بالدفع الزائد",
  "allowOverpaymentSubtitle": "الاحتفاظ بالدفع الزائد كرصيد",
  "balanceCreditLabel": "رصيد الرصيد",
  "balanceLabel": "الرصيد",
  "exportingPdf": "جاري التصدير...",
  "exportPdf": "تصدير PDF",
  "paymentAddedWithBalance": "تمت إضافة الدفعة. رصيد الرصيد: {amount} TND",
  "@paymentAddedWithBalance": {
    "placeholders": {
      "amount": {
        "type": "String"
      }
    }
  },
  "overpaymentError": "الدفعة ({payment} TND) تتجاوز الدين الحالي ({debt} TND). قم بتفعيل 'السماح بالدفع الزائد' للمتابعة.",
  "@overpaymentError": {
    "placeholders": {
      "payment": {
        "type": "String"
      },
      "debt": {
        "type": "String"
      }
    }
  },
  "paid": "مدفوع",
  "createdDate": "تاريخ الإنشاء"
}
```

#### `lib/l10n/app_fr.arb`
```json
{
  "allowOverpayment": "Autoriser le trop-payé",
  "allowOverpaymentSubtitle": "Conserver le trop-payé comme crédit de solde",
  "balanceCreditLabel": "Crédit de Solde",
  "balanceLabel": "Solde",
  "exportingPdf": "Exportation...",
  "exportPdf": "Exporter PDF",
  "paymentAddedWithBalance": "Paiement ajouté. Crédit de solde: {amount} TND",
  "@paymentAddedWithBalance": {
    "placeholders": {
      "amount": {
        "type": "String"
      }
    }
  },
  "overpaymentError": "Le paiement ({payment} TND) dépasse la dette actuelle ({debt} TND). Activez 'Autoriser le trop-payé' pour continuer.",
  "@overpaymentError": {
    "placeholders": {
      "payment": {
        "type": "String"
      },
      "debt": {
        "type": "String"
      }
    }
  },
  "paid": "Payé",
  "createdDate": "Date de création"
}
```

### 2. Update Code Files

#### `lib/presentation/screens/add_payment_screen.dart`

**Change 1** (Line 90-95):
```dart
// OLD
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Payment (${amount.toStringAsFixed(3)} TND) exceeds current debt (${currentDebt.toStringAsFixed(3)} TND). Enable "Allow Overpayment" to continue.'),

// NEW
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.overpaymentError
        .replaceAll('{payment}', amount.toStringAsFixed(3))
        .replaceAll('{debt}', currentDebt.toStringAsFixed(3))),
```

**Change 2** (Line 127):
```dart
// OLD
content: Text('Payment added. Balance credit: ${balanceAmount.toStringAsFixed(3)} TND'),

// NEW
content: Text(l10n.paymentAddedWithBalance
  .replaceAll('{amount}', balanceAmount.toStringAsFixed(3))),
```

**Change 3** (Line 221-223):
```dart
// OLD
CheckboxListTile(
  title: const Text('Allow Overpayment'),
  subtitle: const Text('Keep extra payment as balance credit'),

// NEW
CheckboxListTile(
  title: Text(l10n.allowOverpayment),
  subtitle: Text(l10n.allowOverpaymentSubtitle),
```

#### `lib/presentation/screens/customer_list_screen.dart`

**Change** (Line 130):
```dart
// OLD
Text(
  'Balance: ${balanceCredit.toStringAsFixed(2)}',

// NEW
Text(
  '${l10n.balanceLabel}: ${balanceCredit.toStringAsFixed(2)}',
```

#### `lib/presentation/screens/customer_detail_screen.dart`

**Change 1** (Line 104):
```dart
// OLD
Text(
  'Balance Credit',

// NEW
Text(
  l10n.balanceCreditLabel,
```

**Change 2** (Line 350):
```dart
// OLD
label: Text(_loading ? 'Exporting...' : 'Export PDF'),

// NEW
label: Text(_loading ? l10n.exportingPdf : l10n.exportPdf),
```

### 3. Run Code Generation

After updating the `.arb` files, run:

```bash
flutter pub get
flutter gen-l10n
```

Or if using intl_utils:

```bash
flutter pub run intl_utils:generate
```

### 4. Test All Languages

1. Run app
2. Switch to English - verify all text
3. Switch to Arabic - verify all text
4. Switch to French - verify all text

### 5. Verify These Screens

- [ ] Customer List - "Balance" label
- [ ] Customer Detail - "Balance Credit" label
- [ ] Customer Detail - "Export PDF" button
- [ ] Add Payment - "Allow Overpayment" checkbox
- [ ] Add Payment - Overpayment error message
- [ ] Add Payment - Success message with balance

## Quick Test Checklist

### English
- [ ] "Balance: XX.XX" on customer list
- [ ] "Balance Credit" on customer detail
- [ ] "Export PDF" button
- [ ] "Allow Overpayment" checkbox
- [ ] Error message shows correctly
- [ ] Success message shows correctly

### Arabic (العربية)
- [ ] "الرصيد: XX.XX" on customer list
- [ ] "رصيد الرصيد" on customer detail
- [ ] "تصدير PDF" button
- [ ] "السماح بالدفع الزائد" checkbox
- [ ] Error message in Arabic
- [ ] Success message in Arabic

### French (Français)
- [ ] "Solde: XX.XX" on customer list
- [ ] "Crédit de Solde" on customer detail
- [ ] "Exporter PDF" button
- [ ] "Autoriser le trop-payé" checkbox
- [ ] Error message in French
- [ ] Success message in French

## Estimated Time

- Adding localization keys: 10 minutes
- Updating code files: 15 minutes
- Running code generation: 2 minutes
- Testing all languages: 10 minutes

**Total: ~40 minutes**

## Notes

- Make sure to restart the app after code generation
- Test with actual overpayment scenarios
- Verify RTL layout for Arabic
- Check that placeholders work correctly
