# Comprehensive Test Plan - All Features

## Pre-Test Setup

### 1. Clear All Data
```bash
clear_all_data.bat
flutter pub get
```

### 2. Run App
```bash
# For Windows
flutter run -d windows

# For Web
flutter run -d chrome

# For Android
flutter run -d android
```

## Test Checklist

### Phase 1-8: Core Features (Already Implemented)

#### Customer Management
- [ ] Add new customer
- [ ] Edit customer
- [ ] Delete customer
- [ ] Search customers
- [ ] View customer details
- [ ] **VERIFY**: Customer persists after app restart

#### Transaction Management
- [ ] Add credit transaction
- [ ] Add payment transaction
- [ ] Edit transaction
- [ ] Delete transaction
- [ ] View transaction history
- [ ] **VERIFY**: Transactions persist after app restart

#### PDF Export
- [ ] Export customer report
- [ ] Verify Arabic text displays correctly
- [ ] Verify RTL layout
- [ ] Verify all transaction details included

#### CSV Export
- [ ] Export data to CSV
- [ ] Verify file downloads/saves
- [ ] Verify data is complete

#### Multi-Language
- [ ] Switch to Arabic
- [ ] Switch to French
- [ ] Switch to English
- [ ] **VERIFY**: Language preference persists

### Phase 9: Security & Authentication ✅

**Location**: Settings → System → User Management

#### Initial Setup (First Time)
- [ ] App shows "Initial Setup" screen
- [ ] Can create admin user
- [ ] Username validation works
- [ ] PIN validation works (4-6 digits)
- [ ] **VERIFY**: User is created in database

#### User Management (Admin Only)
- [ ] Navigate to Settings → System → User Management
- [ ] Can see list of users
- [ ] Can create new user (employee role)
- [ ] Can edit user
- [ ] Can deactivate user
- [ ] Can activate user
- [ ] Can reset user PIN
- [ ] **VERIFY**: Changes persist after app restart

#### Authentication
- [ ] Logout from user menu
- [ ] See user selection screen
- [ ] Can login with correct PIN
- [ ] Cannot login with wrong PIN
- [ ] Auto-lock after inactivity (5 minutes default)
- [ ] **VERIFY**: Session persists until timeout

#### Audit Logs
- [ ] Navigate to Settings → System → Audit Logs
- [ ] Can see list of all actions
- [ ] Shows user who performed action
- [ ] Shows timestamp
- [ ] Shows action type (login, create, edit, delete)
- [ ] Can filter by user
- [ ] Can filter by action type
- [ ] **VERIFY**: Logs persist after app restart

### Phase 10: Backup & Restore ✅

**Location**: Settings → Data Management → Backup & Restore

#### Backup
- [ ] Navigate to Backup & Restore
- [ ] Click "Create Backup"
- [ ] Backup file is created
- [ ] Backup includes customers
- [ ] Backup includes transactions
- [ ] Backup includes users
- [ ] Backup includes audit logs
- [ ] Can share backup file
- [ ] **VERIFY**: Backup file is valid JSON

#### Restore - Replace Mode
- [ ] Click "Restore from Backup"
- [ ] Select backup file
- [ ] Choose "Replace" mode
- [ ] Confirm action
- [ ] All data is replaced
- [ ] **VERIFY**: Old data is gone, new data is present

#### Restore - Merge Mode
- [ ] Create some test data
- [ ] Restore from backup
- [ ] Choose "Merge" mode
- [ ] Confirm action
- [ ] Old data is kept
- [ ] New data from backup is added
- [ ] **VERIFY**: Both old and new data present

### Phase 11: PDF Enhancements ✅

**Already Tested**: Arabic PDF with proper letter joining

- [ ] Export PDF with Arabic customer name
- [ ] Verify letters are joined correctly (not separated)
- [ ] Verify RTL text direction
- [ ] Verify Arabic font is used
- [ ] **VERIFY**: PDF looks professional

### Phase 12: Monitoring & Observability ✅

**Location**: Settings → System → System Monitoring

#### Error Logging
- [ ] Navigate to System Monitoring
- [ ] Click "Error Logs" tab
- [ ] Can see list of errors (if any)
- [ ] Shows error message
- [ ] Shows timestamp
- [ ] Shows stack trace
- [ ] Can clear error logs
- [ ] **VERIFY**: Errors are logged when they occur

