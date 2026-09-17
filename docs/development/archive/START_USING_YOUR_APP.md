# 🚀 Start Using Your App - Quick Guide

## ✅ Everything is Ready!

Your Credit Manager app is now fully functional on all platforms with all Phase 9-14 features working.

---

## 🎯 Quick Start

### Option 1: Windows (Ready Now)
The app is already running on your Windows machine!

**What you see**: User selection screen with 2 users

**Next steps**:
1. Click on a user
2. Enter their PIN (4 digits)
3. Start using the app!

### Option 2: Android (Install APK)
Your Android APK is ready to install!

**Location**: `build\app\outputs\flutter-apk\app-release.apk`
**Size**: 63.2 MB

**How to install**:
1. Copy APK to your Android phone
2. Enable "Install from Unknown Sources" in Settings
3. Tap the APK file
4. Install and launch!

---

## 🔐 First Time Setup

If you're starting fresh (no users exist):

1. **Initial Setup Screen** appears
2. Enter username (e.g., "admin")
3. Enter PIN (4-6 digits, e.g., "1234")
4. Click "Create User"
5. You're in!

---

## 📱 Main Features

### Customer Management
- **Add Customer**: Click + button
- **View Details**: Tap customer card
- **Edit Customer**: Open details → Edit icon
- **Search**: Use search bar at top

### Transaction Management
- **Add Credit**: Customer details → "Add Credit" button
- **Add Payment**: Customer details → "Add Payment" button
- **View History**: Customer details → Transaction list
- **Edit Transaction**: Tap transaction → Edit

### Export & Reports
- **Export PDF**: Customer details → Export icon
- **Export CSV**: Settings → Data Management → Data Migration
- **Arabic Support**: PDFs automatically support Arabic text

---

## ⚙️ Phase 9-14 Features

### User Management
**Location**: Settings → System → User Management

**What you can do**:
- Create new users (Admin or Employee)
- Set user roles and permissions
- Activate/deactivate users
- Reset user PINs
- View user activity

### Backup & Restore
**Location**: Settings → Data Management → Backup & Restore

**What you can do**:
- Create full database backup
- Restore from backup file
- View backup history
- Automatic backups on critical operations

### System Monitoring
**Location**: Settings → System → System Monitoring

**What you can do**:
- View performance metrics
- Check database health
- Monitor memory usage
- Track response times
- View error logs

### Audit Logs
**Location**: Settings → System → Audit Logs

**What you can do**:
- View all user actions
- Filter by user, action, or date
- Export audit logs
- Monitor security events

### Data Migration
**Location**: Settings → Data Management → Data Migration

**What you can do**:
- Import customers from CSV
- Export data to CSV
- Validate imported data
- View migration history

---

## 🗄️ Your Data

### Windows
**Database**: SQLite
**Location**: `.dart_tool\sqflite_common_ffi\databases\credit_app.db`
**Persistence**: ✅ YES - Data survives app restart

### Android
**Database**: SQLite
**Location**: App documents directory
**Persistence**: ✅ YES - Data survives app restart

### Web (if you use it)
**Database**: InMemoryDatabase
**Location**: Browser memory
**Persistence**: ❌ NO - Data lost on refresh (by design)

---

## 🎯 Test Data Persistence

Want to verify your data is saved?

1. Add a customer (e.g., "Test Customer")
2. Close the app completely
3. Reopen the app
4. Login again
5. **Check**: "Test Customer" should still be there ✅

---

## 👥 User Roles

### Admin
**Can do everything**:
- Manage customers and transactions
- Create/edit/delete users
- Access all settings
- View audit logs
- Create backups
- Delete data

### Employee
**Limited access**:
- Manage customers and transactions
- Export data
- View their own activity
- Cannot manage users
- Cannot delete data
- Cannot change settings

---

## 🔒 Security Features

### PIN Authentication
- 4-6 digit PIN
- Hashed storage (secure)
- Auto-lock after inactivity
- Failed login tracking

### Auto-Lock
- Configurable timeout (5-60 minutes)
- Locks after inactivity
- Requires PIN to unlock

### Audit Logging
- All actions logged
- User tracking
- Timestamp recording
- Cannot be deleted by employees

---

## 📊 Common Tasks

### Add a Customer
1. Click + button (bottom right)
2. Enter customer name
3. Enter phone (optional)
4. Enter address (optional)
5. Click "Save"

### Record a Credit (Customer Bought Something)
1. Open customer details
2. Click "Add Credit"
3. Enter amount
4. Add note (optional)
5. Click "Save"

### Record a Payment (Customer Paid)
1. Open customer details
2. Click "Add Payment"
3. Enter amount
4. Add note (optional)
5. Click "Save"

### Export Customer Statement
1. Open customer details
2. Click export icon (top right)
3. Choose format (PDF or CSV)
4. Share or save

### Create Backup
1. Go to Settings
2. Data Management → Backup & Restore
3. Click "Create Backup"
4. Backup saved automatically

### Create New User
1. Go to Settings
2. System → User Management
3. Click "Add User"
4. Enter username and PIN
5. Select role (Admin/Employee)
6. Click "Create"

---

## 🐛 Troubleshooting

### App won't start?
- Try: `flutter clean` then `flutter run -d windows`

### Data not saving?
- Check: Database type should be "SQLite" (not InMemory)
- Windows: Look for `.dart_tool\sqflite_common_ffi\databases\credit_app.db`

### Can't see Phase 9-14 features?
- Go to Settings (⚙️ icon)
- Scroll down to "System" section
- Scroll down to "Data Management" section
- All features are there!

### Permission errors?
- Make sure you're logged in as Admin
- Employees have limited permissions

### Android APK won't install?
- Enable "Install from Unknown Sources"
- Settings → Security → Unknown Sources → Enable

---

## 📞 Quick Reference

### File Locations
- **Android APK**: `build\app\outputs\flutter-apk\app-release.apk`
- **Windows Database**: `.dart_tool\sqflite_common_ffi\databases\credit_app.db`
- **Backups**: App documents directory

### Commands
- **Run Windows**: `flutter run -d windows`
- **Build Android**: `flutter build apk --release`
- **Run Web**: `flutter run -d chrome`
- **Clean**: `flutter clean`

### Settings Locations
- **User Management**: Settings → System → User Management
- **Audit Logs**: Settings → System → Audit Logs
- **Monitoring**: Settings → System → System Monitoring
- **Backup**: Settings → Data Management → Backup & Restore
- **Migration**: Settings → Data Management → Data Migration

---

## 🎉 You're All Set!

Your app is ready to use with:
- ✅ Full database persistence
- ✅ User authentication
- ✅ All Phase 9-14 features
- ✅ Windows app running
- ✅ Android APK ready
- ✅ Professional PDF export
- ✅ Backup & restore
- ✅ Audit logging
- ✅ System monitoring
- ✅ Data migration

**Start using your app now!** 🚀

