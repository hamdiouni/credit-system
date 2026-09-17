# Maintenance Guide 🔧

## Quick Reference for Common Tasks

---

## Adding a New Language

### Step 1: Add Translations
Edit `lib/generated/app_localizations.dart`:

```dart
// Add to translations map
'newLang': {
  'appTitle': 'Your Translation',
  'customers': 'Your Translation',
  // ... add all keys
}
```

### Step 2: Update Delegate
```dart
@override
bool isSupported(Locale locale) {
  return ['en', 'ar', 'fr', 'newLang'].contains(locale.languageCode);
}
```

### Step 3: Add to Settings
Edit `lib/presentation/screens/settings_screen.dart`:

```dart
DropdownMenuItem(
  value: 'newLang',
  child: Text('Language Name'),
),
```

### Step 4: Test
1. Run app
2. Go to Settings
3. Select new language
4. Verify all text translates

---

## Adding a New Localization Key

### Step 1: Add Getter
Edit `lib/generated/app_localizations.dart`:

```dart
String get newKey => _translate('newKey');
```

### Step 2: Add Translations
```dart
'en': {
  // ... existing keys
  'newKey': 'English Text',
},
'ar': {
  // ... existing keys
  'newKey': 'النص العربي',
},
'fr': {
  // ... existing keys
  'newKey': 'Texte français',
}
```

### Step 3: Use in UI
```dart
Text(l10n.newKey)
```

---

## Updating Date Format

### Centralized Location
Edit `lib/utils/date_formatter.dart`:

```dart
static String formatDate(DateTime date, String locale) {
  // Change format here
  return DateFormat.yMd(locale).format(date);
}
```

### Available Formats
- `yMd` - 1/15/2024
- `yMMMd` - Jan 15, 2024
- `yMMMMd` - January 15, 2024
- `Hm` - 14:30
- `jm` - 2:30 PM

---

## Changing Currency

### Step 1: Update Localization
Edit `lib/generated/app_localizations.dart`:

```dart
'en': {
  'currency': 'USD', // Change from TND
}
```

### Step 2: Update Formatter
Edit `lib/utils/currency_formatter.dart` if needed.

### Step 3: Update PDF Services
Check `lib/services/pdf_export_service.dart` and `lib/services/html_arabic_pdf.dart`.

---

## Adding a New Transaction Type

### Step 1: Update Enum
Edit `lib/domain/models/transaction.dart`:

```dart
enum TransactionType {
  CREDIT,
  PAYMENT,
  BALANCE_CREDIT,
  NEW_TYPE, // Add here
}
```

### Step 2: Update Debt Calculator
Edit `lib/domain/services/debt_calculator_service.dart`:

```dart
if (txn.type == TransactionType.NEW_TYPE) {
  // Handle new type
}
```

### Step 3: Update UI
Add handling in screens:
- `customer_detail_screen.dart`
- `customer_list_screen.dart`

### Step 4: Update MongoDB Schema
Edit `server.js` and `server.cjs`:

```javascript
type: {
  type: String,
  enum: ['credit', 'payment', 'balance_credit', 'new_type'],
  required: true
}
```

### Step 5: Restart Server
```bash
node server.js
```

---

## Adding a New Grocery Item

### Step 1: Add to Default Items
Edit `lib/domain/models/grocery_item.dart`:

```dart
static final List<GroceryItem> defaultItems = [
  // ... existing items
  GroceryItem(key: 'newItem', label: 'New Item'),
];
```

### Step 2: Add Translations
Edit `lib/generated/app_localizations.dart`:

```dart
String get newItem => _translate('newItem');

// Add to translations
'en': { 'newItem': 'New Item' },
'ar': { 'newItem': 'عنصر جديد' },
'fr': { 'newItem': 'Nouvel article' },
```

### Step 3: Update PDF Services
Add to `_getLocalizedItemLabel` in:
- `lib/services/pdf_export_service.dart`
- `lib/services/html_arabic_pdf.dart`

```dart
case 'newItem':
  return language == 'fr' ? 'Nouvel article' 
       : language == 'ar' ? 'عنصر جديد' 
       : 'New Item';
```

---

## Modifying Empty States

### Customer List Empty State
Edit `lib/presentation/screens/customer_list_screen.dart`:

```dart
Icon(
  Icons.your_icon, // Change icon
  size: 80,
  color: Colors.grey.shade300,
),
Text(
  'Your message', // Change message
  style: TextStyle(fontSize: 18),
),
```

### Transaction Empty State
Edit `lib/presentation/screens/customer_detail_screen.dart`:

```dart
Icon(
  Icons.your_icon, // Change icon
  size: 64,
  color: Colors.grey.shade300,
),
```

