# Architecture Document

## System Design Overview

This document describes the architecture of the Credit Management Application - a clean, layered architecture designed for maintainability, testability, and correctness.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│    PRESENTATION LAYER                   │
│  (UI Screens & Widgets)                 │
│  - customer_list_screen                 │
│  - customer_detail_screen               │
│  - add_credit_screen                    │
│  - add_payment_screen                   │
│  - add_customer_screen                  │
└─────────────────────────────────────────┘
            ↓ Reads/Updates
┌─────────────────────────────────────────┐
│    PROVIDER LAYER (State Management)    │
│  - CustomerProvider                     │
│  - TransactionProvider                  │
└─────────────────────────────────────────┘
            ↓ Uses
┌─────────────────────────────────────────┐
│    DOMAIN LAYER (Business Logic)        │
│  - Models: Customer, Transaction        │
│  - Services: DebtCalculator             │
│  - NO Dependencies on framework         │
└─────────────────────────────────────────┘
            ↓ Uses
┌─────────────────────────────────────────┐
│    DATA LAYER (Repositories)            │
│  - CustomerRepository                   │
│  - TransactionRepository                │
└─────────────────────────────────────────┘
            ↓ Uses
┌─────────────────────────────────────────┐
│    DATABASE ACCESS LAYER (DAOs)         │
│  - CustomerDAO                          │
│  - TransactionDAO                       │
└─────────────────────────────────────────┘
            ↓ Uses
┌─────────────────────────────────────────┐
│    DATABASE LAYER (SQLite)              │
│  - DatabaseHelper                       │
│  - Schema: customers, transactions      │
└─────────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Presentation Layer (`lib/presentation/`)

**Responsibility**: Render UI and handle user interaction

**Key Components**:
- `customer_list_screen.dart` - Display all customers with debt status
- `customer_detail_screen.dart` - Show customer details and transaction history
- `add_customer_screen.dart` - Create new customer
- `add_credit_screen.dart` - Add credit transaction
- `add_payment_screen.dart` - Add payment transaction (with validation)

**Rules**:
- ✅ Can depend on Presentation, Domain, and Provider layers
- ❌ Cannot have business logic beyond UI state
- ❌ Cannot directly access database or repositories
- ✅ Delegates operations to Providers

**Example**:
```dart
// In add_payment_screen.dart
context.read<TransactionProvider>().addPaymentTransaction(
  customerId,
  amount,
  note,
);
```

### 2. Provider Layer (`lib/providers/`)

**Responsibility**: Manage application state and coordinate operations

**Key Components**:
- `CustomerProvider` - Manages customer list and operations
- `TransactionProvider` - Manages transactions and debt calculations

**Rules**:
- ✅ Can depend on Presentation, Domain, and Data layers
- ✅ Uses `ChangeNotifier` for state management
- ✅ Coordinates data operations
- ❌ Cannot contain business logic (delegates to Domain)

**Example**:
```dart
// In transaction_provider.dart
Future<bool> addPaymentTransaction(...) async {
  // Get transactions
  final transactions = await _repository.getTransactionsByCustomerId(customerId);
  
  // Validate using domain logic
  if (!DebtCalculator.isValidPayment(transactions, amount)) {
    return false;
  }
  
  // Perform operation
  await _repository.createTransaction(...);
  
  // Update state
  notifyListeners();
}
```

### 3. Domain Layer (`lib/domain/`)

**Responsibility**: Core business logic and rules

**Key Components**:
- `models/customer.dart` - Customer entity
- `models/transaction.dart` - Transaction entity
- `services/debt_calculator.dart` - Debt calculation and validation

**Rules**:
- ✅ NO dependencies on Flutter or framework
- ✅ Pure Dart with no side effects
- ✅ Can be tested independently
- ✅ Enforces all business rules

**Critical Business Logic**:
```dart
// DebtCalculator.dart
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
  return debt < 0 ? 0 : debt; // Debt never negative
}

static bool isValidPayment(
    List<Transaction> transactions, 
    double paymentAmount) {
  final currentDebt = calculateDebt(transactions);
  return paymentAmount > 0 && paymentAmount <= currentDebt;
}
```

### 4. Data Layer (`lib/data/`)

**Responsibility**: Abstract database operations

**Key Components**:
- `repositories/customer_repository.dart` - Customer operations
- `repositories/transaction_repository.dart` - Transaction operations

**Rules**:
- ✅ Depends on Domain and Data Access layers
- ✅ Maps entities to/from database
- ✅ Provides clean interface to repositories

