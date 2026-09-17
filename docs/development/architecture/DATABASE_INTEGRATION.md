# Database Integration Complete ✅

## What Was Added

### 1️⃣ SQLite3 Database (Default)
**File:** `lib/data/database/sqlite_database.dart`
- Local persistent storage
- No server needed
- Automatic data persistence
- Zero configuration

### 2️⃣ MongoDB Backend
**Files:**
- `lib/data/database/mongo_database.dart` - Flutter API client
- `server.js` - Node.js/Express backend server

### 3️⃣ Database Switcher
**File:** `lib/data/database/database_helper.dart`
- Change databases with one line of code
- Unified interface for both SQLite and MongoDB

### 4️⃣ Configuration File
**File:** `lib/config/database_config.dart`
- Easy database selection
- Status information

---

## How to Use

### 🗄️ Using SQLite (Default - No Setup Needed)

```bash
# Just run normally
flutter run -d chrome
```

**Data automatically saves to:**
- Windows/Linux: `~/.local/share/credit_app/databases/credit_app.db`
- macOS: `~/Library/Application Support/credit_app/databases/credit_app.db`

---

### 🌐 Using MongoDB (Requires Setup)

#### Step 1: Install Node.js Backend
```bash
cd credit_app
npm install express mongoose cors dotenv
```

#### Step 2: Start MongoDB
```bash
# Make sure MongoDB is running
mongod
# Or use MongoDB Atlas (cloud)
```

#### Step 3: Create `.env` file
```
MONGODB_URI=mongodb://localhost:27017/credit_app
PORT=3000
```

#### Step 4: Start Backend Server
```bash
node server.js
```

Output:
```
MongoDB Backend Server running on http://localhost:3000
MongoDB Connection: mongodb://localhost:27017/credit_app
```

#### Step 5: Switch Flutter to MongoDB
Edit `lib/config/database_config.dart`:
```dart
// Change from:
static const DatabaseType activeDatabase = DatabaseType.sqlite;

// To:
static const DatabaseType activeDatabase = DatabaseType.mongo;
```

#### Step 6: Run Flutter App
```bash
flutter run -d chrome
```

---

## Database Comparison

| Feature | SQLite | MongoDB |
|---------|--------|---------|
| Setup | ✅ Zero config | ❌ Requires Node.js |
| Persistence | ✅ Automatic | ✅ Automatic |
| Local First | ✅ Yes | ❌ No |
| Cloud Sync | ❌ Manual | ✅ Automatic |
| Multiple Devices | ❌ Limited | ✅ Full sync |
| Offline | ✅ Works | ❌ Needs internet |
| File Size | < 5MB typical | Unlimited |

---

## Architecture

```
Flutter App (lib/)
    ↓
Repositories (data/repositories/)
    ↓
Database Helper (database_helper.dart)
    ↓
┌─────────────────┬─────────────────┐
│                 │                 │
v                 v                 v
SQLite            MongoDB        In-Memory
(local)          (API)         (backup)
```

---

## Important Files

### Created Files:
- ✅ `lib/data/database/sqlite_database.dart` - SQLite implementation (151 lines)
- ✅ `lib/data/database/mongo_database.dart` - MongoDB API client (180 lines)
- ✅ `lib/config/database_config.dart` - Configuration switcher (28 lines)
- ✅ `server.js` - Node.js backend (188 lines)
- ✅ `DATABASE_SETUP.md` - Detailed setup guide

### Modified Files:
- ✅ `lib/data/database/database_helper.dart` - Updated to support multiple databases
- ✅ `pubspec.yaml` - Added http and mongo_dart packages

---

## API Endpoints (MongoDB Backend)

```
Customers:
  GET    /api/customers              - Get all
  POST   /api/customers              - Create new
  GET    /api/customers/:id          - Get by ID
  PUT    /api/customers/:id          - Update
  DELETE /api/customers/:id          - Delete

Transactions:
  GET    /api/transactions           - Get all
  POST   /api/transactions           - Create new
  GET    /api/transactions/customer/:customerId - Get for customer
  DELETE /api/transactions/:id       - Delete
  DELETE /api/transactions/customer/:customerId - Delete all for customer
```

---

## Switching Databases at Runtime

```dart
import 'package:credit_app/data/database/database_helper.dart';

// Switch to SQLite
DatabaseHelper.setDatabaseType(DatabaseType.sqlite);

// Switch to MongoDB
DatabaseHelper.setDatabaseType(DatabaseType.mongo);

// Check current
print(DatabaseHelper.currentDatabaseType);
```

---

## Testing

### SQLite - No setup needed
```bash
flutter run -d chrome
```

### MongoDB - Full setup
```bash
# Terminal 1: Start MongoDB
mongod

# Terminal 2: Start backend
node server.js

# Terminal 3: Start Flutter
flutter run -d chrome
```

---

## Troubleshooting

### ❌ SQLite Error
- Check `sqflite: ^2.3.0` in pubspec.yaml
- Run `flutter clean && flutter pub get`

### ❌ MongoDB Not Connecting
- Verify MongoDB is running: `mongosh` (or `mongo`)
- Check backend is running: `node server.js`
- Verify port 3000 is accessible

### ❌ API Error 404
- Backend might not be running
- Check `http://localhost:3000/api/customers` in browser
- Should return JSON array (empty is OK)

### ❌ CORS Error
- Confirm backend has `app.use(cors());`
- Server.js already includes this

---

## Next Steps

1. **Choose your database:** SQLite (default) or MongoDB
2. **If SQLite:** Just run the app normally ✅
3. **If MongoDB:** Follow setup steps above
4. **All CRUD operations work the same** regardless of choice!

---

## Data Persistence

### SQLite
- Data saved immediately to local file
- Survives app restart, browser refresh
- Zero cloud sync

### MongoDB
- Data sent to backend server
- Synced across all devices using same server
- Requires internet connection
- Better for multi-user scenarios

---

## Questions?

Both databases support:
- ✅ Customers (create, read, update, delete)
- ✅ Transactions (create, read, delete)
- ✅ Search functionality
- ✅ Debt calculation
- ✅ PDF export
- ✅ Multi-language support
- ✅ All existing features

Choose based on your needs:
- **Single user/device?** → SQLite ✨
- **Multiple devices/users?** → MongoDB 🌐
