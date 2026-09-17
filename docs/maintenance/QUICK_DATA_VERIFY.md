# 🚀 Quick Reference - How to Know Data is Saved

## In 30 Seconds

### Test SQLite (Default)
```bash
# 1. Run app
flutter run -d chrome

# 2. Open browser
http://localhost:52325

# 3. Add customer + credit
# (Use form in app)

# 4. Refresh browser
# If data still there → SQLITE WORKING! ✅

# 5. Verify file exists
Test-Path "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"
# If True → DATA SAVED! ✅
```

### Test MongoDB (Optional)
```bash
# 1. Start MongoDB
mongod

# 2. Start backend (new terminal)
node server.js
# Should show: "MongoDB Backend Server running on http://localhost:3000"

# 3. Switch app to MongoDB
# Edit: lib/config/database_config.dart
# Change: DatabaseType.sqlite → DatabaseType.mongo

# 4. Restart app
flutter run -d chrome

# 5. Add customer + credit in app

# 6. Check MongoDB
mongosh
use credit_app
db.customers.find()
# If shows data → MONGODB WORKING! ✅
```

---

## 3 Ways to Verify Data Storage

### Way 1: File System Check (Easiest for SQLite)
```powershell
# SQLite file should exist here after first use:
C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db

# Check with PowerShell:
Test-Path "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"
```

### Way 2: Database Browser (Visual for SQLite)
```
1. Download: SQLite Browser (https://sqlitebrowser.org/)
2. Open file: C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db
3. Click "customers" table → see your data!
4. Click "transactions" table → see your transactions!
```

### Way 3: CLI Query (Detailed for both)
```bash
# SQLite
sqlite3 "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"
SELECT * FROM customers;
SELECT * FROM transactions;

# MongoDB
mongosh
use credit_app
db.customers.find()
db.transactions.find()
```

---

## What to Expect After Adding Data

### ✅ SQLite Success Indicators
- File appears at: `C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db`
- Data persists when you refresh the page
- SQLite Browser shows data in tables
- File size grows (typically starts at 4-16 KB)

### ✅ MongoDB Success Indicators
- Backend shows: `POST /api/customers 201` in console
- MongoDB shows collection: `credit_app.customers`
- `mongosh` returns JSON documents
- Data syncs to cloud (if using Atlas)

---

## Data Structure in Storage

### What Gets Stored

**Customers:**
```
ID | Name | Phone | Date Created
1  | Ahmed | 21843944 | 2026-01-27T10:30:00
```

**Transactions:**
```
ID | Customer | Type   | Amount | Items              | Date
1  | 1        | credit | 50.00  | sugar:2, milk:1    | 2026-01-27T10:31:00
2  | 1        | payment| 30.00  | (empty)            | 2026-01-27T11:00:00
```

---

## Ports to Check

```bash
# SQLite uses local storage (no port needed)
# Just refresh browser to verify

# MongoDB/Backend uses port 3000
netstat -ano | findstr ":3000"
# Should show: LISTENING if backend is running

# Flutter dev server uses dynamic port (usually 52325)
netstat -ano | findstr ":52325"
# Should show: LISTENING if app is running
```

---

## Change Database Without Losing Data

### Switch from SQLite to MongoDB
1. MongoDB database is separate (empty)
2. Existing SQLite data stays safe
3. Add new data to MongoDB
4. Can switch back anytime

### Switch from MongoDB to SQLite
1. SQLite database is separate (may be empty)
2. Existing MongoDB data stays on server
3. Add new data to SQLite
4. Can switch back anytime

---

## One-Minute Database Test

```bash
# Terminal 1: Start app
flutter run -d chrome

# Wait 60 seconds, then open: http://localhost:52325

# In app, click "Add Customer", enter "Test", click Save

# In same terminal window with flutter, press 'r' for hot reload

# Refresh browser - if customer "Test" still shows
# ✅ DATA SAVED IN SQLITE!

# To verify file:
Test-Path "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"
# True = File exists = DATA SAVED ✅
```

---

## If You See This...

### ✅ "Data persists after refresh"
- SQLite is working!
- Data is being saved

### ✅ "mongosh shows my data"
- MongoDB is working!
- Data is being saved to cloud

### ❌ "Data disappears on refresh"
- Using in-memory database (temporary)
- Check if SQLite file was created
- Restart app and try again

### ❌ "mongosh is empty"
- Check: `node server.js` is running
- Check: DatabaseType.mongo is set
- Check: Backend console shows POST requests

---

## Pro Tips

1. **Keep terminal running** - "flutter run" needs to stay active
2. **Watch port 3000** - Use `netstat -ano | findstr ":3000"` to verify MongoDB backend
3. **Restart for changes** - If you switch databases, restart the app (press 'q' then run again)
4. **Check logs** - Browser console (F12) shows API errors for MongoDB
5. **Multiple files** - SQLite stores 1 file, MongoDB stores 1 collection per database

---

## Files to Check

### SQLite
```
C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db
```

### MongoDB
```
mongosh → use credit_app → show collections
```

---

## Summary

| Action | SQLite | MongoDB |
|--------|--------|---------|
| Run app | Works | Works (with backend) |
| Add data | Saved to file | Saved to server |
| Verify | Check file | Check mongosh |
| Persist | Yes | Yes |
| Multi-device | No | Yes |
| Offline | Yes | No |

**That's it! You now know exactly where your data is stored!** 🎉
