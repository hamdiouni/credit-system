# Business Rules Reference

## Critical Rules

These rules are NON-NEGOTIABLE and enforced by the system.

### Rule 1: Debt Calculation

**Formula:**
```
Remaining Debt = SUM(All Credit Transactions) - SUM(All Payment Transactions)
```

**Properties:**
- ✅ Debt is ALWAYS calculated, NEVER stored
- ✅ Debt can never be negative (minimum = $0)
- ✅ Calculation happens in-memory from transaction history

**Location**: `lib/domain/services/debt_calculator.dart`

**Code:**
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
  return debt < 0 ? 0 : debt; // Can never be negative
}
```

### Rule 2: Transactions Are Immutable

**Properties:**
- ✅ Transactions are APPEND-ONLY
- ❌ NO deletion of transactions
- ❌ NO editing of transactions
- ✅ Once created, transactions are permanent

**Why?**
- Audit trail integrity
- Prevents fraud/manipulation
- Simplifies logic
- Ensures historical accuracy

**Implementation**:
- No `DELETE` or `UPDATE` operations on transactions table
- No UI screens for editing/deleting transactions
- Database schema enforces this at application level

### Rule 3: Payment Validation

**Rule**: You cannot pay more than you owe

**Validation Logic:**
```dart
static bool isValidPayment(
    List<Transaction> transactions, 
    double paymentAmount) {
  final currentDebt = calculateDebt(transactions);
  return paymentAmount > 0 && paymentAmount <= currentDebt;
}
```

**Enforcement Points:**
1. UI validates input (amount > 0)
2. Provider validates against current debt
3. Domain layer confirms with DebtCalculator
4. User sees error message if invalid

**Example Scenario:**
```
Current Debt: $50
User tries to pay: $75
System Response: "Payment amount exceeds remaining debt"
Result: Payment is REJECTED
```

### Rule 4: Amounts Must Be Positive

**Properties:**
- ✅ All amounts > 0
- ❌ No zero amounts
- ❌ No negative amounts

**Validation Locations:**
1. `add_credit_screen.dart` - UI validation
2. `add_payment_screen.dart` - UI validation
3. `DebtCalculator.isValidPayment()` - Domain validation

**Code Example:**
```dart
if (amount == null || amount <= 0) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Enter a valid positive amount')),
  );
  return;
}
```

### Rule 5: Transaction History Is Complete

**Properties:**
- ✅ All transactions are preserved
- ✅ No gaps in history
- ✅ Transactions ordered by creation time (newest first)

**Implementation**:
```dart
// In add_payment_screen.dart
// User sees full transaction history ordered by created_at DESC
final result = db.prepare('''
  SELECT ... FROM transactions 
  WHERE customer_id = ? 
  ORDER BY created_at DESC
''').select([customerId]);
```

### Rule 6: Debt Status Color Coding

**UI Convention**:
- 🟢 **Green**: Debt = $0 (paid in full)
- 🔴 **Red**: Debt > $0 (outstanding balance)

**Implementation Locations:**
1. `customer_list_screen.dart` - Shows debt with color
2. `customer_detail_screen.dart` - Shows debt with color

**Code:**
```dart
final debtColor = debt == 0 ? Colors.green : Colors.red;

