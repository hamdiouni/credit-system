# Data Persistence Guide

## Why Data Gets Deleted

Your data is **NOT deleted** when you:
- ✅ Rebuild the app (`flutter build apk`)
- ✅ Hot reload (press `r` in terminal)
- ✅ Hot restart (press `R` in terminal)
- ✅ Close and reopen the app
- ✅ Update code and run again

Your data **IS deleted** when you:
- ❌ Run `flutter clean` (deletes `.dart_tool` folder where database is stored)
- ❌ Uninstall the app from your phone
- ❌ Clear app data in phone settings

## Database Locations

### Desktop (Windows)
`C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db`

Or in development:
`.dart_tool\sqflite_common_ffi\databases\credit_app.db`

### Mobile (Android)
`/data/data/com.example.credit_app/databases/credit_app.db`

### Web
Browser localStorage (never deleted unless you clear browser data)

## How to Keep Your Data Safe

### Method 1: Use Built-in Backup Feature ✅

Your app already has a backup/restore feature!

1. **Open the app**
2. **Go to Settings** (⚙️ icon)
3. **Tap "Backup & Restore"**
4. **Tap "Create Backup"**
   - Creates a JSON file with all your data
   - Saved to Downloads folder
   - File name: `credit_app_backup_YYYY-MM-DD.json`
5. **Before running `flutter clean`**, create a backup!
6. **After rebuilding**, restore from backup:
   - Go to Settings → Backup & Restore
   - Tap "Restore from Backup"
   - Select your backup file

### Method 2: Copy Database File Manually

**Before `flutter clean`:**
```cmd
copy .dart_tool\sqflite_common_ffi\databases\credit_app.db credit_app_backup.db
```

**After rebuilding:**
```cmd
copy credit_app_backup.db .dart_tool\sqflite_common_ffi\databases\credit_app.db
```

### Method 3: Don't Use `flutter clean`

You only need `flutter clean` when:
- Switching between platforms (Android ↔ Windows ↔ Web)
- Having build errors that won't go away
- Updating dependencies

**For normal updates**, just run:
```cmd
flutter build apk --release
```

No need to clean!

## Best Practices

### During Development

1. **Create test data** that you can easily recreate
2. **Use backup feature** before major changes
3. **Avoid `flutter clean`** unless necessary

### For Production

1. **Users' data is safe** - they never run `flutter clean`
2. **Uninstalling deletes data** - warn users to backup first
3. **App updates preserve data** - data stays when updating APK

## Quick Backup Script

I'll create a script to backup your database before cleaning:

