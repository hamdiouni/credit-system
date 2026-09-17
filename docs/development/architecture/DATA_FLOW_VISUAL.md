# 🎯 Visual Data Flow - Where Your Data Goes

## How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                  Your Credit App (Flutter)                   │
│                   (http://localhost:52325)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ User adds customer "Ahmed"
                       │ in the app form
                       │
        ┌──────────────▼──────────────┐
        │   Database Layer            │
        │   (Choosable: SQLite or     │
        │    MongoDB)                 │
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
        ▼                             ▼
    ┌─────────────┐            ┌──────────────┐
    │   SQLite    │            │   MongoDB    │
    │  (Local)    │            │   (Cloud)    │
    │             │            │              │
    │ File stored │            │  Server API  │
    │ locally on  │            │  (node.js)   │
    │ your PC     │            │              │
    │             │            │  API at:     │
    │ Location:   │            │  :3000/api   │
    │ C:\Users..\│            │              │
    │ credit_app. │            │ Collections: │
    │ databases   │            │ customers    │
    │ credit_app. │            │ transactions │
    │ db          │            │              │
    └─────────────┘            └──────────────┘
```

---

## Step-by-Step: From App to Database

### Adding a Customer Named "Ahmed"

```
1. User Input (App UI)
   ↓
   ┌─────────────────────┐
   │  Customer Form      │
   │  Name: Ahmed        │
   │  Phone: 21843944    │
   │  [Save Button]      │
   └─────────────────────┘
   ↓

2. App Processing
   ↓
   ┌─────────────────────────────────────┐
   │  Flutter Code:                      │
   │  1. Validate input                  │
   │  2. Create Customer object          │
   │  3. Pass to repository              │
   │  4. Call database layer             │
   └─────────────────────────────────────┘
   ↓

3. Database Selection
   ↓
   Check: lib/config/database_config.dart
   ├─ SQLite? → SQLiteDatabase.addCustomer()
   └─ MongoDB? → MongoDatabase.addCustomer()
   ↓

4a. SQLite Path (Local Storage)
   ↓
   ┌─────────────────────────────────────┐
   │  SQLite Database Class              │
   │  - Opens database connection        │
   │  - Inserts row into customers table │
   │  - Saves to disk automatically      │
   │  - Returns success                  │
   └─────────────────────────────────────┘
   ↓
   ┌─────────────────────────────────────┐
   │  SQLite File Created/Updated        │
   │  Location:                          │
   │  C:\Users\HP\AppData\Local\        │
   │  credit_app\databases\              │
   │  credit_app.db                      │
   │                                     │
   │  Table: customers                   │
   │  ┌─────┬──────┬──────────┬─────────┐│
   │  │ id  │ name │  phone   │ created ││
   │  ├─────┼──────┼──────────┼─────────┤│
   │  │ 1   │Ahmed │ 21843944 │ 2026... ││
   │  └─────┴──────┴──────────┴─────────┘│
   └─────────────────────────────────────┘

4b. MongoDB Path (Cloud Storage)
   ↓
   ┌──────────────────────────────────────┐
   │  MongoDB Database Class              │
   │  - Creates JSON from customer object │
   │  - Sends HTTP POST to backend API    │
   │  - Backend receives at /api/customer │
   └──────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────┐
   │  Backend Server (server.js)          │
   │  - Node.js/Express running port 3000 │
   │  - Connected to MongoDB service      │
   │  - Inserts document in collection    │
   └──────────────────────────────────────┘
   ↓
   ┌──────────────────────────────────────┐
   │  MongoDB Cloud Storage               │
   │  Database: credit_app                │
   │  Collection: customers               │
   │                                      │
   │  Document:                           │
   │  {                                   │
   │    _id: ObjectId(...),               │
   │    name: "Ahmed",                    │
   │    phone: "21843944",                │
   │    createdAt: "2026-01-27T..."       │
   │  }                                   │
   └──────────────────────────────────────┘
```

---

## Where to Find Your Data

### SQLite: Local File
```
📁 C:\Users
   └─ HP
      └─ AppData
         └─ Local
            └─ credit_app
               └─ databases
                  └─ credit_app.db  ← 📊 YOUR DATA IS HERE
```

### MongoDB: Cloud Server
```
🌐 MongoDB Server (localhost:27017)
   └─ credit_app (database)
      ├─ customers (collection)    ← 📊 YOUR DATA IS HERE
      └─ transactions (collection)  ← 📊 YOUR DATA IS HERE
```

---

## Checking Your Data

### Check SQLite File Exists
```powershell
📂 File Manager
   └─ Navigate to: C:\Users\HP\AppData\Local\credit_app\databases\
   └─ Look for: credit_app.db
   └─ If it exists → SQLite working! ✅
```

### Check Data in SQLite
```
🔍 SQLite Browser (GUI Tool)
   └─ Download from: https://sqlitebrowser.org/
   └─ Open: credit_app.db
   └─ Click: "customers" table
   └─ See: All customers you added
   ✅ DATA VERIFIED!
```

### Check Data in MongoDB
```
🔍 MongoDB Shell (CLI)
   └─ Open terminal
   └─ Type: mongosh
   └─ Type: use credit_app
   └─ Type: db.customers.find()
   └─ See: All customers in JSON format
   ✅ DATA VERIFIED!
```

---

## Data Flow Summary

### User Adds "Ahmed" in App

```
📱 Browser (http://localhost:52325)
   │
   │ Click "Add Customer"
   │ Enter name, phone
   │ Click "Save"
   ▼
🎯 Flutter App
   │
   │ Validate input
   │ Create object
   ▼
🔀 Database Choice
   │
   ├─ SQLite? ──→ 💾 Local File
   │              (C:\Users\...\credit_app.db)
   │
   └─ MongoDB? ─→ 🌐 HTTP Request
                  └─→ 📡 Backend (port 3000)
                     └─→ ☁️  MongoDB Server
```

---

## Success Indicators

### ✅ SQLite is Working
```
1. File exists: credit_app.db found
2. File grows: Size increases after adding data
3. Data persists: Refresh browser, data still there
4. Can view: SQLite Browser shows tables
5. Contains data: customers table has rows
```

### ✅ MongoDB is Working
```
1. Backend running: node server.js shows "listening"
2. API responsive: http://localhost:3000/api/customers returns JSON
3. Data posted: Backend console shows POST requests
4. Database exists: mongosh shows "credit_app" database
5. Collection populated: db.customers.find() returns documents
```

---

## Real Data Example

### What Gets Stored in SQLite
```
customers table:
┌────┬───────────┬──────────────┬──────────────────┐
│ id │ name      │ phone        │ createdAt        │
├────┼───────────┼──────────────┼──────────────────┤
│ 1  │ Ahmed     │ 21843944     │ 2026-01-27T10:30 │
│ 2  │ Fatima    │ 21654321     │ 2026-01-27T10:45 │
└────┴───────────┴──────────────┴──────────────────┘

transactions table:
┌────┬───────────┬────────┬────────┬──────────────────┐
│ id │ customerId│ type   │ amount │ selectedItems    │
├────┼───────────┼────────┼────────┼──────────────────┤
│ 1  │ 1         │ credit │ 50.00  │ sugar:2,milk:1   │
│ 2  │ 1         │payment │ 30.00  │                  │
└────┴───────────┴────────┴────────┴──────────────────┘
```

### What Gets Stored in MongoDB
```json
// customers collection
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "Ahmed",
  "phone": "21843944",
  "createdAt": "2026-01-27T10:30:00.000Z"
}

// transactions collection
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "customerId": ObjectId("507f1f77bcf86cd799439011"),
  "type": "credit",
  "amount": "50.00",
  "selectedItems": ["sugar:2", "milk:1"],
  "createdAt": "2026-01-27T10:31:00.000Z"
}
```

---

## Architecture Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                   Credit App (Flutter Web)                     │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │  Presentation Layer (UI)                                │  │
│  │  - Customer List Screen                                 │  │
│  │  - Add Customer/Credit/Payment Forms                    │  │
│  └────────────────────┬────────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼────────────────────────────────────┐  │
│  │  Provider Layer (State Management)                      │  │
│  │  - CustomerProvider                                     │  │
│  │  - TransactionProvider                                  │  │
│  └────────────────────┬────────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼────────────────────────────────────┐  │
│  │  Repository Layer (Data Access)                         │  │
│  │  - CustomerRepository                                   │  │
│  │  - TransactionRepository                                │  │
│  └────────────────────┬────────────────────────────────────┘  │
│                       │                                        │
│  ┌────────────────────▼────────────────────────────────────┐  │
│  │  Database Helper (Switcher)                             │  │
│  │  - Choose: SQLite or MongoDB                            │  │
│  └────────────┬────────────────────┬──────────────────────┘  │
│               │                    │                          │
└───────────────┼────────────────────┼──────────────────────────┘
                │                    │
         ┌──────▼──┐          ┌──────▼────┐
         │ SQLite  │          │ MongoDB   │
         │(Local)  │          │ (Cloud)   │
         └──────┬──┘          └──────┬────┘
                │                    │
         ┌──────▼──┐          ┌──────▼────────┐
         │ File    │          │ Express API   │
         │ System  │          │ (Node.js)     │
         │         │          │               │
         │credit.. │          │ localhost:3000│
         │db       │          │               │
         └─────────┘          └──────┬────────┘
                                     │
                              ┌──────▼────────┐
                              │ MongoDB       │
                              │ Server        │
                              │ localhost:... │
                              └───────────────┘
```

---

## Summary

Your data journey:
```
App UI (Form) 
   ↓
Flutter Code 
   ↓
Database Helper (Chooses SQLite or MongoDB)
   ↓
   ├─ SQLite: Saves to credit_app.db file locally
   │
   └─ MongoDB: Sends to API → Stored on cloud server
   
Result: Your data is safely stored! ✅
```

**Choose your database, add data, and you can verify exactly where it's stored!** 🎉
