# 🚀 QUICK START GUIDE

## Installation

### 📱 Mobile (Android)
1. Copy `build\app\outputs\flutter-apk\app-release.apk` to your phone
2. Open the file on your phone
3. Allow installation from unknown sources if prompted
4. Install and open the app

### 💻 Desktop (Windows)
1. Navigate to `build\windows\x64\runner\Release\`
2. Double-click `credit_app.exe`
3. App opens immediately (no installation needed)

### 🌐 Web
1. Open terminal in project folder
2. Run: `flutter run -d chrome`
3. App opens in Chrome browser

---

## First Time Setup

1. **Create Admin User**:
   - App opens to setup screen
   - Enter name and 4-digit PIN
   - Confirm PIN
   - Click "Create Admin User"

2. **Login**:
   - Enter your 4-digit PIN
   - Click "Login"

---

## Basic Usage

### Add Customer
1. Click "+" button (bottom right)
2. Enter customer name
3. Enter phone number (optional)
4. Click "Save"

### Add Credit (Debt)
1. Open customer detail
2. Click "Add Credit"
3. Enter amount
4. Select grocery items (optional)
5. Add note (optional)
6. Click "Save"

### Add Payment
1. Open customer detail
2. Click "Add Payment"
3. Enter amount
4. **For overpayment**: Check "Allow Overpayment" first
5. Add note (optional)
6. Click "Save"

### Change Language
1. Open Settings (⚙️ icon)
2. Click "Language"
3. Select: English / العربية / Français
4. App rebuilds with new language

### Create Backup
1. Open Settings
2. Click "Backup & Restore"
3. Click "Create Backup Now"
4. **Mobile**: Choose where to save via share dialog
5. **Desktop**: File saved to Documents folder
6. **Web**: Browser download dialog appears

### Export PDF
1. Open customer detail
2. Click "Export PDF"
3. PDF generated in current language
4. **Mobile**: Share dialog appears
5. **Desktop**: PDF opens automatically
6. **Web**: Browser download dialog

---

## Key Features

### ✅ Auto Balance Consumption
- Customer has 100 TND balance credit
- Add 150 TND new debt
- **Automatic**: Balance consumed, Debt = 50 TND

### ✅ Overpayment Protection
- Customer has 100 TND debt
- Try to pay 150 TND without checkbox → ❌ Error
- Check "Allow Overpayment" → ✅ Allowed
- Result: Debt = 0, Balance Credit = 50 TND

### ✅ Complete Translation
- Switch language in Settings
- **Everything** changes: buttons, labels, messages, items
- Arabic: RTL layout automatically applied

### ✅ Delete Customer
- Customer with transactions → ❌ Warning, blocked
- Customer without transactions → ✅ Confirmation, allowed

---

## Troubleshooting

### Mobile: "App not installed"
- Enable "Install from unknown sources" in Settings
- Or use: `adb install app-release.apk`

### Desktop: "Windows protected your PC"
- Click "More info"
- Click "Run anyway"

### Web: Slow loading
- First load takes longer (downloading assets)
- Subsequent loads are faster

### Data not saving
- Check app permissions
- Ensure sufficient storage space
- Try creating a backup first

---

## File Locations

### Mobile (Android)
- Database: `/data/data/com.example.credit_app/`
- Backups: Shared via Android share dialog

### Desktop (Windows)
- Database: `C:\Users\[YourName]\Documents\credit_app.db`
- Backups: `C:\Users\[YourName]\Documents\credit_app_backup_*.json`

### Web
- Database: Browser IndexedDB
- Backups: Browser downloads folder

---

## Tips & Tricks

1. **Search Customers**: Use search bar at top of customer list
2. **Filter Transactions**: Click filter icon in customer detail
3. **Edit Transaction**: Long press transaction → Edit
4. **Delete Transaction**: Long press transaction → Delete
5. **View Audit Log**: Settings → Audit Log (Admin only)
6. **Manage Users**: Settings → User Management (Admin only)

---

## Support

### Common Issues

**Q: How do I reset my PIN?**
A: Run `reset_pin_simple.bat` (Desktop) or reinstall app (Mobile)

**Q: Can I use on multiple devices?**
A: Yes! Use Backup/Restore to transfer data between devices

**Q: Is my data safe?**
A: Yes! Data stored locally on your device, encrypted

**Q: Can I export to Excel?**
A: Yes! Use CSV export, opens in Excel

**Q: How do I update the app?**
A: Install new APK (Mobile) or replace .exe file (Desktop)

---

## Quick Reference

### Keyboard Shortcuts (Desktop)
- `Ctrl + N`: New customer
- `Ctrl + S`: Save
- `Ctrl + F`: Search
- `Esc`: Cancel/Back

### Permissions Required
- **Mobile**: Storage (for backups), Internet (optional)
- **Desktop**: None
- **Web**: None

### Languages
- 🇬🇧 English
- 🇸🇦 العربية (Arabic) - RTL
- 🇫🇷 Français (French)

---

**Need help? Check FINAL_UPDATES_COMPLETE.md for detailed documentation!**
