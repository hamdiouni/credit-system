# 🚀 Database Integration - Quick Start

## ✅ What's Ready

Your app now supports **2 professional databases**:

1. **SQLite3** ✅ - Local storage, zero setup
2. **MongoDB** ✅ - Cloud storage with backend API

---

## 🎯 Quick Start (5 seconds)

### Option A: Use SQLite (Recommended - No setup)

```bash
flutter run -d chrome
```

**Done!** Data automatically saves locally. No server needed.

---

### Option B: Use MongoDB (Requires Node.js)

**Step 1:** Install backend
```bash
npm install express mongoose cors dotenv
```

**Step 2:** Start MongoDB
```bash
mongod
```

**Step 3:** Start backend server (new terminal)
```bash
node server.js
```

**Step 4:** Switch to MongoDB in Flutter
Edit `lib/config/database_config.dart`:
```dart
// Change: DatabaseType.sqlite
// To: DatabaseType.mongo
```

**Step 5:** Run app
```bash
flutter run -d chrome
```

---

## 📦 What Was Created

| File | Purpose |
|------|---------|
| `lib/data/database/sqlite_database.dart` | SQLite implementation |
| `lib/data/database/mongo_database.dart` | MongoDB API client |
| `lib/data/database/database_helper.dart` | Switch databases |
| `lib/config/database_config.dart` | Configuration |
| `server.js` | Node.js backend |
| `DATABASE_SETUP.md` | Full setup guide |
| `DATABASE_INTEGRATION.md` | Architecture & details |

---

## ❓ Which Database Should I Use?

### SQLite ✅ If:
- Single user/device
- Works offline
- No server needed
- Simple setup

### MongoDB 🌐 If:
- Multiple users
- Cloud sync needed
- Shared data
- Advanced features

---

## 🔧 How to Switch

Edit `lib/config/database_config.dart`:

```dart
// SQLite (default)
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.sqlite;

// Or MongoDB
static const db_helper.DatabaseType activeDatabase = db_helper.DatabaseType.mongo;
```

Then restart app - that's it!

---

## 📱 Already Running?

The app is already running with **SQLite** as default.

- **Local:** http://localhost:52325
- **Network:** http://192.168.1.39:8080

All features work the same:
- ✅ Add customers
- ✅ Track payments
- ✅ Grocery items
- ✅ Multi-language
- ✅ PDF export
- ✅ Everything else

---

## 🆘 Errors?

### "Can't connect to database"
- **SQLite:** Run `flutter clean && flutter pub get`
- **MongoDB:** Check `node server.js` is running

### "API error 404"
- Backend not running: `node server.js`
- Check port 3000 is free

### Forgot which database is active?
Check `lib/config/database_config.dart` → `activeDatabase` constant

---

## 📚 Full Documentation

- **DATABASE_SETUP.md** - Complete setup guide
- **DATABASE_INTEGRATION.md** - Architecture & API reference

---

## 🎉 You're All Set!

Your app now has professional database support:
- ✅ Local SQLite (default)
- ✅ Cloud MongoDB (optional)
- ✅ Easy switching
- ✅ Zero additional setup for SQLite
- ✅ Full CRUD operations
- ✅ All existing features working

**Start with SQLite, switch to MongoDB later if needed!**