Container(
  decoration: BoxDecoration(
    color: debtColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    '\$${debt.toStringAsFixed(2)}',
    style: TextStyle(color: debtColor, fontWeight: FontWeight.bold),
  ),
)
```

## Data Integrity Rules

### Customer Rules

**Creation:**
- ✅ Name is REQUIRED
- ✅ Phone is OPTIONAL
- ✅ Created timestamp is automatic

**Constraints:**
- ❌ Cannot have duplicate names (not enforced, but discouraged)
- ✅ Customer ID is unique (database enforces)
- ✅ Cannot create customer with empty name

**Immutability:**
- ❌ Cannot delete customer (cascading would delete transactions)
- ❌ Cannot edit customer details
- ✅ Customer record is permanent

### Transaction Rules

**Creation:**
- ✅ Customer ID must reference existing customer
- ✅ Type is either CREDIT or PAYMENT
- ✅ Amount must be positive
- ✅ Note is optional
- ✅ Created timestamp is automatic

**Constraints:**
- ✅ Foreign key constraint: customer_id must exist
- ✅ Type must be valid enum value
- ✅ Amount must be > 0 (not enforced by DB, by domain logic)

**Immutability:**
- ❌ NO UPDATE operations
- ❌ NO DELETE operations
- ✅ Transaction is permanent once created

## Validation Layers

### 1. UI Validation (First Line)

**Location**: Screens handle user input

**Checks**:
- Amount is not empty
- Amount is positive number
- Amount can be parsed to double
- Name is not empty
- Payment doesn't exceed current debt

**Code Example**:
```dart
// In add_payment_screen.dart
if (amount > widget.currentDebt) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Payment exceeds remaining debt')),
  );
  return;
}
```

### 2. Provider Validation (Second Line)

**Location**: Provider before creating transaction

**Checks**:
- Calls domain validation
- Checks business rules
- Returns success/failure

**Code Example**:
```dart
// In transaction_provider.dart
Future<bool> addPaymentTransaction(...) async {
  final transactions = await _repository
      .getTransactionsByCustomerId(customerId);
  
  if (!DebtCalculator.isValidPayment(transactions, amount)) {
    _error = 'Payment amount exceeds remaining debt';
    notifyListeners();
    return false;
  }
  
  await _repository.createTransaction(...);
  return true;
}
```

### 3. Domain Validation (Core Logic)

**Location**: `DebtCalculator` service

**Checks**:
- Payment <= current debt
- Amount > 0
- Mathematical correctness

**Code Example**:
```dart
// In debt_calculator.dart
static bool isValidPayment(
    List<Transaction> transactions, 
    double paymentAmount) {
  final currentDebt = calculateDebt(transactions);
  return paymentAmount > 0 && paymentAmount <= currentDebt;
}
```

### 4. Database Constraints (Last Resort)

**Location**: SQLite schema

**Constraints**:
- Primary keys
- Foreign keys
- NOT NULL for required fields

```sql
CREATE TABLE transactions (
  customer_id INTEGER NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers (id)
)
```

## Business Scenarios

### Scenario 1: Creating a New Customer

**Step 1: Input**
- User enters name: "John Doe"
- User enters phone: "555-1234" (optional)

**Step 2: Validation**
- Screen checks name is not empty ✓
- Phone is optional, so no validation needed

**Step 3: Creation**
- Provider calls repository
- Repository calls DAO
- DAO inserts into database
- System returns customer ID

**Step 4: Display**
- UI updates to show new customer
- Debt is $0 (no transactions)
- Shows in GREEN

### Scenario 2: Customer Takes $100 in Credit

**Starting State**: Debt = $0 (Green)

**Step 1: User clicks "Add Credit"**

**Step 2: Input**
- User enters amount: 100

**Step 3: Validation**
- Amount > 0 ✓
- No debt calculation needed (credit always allowed)

**Step 4: Creation**
- Provider calls repository
- DAO inserts: Transaction(type=CREDIT, amount=100)

**Step 5: Recalculation**
- Debt = SUM(CREDIT) - SUM(PAYMENT)
- Debt = 100 - 0 = 100

**Step 6: Display**
- UI updates debt to $100
- Shows in RED

### Scenario 3: Customer Pays $30

**Starting State**: Debt = $100 (Red)

**Step 1: User clicks "Add Payment"**

**Step 2: Input**
- User enters amount: 30

**Step 3: Validation - UI
- Amount > 0 ✓
- Screen shows "Current Debt: $100"
- Amount (30) <= Debt (100) ✓

**Step 4: Validation - Provider**
- Gets current transactions
- Calls DebtCalculator.isValidPayment()
- Current debt = 100
- 30 > 0 ✓ and 30 <= 100 ✓
- Validation passes

**Step 5: Creation**
- DAO inserts: Transaction(type=PAYMENT, amount=30)

**Step 6: Recalculation**
- Debt = SUM(CREDIT) - SUM(PAYMENT)
- Debt = 100 - 30 = 70

**Step 7: Display**
- UI updates debt to $70
- Still shows in RED

### Scenario 4: Customer Tries to Overpay

**Starting State**: Debt = $70 (Red)

**Step 1: User clicks "Add Payment"**

**Step 2: Input**
- User enters amount: 100

**Step 3: Validation - UI**
- Screen shows "Current Debt: $70"
- User tries to pay $100
- 100 > 70
- Shows error: "Payment amount exceeds remaining debt"
- UI blocks submission

**Result**: Payment is REJECTED - transaction is NOT created

### Scenario 5: Customer Pays in Full

**Starting State**: Debt = $70 (Red)

**Step 1: User clicks "Add Payment"**

**Step 2: Input**
- User enters amount: 70

**Step 3: Validation - UI**
- Amount (70) <= Debt (70) ✓

**Step 4: Validation - Provider**
- 70 <= 70 ✓

**Step 5: Creation**
- DAO inserts: Transaction(type=PAYMENT, amount=70)

**Step 6: Recalculation**
- Debt = 100 - (30 + 70) = 0

**Step 7: Display**
- UI updates debt to $0.00
- Changes to GREEN (paid in full)

**Transaction History** (newest first):
1. PAYMENT $70 (just added)
2. PAYMENT $30 (earlier)
3. CREDIT $100 (original)

## Error Handling Rules

### Invalid Amount
```
User Input: "abc"
System: "Enter a valid positive amount"
Result: Blocked at UI
```

### Amount Too Large
```
Current Debt: $50
User Input: $75
System: "Payment amount exceeds remaining debt"
Result: Blocked at UI and Provider
```

### Empty Customer Name
```
User Input: "" (empty)
System: "Name is required"
Result: Blocked at UI
```

### Missing Amount
```
User Input: "" (empty)
System: "Amount is required"
Result: Blocked at UI
```

## Audit Trail

Every operation leaves a permanent record:

1. **Creating a customer** → Customer record created with `created_at`
2. **Adding a credit** → Transaction record created with CREDIT type and timestamp
3. **Adding a payment** → Transaction record created with PAYMENT type and timestamp

**Properties**:
- All timestamps are in UTC ISO 8601 format
- Transactions never modified or deleted
- Complete history available for review
- Debt can be recalculated at any time from history

## State Consistency

The system maintains consistency through:

1. **In-Memory Calculation**: Debt calculated from current transactions
2. **No Stored Debt**: No debt field in database to get out of sync
3. **Append-Only Transactions**: No modifications = no consistency issues
4. **Single Source of Truth**: SQLite database is the truth

**Guarantee**: If you see debt = $X, you can verify it:
```
Verify Debt:
1. Get all transactions for customer
2. Sum all CREDIT amounts
3. Sum all PAYMENT amounts
4. Debt = Credits - Payments (minimum $0)
```

---

**Remember**: Correctness and simplicity are more important than features.
