# 📊 How to Verify Data Storage in Both Databases

## 🎯 Testing Plan

After running the app, you'll add test data and verify it's saved in both SQLite and MongoDB.

---

## Part 1: Test with SQLite (Default)

### Step 1: Add Test Data in App

1. Open app at: **http://localhost:52325**
2. Click **➕ Add Customer**
3. Fill in:
   - Name: `Test Customer`
   - Phone: `21843944`
4. Click **Save**
5. Click on the customer you just created
6. Click **➕ Add Credit**
7. Select items: `Sugar: 2, Milk: 1`
8. Amount: `50.00`
9. Click **Save**

### Step 2: Verify SQLite Database File

**Location of SQLite database file:**
```
C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db
```

**To view SQLite data:**

**Option A: Using Firefox (Recommended)**
1. Install Firefox DB Browser: https://sqlitebrowser.org/
2. Open the file at: `C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db`
3. View tables:
   - **customers** - Should show your test customer
   - **transactions** - Should show your credit transaction

**Option B: Using Command Line**
```bash
# Install sqlite3 (if not installed)
# Download from: https://www.sqlite.org/download.html

# Open database
sqlite3 "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"

# View tables
.tables

# View customers
SELECT * FROM customers;

# View transactions
SELECT * FROM transactions;
```

**Expected Output:**

Customers table:
```
id | name           | phone     | createdAt
---|----------------|-----------|-------------------
1  | Test Customer  | 21843944  | 2026-01-27T10:30:00
```

Transactions table:
```
id | customerId | type   | amount | selectedItems | createdAt
---|------------|--------|--------|---------------|-----------
1  | 1          | credit | 50.00  | sugar:2,milk:1| 2026-01-27T10:31:00
```

---

## Part 2: Test with MongoDB (Optional - Requires Setup)

### Setup MongoDB Backend First

**Terminal 1: Start MongoDB**
```bash
mongod
```

**Terminal 2: Install Node.js packages**
```bash
cd "c:\Users\HP\OneDrive\Bureau\bolt1.1\project\credit_app"
npm install express mongoose cors dotenv
```

**Terminal 3: Start backend server**
```bash
node server.js
```

Expected output:
```
MongoDB Backend Server running on http://localhost:3000
MongoDB Connection: mongodb://localhost:27017/credit_app
```

### Step 3: Switch App to MongoDB

Edit `lib/config/database_config.dart`:
```dart
// Change line 6 from:
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.sqlite;

// To:
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.mongo;
```

**Terminal 4: Restart Flutter app**
```bash
# Kill previous: Press 'q' in the flutter terminal
# Start new:
flutter run -d chrome
```

### Step 4: Add Test Data to MongoDB

1. Add same test data through the app UI
2. The app will now save to MongoDB instead of SQLite

### Step 5: Verify MongoDB Data

**Option A: Using MongoDB Compass (GUI)**
1. Download: https://www.mongodb.com/products/tools/compass
2. Connect to: `mongodb://localhost:27017`
3. Database: `credit_app`
4. Collections:
   - **customers** - View test customer
   - **transactions** - View test transaction

**Option B: Using mongosh (CLI)**
```bash
# Start mongo shell
mongosh

# List databases
show databases

# Switch to credit_app
use credit_app

# List collections
show collections

# View customers
db.customers.find()

# View transactions
db.transactions.find()

# Count documents
db.customers.countDocuments()
db.transactions.countDocuments()
```

**Expected Output:**

Customers collection:
```json
{
  "_id": ObjectId("..."),
  "name": "Test Customer",
  "phone": "21843944",
  "createdAt": "2026-01-27T10:30:00.000Z"
}
```

Transactions collection:
```json
{
  "_id": ObjectId("..."),
  "customerId": ObjectId("..."),
  "type": "credit",
  "amount": "50.00",
  "note": null,
  "selectedItems": ["sugar:2", "milk:1"],
  "createdAt": "2026-01-27T10:31:00.000Z"
}
```

---

## Part 3: Quick Verification Checklist

### ✅ SQLite Works If:
- [ ] App runs without errors
- [ ] Can add customers and transactions
- [ ] Data persists after page refresh
- [ ] Data exists in SQLite file

### ✅ MongoDB Works If:
- [ ] Backend server running on port 3000
- [ ] App shows no API errors
- [ ] Can add customers and transactions
- [ ] Data appears in `mongosh`
- [ ] MongoDB Compass shows collections

### ✅ Database Switching Works If:
- [ ] Can change `DatabaseType` in config
- [ ] Data saves to correct database
- [ ] No errors in app or console

---

## Part 4: Testing Scenarios

### Scenario 1: Multi-User Sync (MongoDB Only)
1. Add customer on phone: `http://192.168.1.39:8080`
2. Check on computer: `http://localhost:52325`
3. Data should be identical (synced via MongoDB)

### Scenario 2: Offline Mode (SQLite Only)
1. Add customer with SQLite
2. Disconnect internet
3. App still works
4. Data still saves locally

### Scenario 3: Data Migration
1. Add 10 customers to SQLite
2. Switch to MongoDB
3. MongoDB backend should have separate database
4. To migrate: Export SQLite data, import to MongoDB

---

## Part 5: Common Issues & Solutions

### ❌ "Database file not found"
- Check path: `C:\Users\HP\AppData\Local\credit_app\databases\`
- If missing, add a customer in app (creates file)

### ❌ "Can't connect to MongoDB"
- Start MongoDB: `mongod`
- Start backend: `node server.js`
- Check port 3000: `netstat -ano | findstr :3000`

### ❌ "Data not showing in MongoDB"
- Check backend console: any errors?
- Verify `mongosh` can connect: `mongosh`
- Check database exists: `show databases` in mongosh

### ❌ "SQLite file is empty"
- App may still be running (keeps lock)
- Kill Flutter: Press 'q' in terminal
- Kill Chrome processes
- Try again

---

## Part 6: Verify Both Databases Simultaneously

Run both at same time:

**Terminal 1:**
```bash
mongod
```

**Terminal 2:**
```bash
node server.js
```

**Terminal 3:**
```bash
flutter run -d chrome
```

Create a test script to toggle between databases:

```dart
// In main.dart or any screen
import 'package:credit_app/data/database/database_helper.dart';

// Switch and test
void testDatabases() {
  // Test SQLite
  DatabaseHelper.setDatabaseType(DatabaseType.sqlite);
  print('✅ Using SQLite');
  
  // Switch to MongoDB
  DatabaseHelper.setDatabaseType(DatabaseType.mongo);
  print('✅ Using MongoDB');
  
  // Back to SQLite
  DatabaseHelper.setDatabaseType(DatabaseType.sqlite);
  print('✅ Back to SQLite');
}
```

---

## Summary

| Action | SQLite | MongoDB |
|--------|--------|---------|
| Add customer | App UI | App UI |
| View data | SQLite file OR CLI | MongoDB Compass OR mongosh |
| Persist | Automatic | Automatic |
| Sync devices | No | Yes (same server) |
| Offline | Yes | No |

**You now have professional database testing tools for both SQLite and MongoDB!** 🎉
