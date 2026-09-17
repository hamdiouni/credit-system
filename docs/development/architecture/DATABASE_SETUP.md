# Database Setup Guide - SQLite3 & MongoDB

## Current Status
✅ **SQLite3**: Configured and ready (default)
✅ **MongoDB**: API backend created

---

## Option 1: Use SQLite3 (Recommended for Local)

SQLite is the default. Data persists locally on each device.

**No setup needed!** Just run:
```bash
flutter run -d chrome
```

Data is automatically saved to local SQLite database.

---

## Option 2: Use MongoDB (Cloud/Server)

### Prerequisites
- Node.js installed
- MongoDB running (local or Atlas)

### Step 1: Install Backend Dependencies
```bash
cd credit_app
npm install express mongoose cors dotenv
```

### Step 2: Create `.env` file in project root
```
MONGODB_URI=mongodb://localhost:27017/credit_app
PORT=3000
```

For MongoDB Atlas (Cloud), use:
```
MONGODB_URI=mongodb+srv://<username>:<password>@<cluster>.mongodb.net/credit_app
```

### Step 3: Start MongoDB Backend
```bash
node server.js
```

Output should be:
```
MongoDB Backend Server running on http://localhost:3000
MongoDB Connection: mongodb://localhost:27017/credit_app
```

### Step 4: Switch Flutter App to MongoDB

In `lib/data/database/database_helper.dart`, change:
```dart
static DatabaseType _dbType = DatabaseType.mongo; // Changed from sqlite
```

### Step 5: Run Flutter App
```bash
flutter run -d chrome
```

---

## Option 3: Hybrid (SQLite Local + MongoDB Cloud)

Use SQLite locally, sync to MongoDB periodically:

In your provider, implement sync logic:
```dart
Future<void> syncWithMongo() async {
  // Get data from SQLite
  final customers = await sqliteDb.getAllCustomers();
  
  // Push to MongoDB
  for (var customer in customers) {
    await mongoDb.addCustomer(customer);
  }
}
```

---

## Switching Databases at Runtime

```dart
// Switch to SQLite
DatabaseHelper.setDatabaseType(DatabaseType.sqlite);

// Switch to MongoDB
DatabaseHelper.setDatabaseType(DatabaseType.mongo);

// Check current
print(DatabaseHelper.currentDatabaseType);
```

---

## MongoDB Connection URLs

### Local MongoDB
```
mongodb://localhost:27017/credit_app
```

Ensure MongoDB is running:
```bash
mongod
```

### MongoDB Atlas (Cloud)
1. Create account at https://cloud.mongodb.com
2. Create cluster
3. Get connection string:
   ```
   mongodb+srv://username:password@cluster.mongodb.net/credit_app
   ```

---

## Database Comparison

| Feature | SQLite | MongoDB |
|---------|--------|---------|
| Setup | Zero config | Needs backend |
| Persistence | Local file | Cloud/Server |
| Sync | Manual | Built-in |
| Multi-device | Files only | Full sync |
| Cost | Free | Free tier available |
| Scale | Good for <10MB | Unlimited |

---

## Testing Data

Both databases support the same models:
- Customer: id, name, phone, createdAt
- Transaction: id, customerId, type, amount, note, selectedItems, createdAt

Create test data through the app UI or API:

### Via API (MongoDB)
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{"name": "Ali", "phone": "21843944", "createdAt": "2026-01-27T10:00:00"}'
```

---

## Troubleshooting

### SQLite Issues
- Check `pubspec.yaml` has `sqflite: ^2.3.0`
- Ensure `path_provider` is installed

### MongoDB Issues
- Check `server.js` is running on port 3000
- Verify MongoDB connection string in `.env`
- Check network access if using Atlas

### API Errors
- If MongoDB API returns 404: Ensure backend server is running
- If CORS error: Backend already has `cors()` middleware configured

---

## Files Created
- ✅ `lib/data/database/sqlite_database.dart` - SQLite implementation
- ✅ `lib/data/database/mongo_database.dart` - MongoDB API client
- ✅ `lib/data/database/database_helper.dart` - Database switcher
- ✅ `server.js` - Node.js/Express backend
- ✅ `pubspec.yaml` - Updated with http and mongo_dart packages

---

## Next Steps
1. Choose SQLite (default) or MongoDB
2. If MongoDB: Install Node.js packages and start backend
3. Run Flutter app normally
4. All CRUD operations work the same regardless of database!
