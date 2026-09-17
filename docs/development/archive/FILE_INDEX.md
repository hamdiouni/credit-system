# File Index & Quick Reference

## Project Structure Overview

```
credit_app/
├── lib/                                  # Application code
│   ├── main.dart                         # App entry point & MultiProvider setup
│   │
│   ├── data/                             # Data layer (database, DAOs, repositories)
│   │   ├── database/
│   │   │   └── database_helper.dart      # SQLite initialization & schema
│   │   │
│   │   ├── dao/                          # Data Access Objects
│   │   │   ├── customer_dao.dart         # SQL: Customer queries
│   │   │   └── transaction_dao.dart      # SQL: Transaction queries
│   │   │
│   │   └── repositories/                 # Business-level data operations
│   │       ├── customer_repository.dart  # Customer operations abstraction
│   │       └── transaction_repository.dart # Transaction operations abstraction
│   │
│   ├── domain/                           # Domain layer (models & business logic)
│   │   ├── models/
│   │   │   ├── customer.dart             # Customer entity with serialization
│   │   │   └── transaction.dart          # Transaction entity with enum
│   │   │
│   │   └── services/
│   │       └── debt_calculator.dart      # 🔑 CORE LOGIC: Debt calculation & validation
│   │
│   ├── providers/                        # State management (Provider)
│   │   ├── customer_provider.dart        # Customer state & operations
│   │   └── transaction_provider.dart     # Transaction state & debt calculations
│   │
│   └── presentation/                     # Presentation layer (UI screens)
│       ├── screens/
│       │   ├── customer_list_screen.dart       # List all customers with debt
│       │   ├── customer_detail_screen.dart    # Customer details & transaction history
│       │   ├── add_customer_screen.dart       # Create new customer form
│       │   ├── add_credit_screen.dart         # Add credit transaction form
│       │   └── add_payment_screen.dart        # Add payment transaction form
│       │
│       └── widgets/                     # Reusable UI components (currently none)
│
├── pubspec.yaml                         # Flutter dependencies
├── analysis_options.yaml                # Dart lint rules
├── .gitignore                          # Git ignore rules
│
├── README.md                           # Full project documentation
├── QUICK_START.md                      # Setup & first steps guide
├── ARCHITECTURE.md                     # Detailed architecture documentation
├── BUSINESS_RULES.md                   # Business rules reference
└── IMPLEMENTATION_SUMMARY.md           # This project completion summary
```

## File Purpose Quick Reference

### Core Application Files

| File | Purpose | Key Classes |
|------|---------|-------------|
| `main.dart` | App entry point, MultiProvider setup | `CreditApp` |
| `database_helper.dart` | SQLite init, singleton, schema | `DatabaseHelper` |
| `customer_dao.dart` | Customer database queries | `CustomerDAO` |
| `transaction_dao.dart` | Transaction database queries | `TransactionDAO` |
| `customer_repository.dart` | Customer data abstraction | `CustomerRepository` |
| `transaction_repository.dart` | Transaction data abstraction | `TransactionRepository` |
| `customer.dart` | Customer model with serialization | `Customer` |
| `transaction.dart` | Transaction model + enum | `Transaction`, `TransactionType` |
| `debt_calculator.dart` | **Business logic** - debt calculation | `DebtCalculator` |
| `customer_provider.dart` | Customer state management | `CustomerProvider` |
| `transaction_provider.dart` | Transaction state management | `TransactionProvider` |
| `customer_list_screen.dart` | Display all customers | `CustomerListScreen` |
| `customer_detail_screen.dart` | Show customer details & history | `CustomerDetailScreen` |
| `add_customer_screen.dart` | Create customer form | `AddCustomerScreen` |
| `add_credit_screen.dart` | Add credit form | `AddCreditScreen` |
| `add_payment_screen.dart` | Add payment form | `AddPaymentScreen` |

### Documentation Files

