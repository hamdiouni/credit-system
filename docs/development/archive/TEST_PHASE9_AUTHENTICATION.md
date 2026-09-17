# 🧪 Test Phase 9 - Security & Authentication

## Quick Test Guide

### ✅ Test 1: First-Time Setup
1. **Delete existing database** (if testing fresh):
   - Close app
   - Delete SQLite database file
   - Restart app

2. **Initial Setup Screen**:
   - Should see "Welcome! Let's set up your admin account"
   - Enter username: `admin`
   - Enter PIN: `1234`
   - Confirm PIN: `1234`
   - Click "Create Admin Account"
   - ✅ Should navigate to app

### ✅ Test 2: Login Flow
1. **Restart app**
2. **User Selection Screen**:
   - Should see list of users
   - Should see "admin" with Admin badge
   - Click on "admin"
3. **PIN Login Screen**:
   - Enter PIN: `1234`
   - Click "Login"
   - ✅ Should navigate to app

### ✅ Test 3: User Management (Admin)
1. **Go to Settings → Security → User Management**
2. **Add Employee**:
   - Click "Add User" button
   - Username: `employee1`
   - PIN: `5678`
   - Role: Employee
   - Click "Create"
   - ✅ Should see new user in list

3. **Reset PIN**:
   - Click menu on employee1
   - Select "Reset PIN"
   - New PIN: `9999`
   - Click "Reset"
   - ✅ Should show success message

4. **Deactivate User**:
   - Click menu on employee1
   - Select "Deactivate"
   - Confirm
   - ✅ Should show "Inactive" label

5. **Activate User**:
   - Click menu on employee1
   - Select "Activate"
   - ✅ Should remove "Inactive" label

### ✅ Test 4: Audit Log
1. **Go to Settings → Security → Audit Log**
2. **View Logs**:
   - ✅ Should see all actions (login, user created, etc.)
   - ✅ Should show timestamps (e.g., "2h ago")
   - ✅ Should show username and action

3. **Filter Logs**:
   - Click filter icon
   - Select action type: "Created user"
   - Click "Apply"
   - ✅ Should show only user creation logs

4. **Search Logs**:
   - Type "employee1" in search
   - ✅ Should show only logs related to employee1

### ✅ Test 5: Permission Checks
1. **Logout** (Settings → Security → Logout)
2. **Login as Employee**:
   - Select "employee1"
   - Enter PIN: `9999`

3. **Test Employee Permissions**:
   - Go to customer detail
   - ✅ Delete button should NOT be visible (Admin only)
   - Click transaction menu
   - ✅ Delete option should NOT be visible (Admin only)
   - Go to Settings
   - ✅ User Management should NOT be visible (Admin only)
   - ✅ Audit Log should NOT be visible (Admin only)

4. **Logout and Login as Admin**:
   - ✅ All features should be visible

### ✅ Test 6: Change PIN
1. **Go to Settings → Security → Change PIN**
2. **Change PIN**:
   - Current PIN: `1234`
   - New PIN: `4321`
   - Confirm: `4321`
   - Click "Change"
   - ✅ Should show success message

3. **Test New PIN**:
   - Logout
   - Login with new PIN: `4321`
   - ✅ Should work

### ✅ Test 7: Auto-Lock
1. **Go to Settings → Security → Auto-Lock Timeout**
2. **Set to 1 minute**
3. **Wait 1 minute without interaction**
4. **Try to navigate**:
   - ✅ Should redirect to PIN login
   - ✅ Should show "Session locked" message

### ✅ Test 8: Failed Login
1. **Logout**
2. **Try wrong PIN**:
   - Enter: `0000`
   - ✅ Should show "Invalid PIN" error
   - ✅ Should not navigate to app

### ✅ Test 9: Cannot Delete Self
1. **Login as Admin**
2. **Go to User Management**
3. **Try to delete admin (yourself)**:
   - Click menu on admin
   - ✅ Delete option should NOT be visible

### ✅ Test 10: Audit Trail Verification
1. **Perform various actions**:
   - Add a customer
   - Add a transaction
   - Delete a transaction (as admin)
   - Create a user
   - Change settings

2. **Check Audit Log**:
   - ✅ All actions should be logged
   - ✅ Each log should have:
     - Username
     - Action type
     - Timestamp
     - Entity details (if applicable)

---

## 🎯 Expected Results

### All Tests Should Pass ✅
- First-time setup works
- Login/logout works
- User management works (Admin only)
- Audit logging works
- Permission checks work
- Auto-lock works
- PIN changes work
- Failed logins handled gracefully

### Code Quality ✅
```bash
flutter analyze
# Should show: 4 issues found (2 dart:html warnings only)
```

---

## 🐛 Common Issues

### Issue: "User not found"
**Solution**: Make sure you created the admin account in initial setup

### Issue: "Invalid PIN"
**Solution**: Check if you changed the PIN. Default is `1234`

### Issue: Database error
**Solution**: Delete the SQLite database and restart app for fresh setup

### Issue: Auto-lock not working
**Solution**: Make sure you set the timeout and waited long enough

---

## 📱 Test on Multiple Platforms

### Android
```bash
flutter run -d android
```

### Windows
```bash
flutter run -d windows
```

### Web
```bash
flutter run -d chrome
```

All authentication features should work on all platforms!

---

**Happy Testing! 🎉**