**Example**:
```dart
// In customer_repository.dart
class CustomerRepository {
  final CustomerDAO _customerDAO = CustomerDAO();

  Future<int> createCustomer(String name, String? phone) async {
    return await _customerDAO.createCustomer(name, phone);
  }
}
```

### 5. Data Access Layer (DAOs) (`lib/data/dao/`)

**Responsibility**: Direct database operations

**Key Components**:
- `customer_dao.dart` - SQL operations for customers
- `transaction_dao.dart` - SQL operations for transactions

**Rules**:
- ✅ Contains all SQL queries
- ✅ Maps database rows to domain models
- ✅ No business logic, only CRUD operations
- ✅ Handles database errors

**Example**:
```dart
// In customer_dao.dart
Future<int> createCustomer(String name, String? phone) async {
  final db = await _dbHelper.database;
  final now = DateTime.now().toIso8601String();
  
  final result = db.prepare('''
    INSERT INTO customers (name, phone, created_at)
    VALUES (?, ?, ?)
  ''').execute([name, phone, now]);
  
  return result.lastInsertRowId.toInt();
}
```

### 6. Database Layer (`lib/data/database/`)

**Responsibility**: SQLite initialization and schema

**Key Components**:
- `database_helper.dart` - Singleton database instance
- Schema creation and migrations

**Rules**:
- ✅ Singleton pattern ensures single database connection
- ✅ Creates tables on first run
- ✅ Manages database lifecycle

## Data Flow

### Creating a Customer

```
[Add Customer Screen]
         ↓ User taps "Add Customer"
[Add Customer Screen validates input]
         ↓
[Provider: context.read<CustomerProvider>().createCustomer(name, phone)]
         ↓
[Repository: customerRepository.createCustomer(name, phone)]
         ↓
[DAO: customerDAO.createCustomer(name, phone)]
         ↓
[Database: INSERT INTO customers]
         ↓
[Notification: Provider notifies listeners]
         ↓
[UI: customer_list_screen updates with new customer]
```

### Adding a Payment

```
[Add Payment Screen]
         ↓ User enters amount
[Add Payment Screen validates amount > 0]
         ↓
[Provider: context.read<TransactionProvider>().addPaymentTransaction()]
         ↓
[Domain: DebtCalculator.isValidPayment(transactions, amount)]
         ↓ If valid:
[Repository: transactionRepository.createTransaction(type=PAYMENT)]
         ↓
[DAO: transactionDAO.createTransaction()]
         ↓
[Database: INSERT INTO transactions]
         ↓
[Provider: Reloads transactions and calculates new debt]
         ↓
[Notification: Provider notifies listeners]
         ↓
[UI: customer_detail_screen updates with new debt and transaction]
```

### Calculating Debt

```
[Any UI Component needs debt for customer]
         ↓
[Provider: getDebtForCustomer(customerId)]
         ↓
[Get: getTransactionsForCustomer(customerId)]
         ↓
[Domain: DebtCalculator.calculateDebt(transactions)]
         ↓
[Returns: debt = SUM(CREDIT) - SUM(PAYMENT)]
         ↓
[UI: Displays debt with appropriate color]
```

## Database Schema

### customers Table
```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  created_at TEXT NOT NULL
)
```

**Indexes**: 
- PRIMARY KEY on `id` (automatic)

### transactions Table
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

CREATE INDEX idx_transactions_customer_id 
ON transactions(customer_id)
```

**Constraints**:
- `customer_id` must reference existing customer
- `type` is either 'CREDIT' or 'PAYMENT'
- `amount` is always positive (validated in domain layer)

## Design Patterns Used

### 1. Singleton Pattern (DatabaseHelper)
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() {
    return _instance;
  }
  
  DatabaseHelper._internal();
}
```
**Purpose**: Ensures single database connection throughout app

### 2. Repository Pattern
```dart
class CustomerRepository {
  final CustomerDAO _customerDAO = CustomerDAO();
  
  Future<int> createCustomer(String name, String? phone) async {
    return await _customerDAO.createCustomer(name, phone);
  }
}
```
**Purpose**: Abstracts data access, easier to test

### 3. Provider Pattern (State Management)
```dart
class CustomerProvider with ChangeNotifier {
  Future<void> loadCustomers() async {
    _customers = await _repository.getAllCustomers();
    notifyListeners();
  }
}
```
**Purpose**: Decouples UI from state management