| File | Purpose | Audience |
|------|---------|----------|
| `README.md` | Complete documentation | Everyone |
| `QUICK_START.md` | Setup & first run | New users |
| `ARCHITECTURE.md` | Architecture details | Developers |
| `BUSINESS_RULES.md` | Business rules reference | Business & Developers |
| `IMPLEMENTATION_SUMMARY.md` | Project completion summary | Project stakeholders |
| `FILE_INDEX.md` | This file - file reference | Everyone |

### Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Flutter project manifest & dependencies |
| `analysis_options.yaml` | Dart lint rules |
| `.gitignore` | Git ignore patterns |

## How to Navigate the Codebase

### I want to understand debt calculation
👉 Start: `lib/domain/services/debt_calculator.dart`
- Core business logic
- All rules enforced here
- Only ~50 lines

### I want to understand data flow
👉 Read: `ARCHITECTURE.md` → "Data Flow" section
- Shows operation flow through layers
- Shows where validation happens
- Includes diagrams

### I want to add a feature
👉 Follow: `ARCHITECTURE.md` → "Scalability Considerations" section
- Shows how to add new features
- Shows all layers that need changes

### I want to understand the app startup
👉 Start: `lib/main.dart`
- App initialization
- Provider setup
- Initial screen

### I want to understand customer management
👉 Read in order:
1. `lib/domain/models/customer.dart` - Customer model
2. `lib/data/dao/customer_dao.dart` - Database operations
3. `lib/data/repositories/customer_repository.dart` - Data abstraction
4. `lib/providers/customer_provider.dart` - State management
5. `lib/presentation/screens/customer_list_screen.dart` - UI

### I want to understand transaction management
👉 Read in order:
1. `lib/domain/models/transaction.dart` - Transaction model
2. `lib/domain/services/debt_calculator.dart` - Business logic
3. `lib/data/dao/transaction_dao.dart` - Database operations
4. `lib/providers/transaction_provider.dart` - State management
5. `lib/presentation/screens/add_payment_screen.dart` - Payment UI

### I want to understand a specific screen
👉 Navigate to `lib/presentation/screens/` and find the file
- Each screen is self-contained
- Shows how to use providers
- Shows user input validation

## Key Classes & Their Locations

### Data Models
- `Customer` - `lib/domain/models/customer.dart`
- `Transaction` - `lib/domain/models/transaction.dart`
- `TransactionType` (CREDIT, PAYMENT) - `lib/domain/models/transaction.dart`

### Business Logic
- `DebtCalculator` - `lib/domain/services/debt_calculator.dart`
  - `calculateDebt()` - Calculate debt from transactions
  - `isValidPayment()` - Validate payment amount
  - `wouldOverpay()` - Check if payment would overpay

### Data Access
- `DatabaseHelper` - `lib/data/database/database_helper.dart`
- `CustomerDAO` - `lib/data/dao/customer_dao.dart`
- `TransactionDAO` - `lib/data/dao/transaction_dao.dart`

### Repositories
- `CustomerRepository` - `lib/data/repositories/customer_repository.dart`
- `TransactionRepository` - `lib/data/repositories/transaction_repository.dart`

### State Management
- `CustomerProvider` - `lib/providers/customer_provider.dart` (extends `ChangeNotifier`)
- `TransactionProvider` - `lib/providers/transaction_provider.dart` (extends `ChangeNotifier`)

### UI Screens
- `CustomerListScreen` - `lib/presentation/screens/customer_list_screen.dart`
- `CustomerDetailScreen` - `lib/presentation/screens/customer_detail_screen.dart`
- `AddCustomerScreen` - `lib/presentation/screens/add_customer_screen.dart`
- `AddCreditScreen` - `lib/presentation/screens/add_credit_screen.dart`
- `AddPaymentScreen` - `lib/presentation/screens/add_payment_screen.dart`

## Important Methods to Know

