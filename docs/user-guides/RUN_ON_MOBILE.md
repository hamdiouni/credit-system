# Run App on Mobile - Quick Guide 📱

## Current Situation

You have an Android emulator available but it's not running yet. Here's how to run your app on mobile:

## Option 1: Use Android Emulator (Recommended)

### Step 1: Launch the Emulator
```bash
flutter emulators --launch Medium_Phone_API_36.1
```

**Wait 1-2 minutes** for the emulator to fully start (you'll see the Android home screen).

### Step 2: Verify Emulator is Running
```bash
flutter devices
```

You should see something like:
```
Medium Phone API 36.1 (mobile) • emulator-5554 • android-x64 • Android 14 (API 36)
```

### Step 3: Run the App
```bash
flutter run -d emulator-5554
```

Or simply:
```bash
flutter run
```
(Flutter will auto-detect the emulator)

## Option 2: Use Physical Android Device

### Step 1: Enable Developer Mode on Your Phone
1. Go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times
3. Go back to **Settings** → **Developer Options**
4. Enable **USB Debugging**

### Step 2: Connect Phone via USB
1. Connect your Android phone to PC with USB cable
2. On phone, allow USB debugging when prompted

### Step 3: Verify Device is Connected
```bash
flutter devices
```

You should see your phone listed.

### Step 4: Run the App
```bash
flutter run
```

## Option 3: Build APK and Install Manually

### Step 1: Build APK
```bash
flutter build apk --release
```

### Step 2: Find the APK
The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Transfer to Phone
- Copy APK to phone via USB, email, or cloud storage
- On phone, open the APK file
- Allow installation from unknown sources if prompted
- Install and run

## Quick Commands Reference

```bash
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch Medium_Phone_API_36.1

# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster)
flutter run --release

# Build APK
flutter build apk --release

# Build APK (debug mode)
flutter build apk --debug
```

## Troubleshooting

### Emulator Won't Start
**Solution**: 
- Open Android Studio
- Go to Tools → AVD Manager
- Click the play button next to your emulator
- Wait for it to fully boot

### "No devices found"
**Solution**:
- Wait longer for emulator to boot (can take 2-3 minutes)
- Check USB debugging is enabled on physical device
- Try `adb devices` to see if device is recognized

### Build Errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Emulator is Slow
**Solution**:
- Close other applications
- Increase emulator RAM in Android Studio
- Use a physical device instead (much faster)

## What to Expect on Mobile

### Features That Work
✅ All customer management features
✅ Add/edit customers
✅ Add credit/payment transactions
✅ View transaction history
✅ Search and filter
✅ Multi-language support (English, French, Arabic)
✅ PDF export (opens in browser)
✅ CSV export
✅ Backup/restore
✅ User authentication
✅ Settings

### Mobile-Specific Features
✅ Touch-optimized UI
✅ Responsive layout
✅ Mobile keyboard support
✅ Share functionality for PDFs
✅ SQLite database (data persists)

### Known Differences from Desktop
- PDF export opens in mobile browser (not direct download)
- CSV export uses share dialog
- Smaller screen = more scrolling
- Touch gestures instead of mouse

## Testing Checklist

Once the app is running on mobile:

- [ ] App launches successfully
- [ ] Can create first user (if fresh install)
- [ ] Can login with PIN
- [ ] Can view customer list
- [ ] Can add new customer
- [ ] Can add credit transaction
- [ ] Can add payment transaction
- [ ] Can view customer details
- [ ] Can export PDF (opens in browser)
- [ ] Can change language
- [ ] UI looks good on mobile screen
- [ ] All buttons are touchable
- [ ] Keyboard appears for text input
- [ ] Data persists after closing app

## Performance Tips

### For Emulator
- Use x86_64 emulator (faster than ARM)
- Enable hardware acceleration
- Allocate at least 2GB RAM
- Close other apps while running

### For Physical Device
- Use USB 3.0 port for faster deployment
- Enable "Install via USB" in developer options
- Keep phone plugged in during development

## Current Status

**Available Emulator**: Medium Phone API 36.1 (Android 14)
**Status**: Not running yet
**Action Needed**: Launch the emulator and wait for it to boot

## Next Steps

1. **Launch emulator** (command above)
2. **Wait 1-2 minutes** for boot
3. **Run `flutter devices`** to verify
4. **Run `flutter run`** to start app
5. **Test all features** on mobile

---

## Quick Start (Copy-Paste)

```bash
# 1. Launch emulator (wait 1-2 minutes)
flutter emulators --launch Medium_Phone_API_36.1

# 2. Check if ready
flutter devices

# 3. Run app
flutter run

# Or build APK for manual install
flutter build apk --release
```

---

**The emulator is launching now. Wait 1-2 minutes, then run `flutter devices` to check if it's ready!** 📱