### 4. Model Classes with toMap/fromMap
```dart
class Customer {
  Map<String, dynamic> toMap() { ... }
  factory Customer.fromMap(Map<String, dynamic> map) { ... }
}
```
**Purpose**: Clean serialization between database and domain

## Dependency Injection

The app uses implicit dependency injection through constructor:

```dart
// In TransactionProvider
class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();
  
  // Usage throughout the class
}

// In main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CustomerProvider()),
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
  ],
)
```

## Error Handling Strategy

Each layer handles errors appropriately:

### Domain Layer
- Validates business rules
- Returns false/throws for invalid operations
- No database errors exposed

### Data Layer
- Catches database errors
- Converts to meaningful messages
- Logs errors

### Provider Layer
- Wraps operations in try-catch
- Sets error state for UI
- Notifies listeners of errors

### Presentation Layer
- Shows error snackbars to user
- Disables UI during operations
- Handles loading states

## Testing Considerations

### Domain Layer (Easy to test)
```dart
// Test debt calculator without any dependencies
test('calculateDebt returns correct value', () {
  final transactions = [
    Transaction(..., type: CREDIT, amount: 100),
    Transaction(..., type: PAYMENT, amount: 30),
  ];
  
  final debt = DebtCalculator.calculateDebt(transactions);
  expect(debt, 70);
});
```

### Data Layer (Mock database)
```dart
// Mock CustomerDAO for testing repositories
class MockCustomerDAO extends Mock implements CustomerDAO {}

test('createCustomer calls dao', () async {
  final repo = CustomerRepository();
  // Mock the DAO
  
  await repo.createCustomer('John', null);
  // Verify DAO was called
});
```

### Presentation Layer (Mock providers)
```dart
// Wrap test widgets with MultiProvider
testWidgets('shows customer list', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockCustomerProvider()),
      ],
      child: const CreditApp(),
    ),
  );
  
  expect(find.text('John Doe'), findsOneWidget);
});
```

## Scalability Considerations

### Adding a New Feature

1. **Domain**: Define model and business rules
2. **Data Access**: Add DAO methods
3. **Repository**: Add repository methods
4. **Provider**: Add provider methods and state
5. **UI**: Add screens and navigation

### Example: Add "Customer Notes" Feature

```dart
// 1. Domain: Update Customer model
class Customer {
  final String notes; // Add this
}

// 2. Data Access: Add column to customers table
db.execute('''ALTER TABLE customers ADD COLUMN notes TEXT''');

// 3. Data Access: Update DAO
Future<void> updateCustomerNotes(int id, String notes) async {
  // Update query
}

// 4. Repository: Add method
Future<void> updateCustomerNotes(int id, String notes) async {
  return await _customerDAO.updateCustomerNotes(id, notes);
}

// 5. Provider: Add method
Future<void> updateCustomerNotes(int id, String notes) async {
  await _repository.updateCustomerNotes(id, notes);
  await loadCustomers();
}

// 6. UI: Add edit screen and call provider
```

## Performance Considerations

### Debt Calculation
- Calculated in-memory from transactions list
- O(n) complexity where n = number of transactions for customer
- Acceptable for small customer base (millions of transactions)
- For massive scale: could cache at database level

### Database Queries
- Indexed on `customer_id` for fast transaction lookups
- Transactions ordered by `created_at DESC` in queries
- No complex joins needed

### State Management
- Loads only when needed
- Caches in Provider to avoid repeated queries
- Notifies only affected listeners

## Security Considerations

**Current Scope**: Single-user, offline app on personal device

### Not Implemented (Out of scope):
- User authentication
- Encryption at rest
- Network transmission security

### Implemented:
- Input validation (amount must be positive)
- Business rule enforcement (no overpayment)
- Transaction immutability (no deletion)
- Type safety (Dart compile-time checking)

## Offline-First Design

The entire app works without network:
- ✅ All data stored locally in SQLite
- ✅ No cloud sync or backend dependency
- ✅ Works on airplane mode
- ✅ Zero latency for operations

This is enforced by:
1. No HTTP/network code anywhere
2. SQLite as single source of truth
3. No authentication or user accounts
4. No cloud services

## Conclusion

This architecture prioritizes:
1. **Correctness**: Business rules enforced in domain layer
2. **Simplicity**: Clear separation of concerns
3. **Maintainability**: Easy to understand and modify
4. **Testability**: Can test layers independently
5. **Scalability**: Can add features without major refactoring

The design is intentionally constrained to prevent over-engineering for v1.