---

## Customizing Success/Error Messages

### Success Message Template
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text('Your message')),
      ],
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);
```

### Error Message Template
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text('Your error message')),
      ],
    ),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 4),
  ),
);
```

### Warning Message Template
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(
      children: [
        const Icon(Icons.warning_amber, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text('Your warning message')),
      ],
    ),
    backgroundColor: Colors.orange,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 4),
  ),
);
```

---

## Database Maintenance

### Backup Database
```bash
# MongoDB backup
mongodump --db credit_app --out /backup/path

# Restore
mongorestore --db credit_app /backup/path/credit_app
```

### Clear Test Data
```javascript
// In MongoDB shell
use credit_app
db.customers.deleteMany({})
db.transactions.deleteMany({})
```

### Check Database Size
```javascript
db.stats()
```

---

## Performance Optimization

### Check for Memory Leaks
```dart
// Add to main.dart for debugging
void main() {
  debugPrintBeginFrameBanner = true;
  debugPrintEndFrameBanner = true;
  runApp(MyApp());
}
```

### Optimize Images
- Use appropriate image sizes
- Compress images before adding to assets
- Use cached network images

### Optimize Queries
- Add indexes to MongoDB collections
- Limit query results
- Use pagination for large lists

---

## Troubleshooting

### App Won't Start
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart IDE
4. Run `flutter run`

### Localization Not Working
1. Check `app_localizations.dart` for typos
2. Verify all languages have the key
3. Restart app (hot reload may not work)

### PDF Export Fails
1. Check browser console for errors
2. Verify MongoDB server is running
3. Check network tab for API errors
4. Verify customer has transactions

### Balance Credit Not Showing
1. Verify overpayment checkbox was checked
2. Verify payment amount > debt
3. Check transaction type in database
4. Restart app

### MongoDB Connection Error
1. Verify MongoDB is running: `mongod --version`
2. Check connection string in server.js
3. Verify port 27017 is not blocked
4. Check MongoDB logs

---

## Code Style Guidelines

### Naming Conventions
- Classes: `PascalCase`
- Variables: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Files: `snake_case.dart`

### File Organization
```
lib/
├── config/          # Configuration files
├── data/            # Data layer (DAO, repositories)
├── domain/          # Business logic (models, services)
├── presentation/    # UI layer (screens, widgets)
├── providers/       # State management
├── services/        # External services (PDF, etc)
├── utils/           # Utilities (formatters, etc)
└── generated/       # Generated files (localization)
```

### Import Order
1. Dart imports
2. Flutter imports
3. Package imports
4. Relative imports

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/customer.dart';
```

---

## Testing Guidelines

### Unit Tests
```dart
// test/unit/debt_calculator_test.dart
test('calculates debt correctly', () {
  final calculator = DebtCalculatorService();
  final result = calculator.calculateDebt(transactions);
  expect(result, equals(100.0));
});
```

### Widget Tests
```dart
// test/widget/customer_list_test.dart
testWidgets('shows empty state', (tester) async {
  await tester.pumpWidget(CustomerListScreen());
  expect(find.text('No customers yet'), findsOneWidget);
});
```

### Integration Tests
```dart
// integration_test/app_test.dart
testWidgets('full user flow', (tester) async {
  // Test complete user journey
});
```

---

## Security Best Practices

### Input Validation
- Always validate user input
- Sanitize data before database operations
- Use parameterized queries

### Authentication (Future)
- Use secure password hashing (bcrypt)
- Implement JWT tokens
- Use HTTPS in production

### Data Protection
- Don't log sensitive data
- Encrypt sensitive data at rest
- Use environment variables for secrets

---

## Monitoring & Logging

### Add Logging
```dart
import 'package:flutter/foundation.dart';

debugPrint('🔍 [ClassName] Message: $data');
```

### Log Levels
- 🔍 Debug: Development info
- ℹ️ Info: General information
- ⚠️ Warning: Potential issues
- ❌ Error: Actual errors

### Production Logging
- Use logging package
- Send logs to monitoring service
- Don't log sensitive data

---

## Version Control

### Commit Message Format
```
type(scope): subject

body

footer
```

### Types
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance

### Example
```
feat(payment): add overpayment support

- Added checkbox for overpayment
- Split payment into payment + balance credit
- Updated UI to show balance credit

Closes #123
```

---

## Getting Help

### Resources
- Flutter Docs: https://flutter.dev/docs
- Provider Docs: https://pub.dev/packages/provider
- MongoDB Docs: https://docs.mongodb.com

### Community
- Flutter Discord
- Stack Overflow
- GitHub Issues

---

**Last Updated**: February 1, 2026