### DebtCalculator (Core Logic)
```dart
// Calculate remaining debt
static double calculateDebt(List<Transaction> transactions)

// Validate if payment is allowed
static bool isValidPayment(List<Transaction> transactions, double paymentAmount)

// Check if would overpay
static bool wouldOverpay(List<Transaction> transactions, double paymentAmount)
```

### CustomerProvider
```dart
// Load all customers
Future<void> loadCustomers()

// Create new customer
Future<int> createCustomer(String name, String? phone)

// Get customer by ID
Future<Customer?> getCustomerById(int id)
```

### TransactionProvider
```dart
// Load transactions for customer
Future<void> loadTransactionsForCustomer(int customerId)

// Add credit transaction
Future<void> addCreditTransaction(int customerId, double amount, String? note)

// Add payment transaction (validates)
Future<bool> addPaymentTransaction(int customerId, double amount, String? note)

// Get transactions for customer
List<Transaction> getTransactionsForCustomer(int customerId)

// Get debt for customer
double getDebtForCustomer(int customerId)
```

## Database Tables

### customers
```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  created_at TEXT NOT NULL
)
```

### transactions
```sql
CREATE TABLE transactions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  type TEXT NOT NULL,
  amount REAL NOT NULL,
  note TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers (id)
)

CREATE INDEX idx_transactions_customer_id ON transactions(customer_id)
```

## Dependency Graph

```
main.dart
├── CustomerProvider
│   ├── CustomerRepository
│   │   └── CustomerDAO
│   │       └── DatabaseHelper
│   └── Customer (domain model)
│
└── TransactionProvider
    ├── TransactionRepository
    │   └── TransactionDAO
    │       └── DatabaseHelper
    ├── Transaction (domain model)
    └── DebtCalculator
        └── Transaction (domain model)
```

## Layer Dependencies

```
Presentation Layer
  ↓ depends on
Provider Layer
  ↓ depends on
Domain Layer + Data Layer
  ↓ depends on
Data Access Layer
  ↓ depends on
Database Layer
```

## File Sizes (Approximate)

| Category | Files | Size |
|----------|-------|------|
| Models | 2 | ~150 lines |
| Database | 3 | ~150 lines |
| Repositories | 2 | ~40 lines |
| Providers | 2 | ~130 lines |
| Screens | 5 | ~500 lines |
| Business Logic | 1 | ~50 lines |
| Configuration | 3 | ~100 lines |
| Documentation | 5 | ~2000 lines |
| **Total** | **23** | **~3000 lines** |

## Common Navigation Patterns

### To understand a feature
1. Find the screen in `lib/presentation/screens/`
2. Look at the provider it uses
3. Look at the repository/DAO it calls
4. Look at the domain model
5. Look at any domain services (like DebtCalculator)

### To add a feature
1. Update domain model if needed
2. Add DAO methods if needed
3. Add repository methods if needed
4. Add provider methods if needed
5. Add UI screen if needed
6. Update navigation if needed

### To fix a bug
1. Identify which screen shows the bug
2. Check the provider logic
3. Check the domain logic
4. Check the data access logic
5. Check the database

## Quick Command Reference

```bash
# Navigate to project
cd c:\Users\HP\OneDrive\Bureau\bolt1.1\project\credit_app

# Install dependencies
flutter pub get

# Run app
flutter run                    # Android/default
flutter run -d windows         # Windows
flutter run -d linux          # Linux

# Build for release
flutter build apk --release   # Android APK
flutter build windows --release # Windows exe
flutter build linux --release   # Linux exe

# Lint code
dart analyze

# Format code
dart format lib/
```

## Documentation Files & What To Read

- **New to the project?** → Start with `QUICK_START.md`
- **Want full details?** → Read `README.md`
- **Understanding design?** → Read `ARCHITECTURE.md`
- **Business requirements?** → Read `BUSINESS_RULES.md`
- **Project completion?** → Read `IMPLEMENTATION_SUMMARY.md`
- **File locations?** → This file (`FILE_INDEX.md`)

---

**Last Updated**: January 25, 2026
**Project Status**: ✅ Complete and Ready to Run
