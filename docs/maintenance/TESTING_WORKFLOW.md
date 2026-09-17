# 🧪 Testing Workflow - SQLite & MongoDB

## Current Status
- ✅ App compiled successfully (0 errors)
- ✅ SQLite ready (default database)
- ⏳ Need to run app and test

---

## Quick Start Testing (5 Minutes)

### Step 1: Start the App
```bash
flutter run -d chrome
```

Wait 60+ seconds for Chrome to load. Output should show:
```
Waiting for connection from debug service on Chrome...
```

Then:
```
App is listening on http://localhost:52325
```

### Step 2: Open in Browser
Go to: **http://localhost:52325**

### Step 3: Add Test Customer
1. Click **➕ Add Customer** button
2. Enter:
   - Name: `Ahmed`
   - Phone: `21843944`
3. Click **Save**

### Step 4: Add Credit Transaction
1. Click on customer "Ahmed"
2. Click **➕ Add Credit**
3. Select items:
   - Sugar: 2
   - Milk: 1
4. Amount: `50.00`
5. Click **Save**

### Step 5: Refresh Browser
- Press F5 or Ctrl+R
- **If data persists → SQLite is working! ✅**

### Step 6: Verify SQLite File
Run in PowerShell:
```powershell
# Check if SQLite file exists
Test-Path "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"

# Should return: True
```

**If it returns True → Data is stored in SQLite database!** 📊

---

## View SQLite Data (3 Ways)

### Method 1: GUI Tool (Easiest)
1. Download: **SQLite Browser** (https://sqlitebrowser.org/)
2. Open the database file: `C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db`
3. Click on tables:
   - **customers** - Shows customer "Ahmed"
   - **transactions** - Shows credit of 50.00

### Method 2: Command Line
```bash
# Download sqlite3 from: https://www.sqlite.org/download.html

# Open database
sqlite3 "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"

# View customers
SELECT * FROM customers;

# Output:
# 1|Ahmed|21843944|2026-01-27T10:30:00.000

# View transactions
SELECT * FROM transactions;

# Output:
# 1|1|credit|50.00||sugar:2,milk:1|2026-01-27T10:31:00.000
```

### Method 3: PowerShell Script
```powershell
# Download SQLite: https://www.sqlite.org/download.html
# Place sqlite3.exe in your PATH

$dbPath = "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"

if (Test-Path $dbPath) {
    Write-Host "✓ SQLite database found!"
    
    # Get file size
    $size = (Get-Item $dbPath).Length / 1KB
    Write-Host "  Size: $size KB"
    
    # Get creation time
    $created = (Get-Item $dbPath).CreationTime
    Write-Host "  Created: $created"
    
    # Show tables
    sqlite3 $dbPath ".tables"
} else {
    Write-Host "✗ Database not found - add a customer first!"
}
```

---

## Optional: Test MongoDB (Advanced)

### Prerequisites
- Node.js installed
- MongoDB installed (or MongoDB Atlas account)

### Step 1: Install Backend
```bash
cd "c:\Users\HP\OneDrive\Bureau\bolt1.1\project\credit_app"
npm install express mongoose cors dotenv
```

### Step 2: Start MongoDB
```bash
mongod
```

### Step 3: Start Backend (New Terminal)
```bash
node server.js
```

Expected:
```
MongoDB Backend Server running on http://localhost:3000
MongoDB Connection: mongodb://localhost:27017/credit_app
```

### Step 4: Switch App to MongoDB
Edit: `lib/config/database_config.dart`

Change:
```dart
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.sqlite;
```

To:
```dart
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.mongo;
```

### Step 5: Restart Flutter
```bash
# In the flutter terminal, press 'q' to quit
# Then run again:
flutter run -d chrome
```

### Step 6: Add Same Test Data
- Add customer "Ahmed" again
- Add credit transaction

### Step 7: Verify MongoDB Data
```bash
# Open MongoDB shell
mongosh

# Switch database
use credit_app

# View customers
db.customers.find()

# Output:
# {
#   _id: ObjectId("..."),
#   name: 'Ahmed',
#   phone: '21843944',
#   createdAt: '2026-01-27T10:30:00.000Z'
# }

# View transactions
db.transactions.find()

# Output:
# {
#   _id: ObjectId("..."),
#   customerId: ObjectId("..."),
#   type: 'credit',
#   amount: '50.00',
#   selectedItems: [ 'sugar:2', 'milk:1' ],
#   createdAt: '2026-01-27T10:31:00.000Z'
# }
```

**If you see data → MongoDB is working!** ✅

---

## Complete Testing Checklist

### SQLite Tests
- [ ] App runs without errors
- [ ] Can add customer through UI
- [ ] Can add credit transaction
- [ ] Data persists after page refresh
- [ ] SQLite file exists at: `C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db`
- [ ] SQLite Browser shows data in tables
- [ ] mongosh shows customer and transaction records

### MongoDB Tests (Optional)
- [ ] Backend server running on port 3000
- [ ] App switches to MongoDB without errors
- [ ] Can add customer through UI
- [ ] Can add credit transaction
- [ ] `mongosh` shows data in `credit_app` database
- [ ] MongoDB Compass shows collections and data

### Database Switching Tests
- [ ] Can switch from SQLite to MongoDB
- [ ] Can switch from MongoDB back to SQLite
- [ ] Each database stores data independently
- [ ] No cross-database conflicts

---

## Expected Data Format

### SQLite Format
```
customers table:
id | name  | phone    | createdAt
1  | Ahmed | 21843944 | 2026-01-27T10:30:00.000

transactions table:
id | customerId | type   | amount | note | selectedItems | createdAt
1  | 1          | credit | 50.00  | null | sugar:2,milk:1 | 2026-01-27T10:31:00.000
```

### MongoDB Format
```json
// customers collection
{
  "_id": ObjectId("..."),
  "name": "Ahmed",
  "phone": "21843944",
  "createdAt": "2026-01-27T10:30:00.000Z"
}

// transactions collection
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

## Troubleshooting

### ❌ App won't start
- Check Flutter is installed: `flutter doctor`
- Check Chrome is available: `flutter devices`
- Try: `flutter clean && flutter pub get`

### ❌ App runs but no database file created
- App might not be saving data properly
- Check browser console for JavaScript errors: F12
- Check Flutter console for Dart errors

### ❌ MongoDB not connecting
- Verify MongoDB is running: `mongosh`
- Check backend server: `http://localhost:3000/api/customers`
- Verify network firewall allows port 3000

### ❌ Data shows in SQLite but not MongoDB
- Different databases store separately
- Make sure you changed `DatabaseType.mongo`
- Restart Flutter after changing database type

---

## Success Indicators

### ✅ SQLite Working
1. App runs
2. Can add customers
3. Database file exists
4. Data in SQLite file
5. Data persists on refresh

### ✅ MongoDB Working
1. Backend server running
2. App connects to API
3. Can add customers
4. Data in MongoDB collections
5. Can view with mongosh

### ✅ Both Databases Working
1. Can switch between them
2. Each stores data independently
3. No errors on switch
4. All features work on both

---

## Summary

You now have:
✅ **SQLite** - Local storage, ready to use
✅ **MongoDB** - Optional cloud storage, requires setup
✅ **Easy switching** - One line of code to switch databases
✅ **Full testing** - Know exactly where data is stored

**Start with SQLite, upgrade to MongoDB when needed!**
