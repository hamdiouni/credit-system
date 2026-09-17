# Quick Start Guide

## Project Overview

Your Flutter credit management application is now ready. Here's what's been implemented:

### ✅ Completed Components

1. **Database Layer**
   - SQLite database with schema for customers and transactions
   - Customer DAO and Transaction DAO
   - Repositories for data access

2. **Domain Logic**
   - Customer and Transaction models
   - DebtCalculator service (core business logic)
   - Strict business rule enforcement

3. **State Management**
   - Provider-based state management
   - CustomerProvider for customer operations
   - TransactionProvider for transaction operations and debt calculations

4. **UI Screens**
   - Customer List Screen (shows all customers with debt status)
   - Customer Detail Screen (shows customer info, debt, and transaction history)
   - Add Customer Screen
   - Add Credit Screen
   - Add Payment Screen (with validation)

### 📁 Project Location

```
c:\Users\HP\OneDrive\Bureau\bolt1.1\project\credit_app\
```

## Getting Started

### 1. Install Dependencies

```bash
cd c:\Users\HP\OneDrive\Bureau\bolt1.1\project\credit_app
flutter pub get
```

### 2. Run the Application

**For Android Emulator/Device:**
```bash
flutter run
```

**For Windows (Desktop):**
```bash
flutter run -d windows
```

**For Linux (Desktop):**
```bash
flutter run -d linux
```

### 3. First Test Run

1. App opens with empty customer list
2. Click the **+** button to add a customer
3. Add a test customer (name: "John Doe", phone: "555-1234")
4. Tap the customer to view details
5. Click "Add Credit" to increase debt by $100
6. Click "Add Payment" to decrease debt by $30
7. Verify debt shows $70 and transaction history is correct

## Project Structure Explained

### Data Layer (`lib/data/`)
Handles all data operations:
- `database/database_helper.dart` - SQLite initialization
- `dao/customer_dao.dart` - Low-level customer operations
- `dao/transaction_dao.dart` - Low-level transaction operations
- `repositories/` - Business-level data operations

### Domain Layer (`lib/domain/`)
Core business logic and models:
- `models/customer.dart` - Customer entity
- `models/transaction.dart` - Transaction entity with enum
- `services/debt_calculator.dart` - Debt calculation logic (most critical)

### Presentation Layer (`lib/presentation/`)
User interface:
- `screens/` - All app screens
- `widgets/` - Reusable UI components

### State Management (`lib/providers/`)
Provider-based state:
- `customer_provider.dart` - Manages customer state
- `transaction_provider.dart` - Manages transaction state and debt

## Key Business Rules (Enforced)

✅ **Debt = SUM(CREDIT) - SUM(PAYMENT)** (never negative)
✅ **No deletion of transactions** (append-only)
✅ **No editing of transactions** (immutable)
✅ **Payment validation** (can't overpay)
✅ **Debt never stored** (always calculated)

## Core Logic: Debt Calculation

Located in: `lib/domain/services/debt_calculator.dart`

```dart
static double calculateDebt(List<Transaction> transactions) {
  double totalCredit = 0;
  double totalPayment = 0;
  
  for (final transaction in transactions) {
    if (transaction.type == TransactionType.CREDIT) {
      totalCredit += transaction.amount;
    } else {
      totalPayment += transaction.amount;
    }
  }
  
  final debt = totalCredit - totalPayment;
  return debt < 0 ? 0 : debt;
}
```

This is the heart of the application. All other logic depends on it.

## Testing Checklist

Run these tests to verify everything works:

- [ ] Create multiple customers
- [ ] Add credit to a customer
- [ ] Add payment to same customer
- [ ] Verify debt calculation is correct
- [ ] Try to add payment > remaining debt (should fail)
- [ ] Verify transaction history shows newest first
- [ ] Check customer list shows correct debt amounts
- [ ] Check color coding (Green for $0, Red for >$0)
- [ ] Verify phone number is optional
- [ ] Verify notes on transactions are optional

## File Manifest

Essential files to know:

```
lib/
├── main.dart                              ← App entry point
├── data/
│   ├── database/database_helper.dart      ← SQLite setup
│   ├── dao/customer_dao.dart              ← Customer queries
│   ├── dao/transaction_dao.dart           ← Transaction queries
│   └── repositories/                      ← Repositories
├── domain/
│   ├── models/customer.dart               ← Customer class
│   ├── models/transaction.dart            ← Transaction class
│   └── services/debt_calculator.dart      ← 🔑 CORE LOGIC
├── providers/
│   ├── customer_provider.dart             ← Customer state
│   └── transaction_provider.dart          ← Transaction state
└── presentation/
    └── screens/                           ← All UI screens

pubspec.yaml                               ← Dependencies
README.md                                  ← Full documentation
```

## Building for Release

### Android (APK)
```bash
flutter build apk --release
```

### Windows (Executable)
```bash
flutter build windows --release
```

### Linux (Executable)
```bash
flutter build linux --release
```

## Troubleshooting

**Problem: Flutter not found**
```bash
# Make sure Flutter is in your PATH, or use full path
C:\flutter\bin\flutter run
```

**Problem: Android emulator not detected**
```bash
# List available devices
flutter devices

# Start emulator first, then run
flutter run
```

**Problem: Database errors**
- Delete the app and reinstall
- This will clear the database file
- App will recreate it on first run

**Problem: Validation errors**
- Ensure amount > 0
- Ensure payment <= remaining debt
- Check that customer name is not empty

## What's Next

The app is production-ready for v1. Potential enhancements (not in v1):
- Cloud sync (but this breaks offline-first design)
- Authentication (centralized vs distributed)
- Advanced reporting
- Mobile app hardening
- Internationalization

Remember: **Simplicity and correctness are more important than features.**

---

Questions? Check [README.md](./README.md) for complete documentation.