#### Performance Tracking
- [ ] Click "Performance" tab
- [ ] Can see list of operations
- [ ] Shows operation name
- [ ] Shows duration
- [ ] Shows timestamp
- [ ] Can see slow operations highlighted
- [ ] **VERIFY**: Operations are tracked

#### Health Checks
- [ ] Click "Health" tab
- [ ] Shows database status
- [ ] Shows memory usage
- [ ] Shows app version
- [ ] Shows platform info
- [ ] All checks show "Healthy"
- [ ] **VERIFY**: Health status is accurate

### Phase 13: Data Migration ✅

**Location**: Settings → Data Management → Data Migration

#### MongoDB to SQLite Migration
- [ ] Navigate to Data Migration
- [ ] See migration options
- [ ] Can configure MongoDB connection
- [ ] Can test connection
- [ ] Can start migration
- [ ] Shows progress
- [ ] Shows results (customers/transactions migrated)
- [ ] **VERIFY**: Data is migrated correctly

### Phase 14: Maintenance & Reliability ✅

**Already Implemented**: Error boundaries, logging, error handling

- [ ] App doesn't crash on errors
- [ ] Errors are logged
- [ ] User sees friendly error messages
- [ ] App recovers from errors
- [ ] **VERIFY**: App is stable

## Critical Tests

### Data Persistence (MOST IMPORTANT)

#### Test 1: Customer Persistence
1. Add a customer named "Test Customer"
2. Close the app completely
3. Reopen the app
4. **VERIFY**: "Test Customer" is still there

#### Test 2: Transaction Persistence
1. Add a credit transaction for 100
2. Close the app completely
3. Reopen the app
4. **VERIFY**: Transaction is still there

#### Test 3: User Persistence
1. Create a new user
2. Close the app completely
3. Reopen the app
4. Login as the new user
5. **VERIFY**: User can login

#### Test 4: Settings Persistence
1. Change language to Arabic
2. Close the app completely
3. Reopen the app
4. **VERIFY**: Language is still Arabic

## Platform-Specific Tests

### Windows
- [ ] All features work
- [ ] Data persists after app close
- [ ] Database file exists at: `.dart_tool\sqflite_common_ffi\databases\credit_app.db`
- [ ] File size increases when adding data

### Web
- [ ] Core features work (customers, transactions)
- [ ] PDF export works
- [ ] CSV export works
- [ ] **EXPECTED**: Data lost on page refresh (InMemoryDatabase)
- [ ] **EXPECTED**: No authentication (by design)
- [ ] **EXPECTED**: No Phase 9-14 features (require SQLite)

### Android
- [ ] All features work
- [ ] Data persists after app close
- [ ] Database file exists in app data folder
- [ ] Performance is good

## Troubleshooting

### If Data Doesn't Persist

1. Check console output for database type:
   ```
   📊 [Main] Database type: SQLite  ← Should be SQLite, not InMemory
   ```

2. Check if database file exists:
   ```bash
   dir .dart_tool\sqflite_common_ffi\databases\credit_app.db
   ```

3. Check file size increases:
   ```bash
   # Before adding data
   dir .dart_tool\sqflite_common_ffi\databases\credit_app.db
   
   # Add some data
   
   # After adding data (should be larger)
   dir .dart_tool\sqflite_common_ffi\databases\credit_app.db
   ```

### If Phase 9-14 Features Not Visible

1. Go to Settings screen
2. Scroll down to "System" section
3. Should see:
   - User Management
   - Audit Logs
   - System Monitoring
4. Scroll to "Data Management" section
5. Should see:
   - Backup & Restore
   - Data Migration

### If FormatException Occurs

1. Run: `clear_all_data.bat`
2. Run: `flutter pub get`
3. Run: `flutter run -d windows`
4. Check console for specific error

## Success Criteria

✅ **Core Features**: All working
✅ **Data Persistence**: Data survives app restart
✅ **Phase 9**: Authentication and audit logs working
✅ **Phase 10**: Backup and restore working
✅ **Phase 12**: Monitoring screens accessible
✅ **Phase 13**: Data migration screen accessible
✅ **Phase 14**: Error handling working
✅ **All Platforms**: Windows, Web, Android all working

## Reporting Issues

If any test fails, report:
1. Which test failed
2. What platform (Windows/Web/Android)
3. Console output (copy full output)
4. Steps to reproduce
5. Expected vs actual behavior
