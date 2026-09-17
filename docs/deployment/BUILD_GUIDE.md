# 🚀 Build Guide - Android APK & Windows Desktop EXE

## Quick Start

### Build Android APK
```bash
# Double-click this file:
build_android.bat
```

### Build Windows Desktop EXE
```bash
# Double-click this file:
build_windows.bat
```

---

## 📱 Android APK Build

### Prerequisites
- ✅ Android Studio installed
- ✅ Android SDK installed
- ✅ Internet connection (for first build)

### Build Steps

**1. Run the build script:**
```bash
build_android.bat
```

**2. Wait for build to complete:**
- First build: 5-10 minutes (downloading Gradle dependencies)
- Subsequent builds: 1-2 minutes

**3. Find your APK:**
```
build\app\outputs\flutter-apk\app-release.apk
```

**4. Install on Android phone:**
- Copy APK to phone (USB, email, cloud, etc.)
- Open APK file on phone
- Allow "Install from Unknown Sources" if prompted
- Tap "Install"
- Done!

### APK Details
- **Size**: ~20-30 MB
- **Minimum Android**: 5.0 (API 21)
- **Target Android**: 14 (API 34)
- **Architecture**: Universal (works on all devices)

---

## 🖥️ Windows Desktop EXE Build

### Prerequisites
- ✅ Visual Studio 2022 with C++ workload
- ✅ Windows 10 or higher

### Current Status Check

Run this to check if Visual Studio is ready:
```bash
flutter doctor -v
```

**If you see:**
```
[√] Visual Studio - develop Windows apps
```
✅ You're ready to build!

**If you see:**
```
[X] Visual Studio - develop Windows apps
```
❌ You need to install/fix Visual Studio first.

### Fix Visual Studio (If Needed)

**1. Download Visual Studio 2022 Community (FREE):**
- Go to: https://visualstudio.microsoft.com/downloads/
- Click "Download Visual Studio 2022 Community"

**2. Install with C++ workload:**
- Run the installer
- When asked to select workloads, check:
  - ✅ **Desktop development with C++**
- Click "Install"
- Wait 10-15 minutes

**3. Restart your computer**

**4. Verify installation:**
```bash
flutter doctor -v
```

Should now show:
```
[√] Visual Studio - develop Windows apps
```

### Build Steps

**1. Run the build script:**
```bash
build_windows.bat
```

**2. Wait for build to complete:**
- Takes 2-5 minutes

**3. Find your executable:**
```
build\windows\x64\runner\Release\
```

**4. Distribute:**
- Copy the **entire Release folder**
- Share with users
- They run `credit_app.exe` directly (no installation needed)

### EXE Details
- **Size**: ~15-20 MB (entire folder)
- **Minimum Windows**: Windows 10
- **Architecture**: x64 (64-bit)
- **Dependencies**: Included in Release folder

---

## 📦 Build Outputs

### Android APK
```
build\app\outputs\flutter-apk\
└── app-release.apk (20-30 MB)
```

**What's included:**
- Complete app
- All assets and resources
- SQLite database support
- All dependencies bundled

**How to distribute:**
- Single APK file
- Email, cloud storage, or USB transfer
- Users install directly on phone

### Windows EXE
```
build\windows\x64\runner\Release\
├── credit_app.exe (main executable)
├── flutter_windows.dll
├── various other DLLs
└── data\ (assets folder)
```

**What's included:**
- Complete app
- All assets and resources
- SQLite database support
- All dependencies bundled

**How to distribute:**
- Zip the entire Release folder
- Share ZIP file
- Users extract and run credit_app.exe

---

## 🧪 Testing Your Builds

### Test Android APK

**On Physical Device:**
1. Enable USB debugging on phone
2. Connect phone via USB
3. Run: `flutter install`
4. Or manually install the APK

**On Emulator:**
1. Start Android emulator
2. Run: `flutter install`
3. Or drag APK to emulator

**Test Checklist:**
- [ ] App installs successfully
- [ ] App launches without crashes
- [ ] Can add customer
- [ ] Can add credit/payment
- [ ] Can edit transaction
- [ ] Can delete transaction
- [ ] Search works
- [ ] Filter works
- [ ] CSV export (share dialog)
- [ ] PDF export (share dialog)
- [ ] Data persists after restart
- [ ] Language switching works

### Test Windows EXE

**Run from build folder:**
```bash
cd build\windows\x64\runner\Release
.\credit_app.exe
```

**Test Checklist:**
- [ ] App launches without errors
- [ ] Can add customer
- [ ] Can add credit/payment
- [ ] Can edit transaction
- [ ] Can delete transaction
- [ ] Search works
- [ ] Filter works
- [ ] CSV export (downloads file)
- [ ] PDF export (downloads file)
- [ ] Data persists after restart
- [ ] Language switching works
- [ ] Window can be resized

---

## 🔧 Troubleshooting

### Android Build Issues

**Problem: "Gradle build failed"**
```bash
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

**Problem: "SDK licenses not accepted"**
```bash
flutter doctor --android-licenses
# Press 'y' to accept all
```

**Problem: "Build takes too long"**
- First build downloads dependencies (5-10 min)
- This is normal
- Subsequent builds are much faster

**Problem: "No space left on device"**
- Free up disk space (need ~2GB)
- Clean old builds: `flutter clean`

### Windows Build Issues

**Problem: "Unable to find suitable Visual Studio toolchain"**
- Install Visual Studio 2022 Community
- Select "Desktop development with C++"
- Restart computer
- Run `flutter doctor -v` to verify

**Problem: "CMake not found"**
- Install Visual Studio with C++ workload
- CMake is included in the C++ workload

**Problem: "Windows SDK not found"**
- Open Visual Studio Installer
- Modify installation
- Add Windows 10/11 SDK
- Restart

**Problem: "Build failed with error code 1"**
```bash
flutter clean
flutter pub get
flutter build windows --release
```

---

## 📊 Build Comparison

| Aspect | Android APK | Windows EXE |
|--------|-------------|-------------|
| **Build Time (First)** | 5-10 minutes | 2-5 minutes |
| **Build Time (Next)** | 1-2 minutes | 1-2 minutes |
| **Output Size** | 20-30 MB | 15-20 MB |
| **Distribution** | Single APK file | Folder with EXE + DLLs |
| **Installation** | Install APK | Extract and run |
| **Prerequisites** | Android Studio | Visual Studio 2022 |

---

## 🎯 Quick Commands Reference

### Check Setup
```bash
flutter doctor -v
flutter devices
```

### Clean Build
```bash
flutter clean
flutter pub get
```

### Build Android APK
```bash
flutter build apk --release
```

### Build Windows EXE
```bash
flutter build windows --release
```

### Install on Connected Device
```bash
flutter install
```

### Run in Debug Mode
```bash
flutter run -d windows
flutter run -d android
```

---

## 📱 Distribution Guide

### Android APK Distribution

**For Testing:**
- Email APK to testers
- Upload to Google Drive/Dropbox
- Share via messaging apps

**For Production (Google Play):**
1. Build App Bundle:
   ```bash
   flutter build appbundle --release
   ```
2. Create Google Play Developer account ($25 one-time)
3. Upload AAB to Google Play Console
4. Fill in app details
5. Submit for review

### Windows EXE Distribution

**For Testing:**
1. Zip the Release folder:
   ```bash
   cd build\windows\x64\runner
   # Right-click Release folder → Send to → Compressed folder
   ```
2. Share ZIP file
3. Users extract and run credit_app.exe

**For Production:**
1. Create installer with Inno Setup or NSIS
2. Optionally sign the executable
3. Distribute installer

---

## ✅ Final Checklist

### Before Building Android APK
- [ ] Android Studio installed
- [ ] Android SDK installed
- [ ] Internet connection available
- [ ] At least 2GB free disk space

### Before Building Windows EXE
- [ ] Visual Studio 2022 installed
- [ ] "Desktop development with C++" workload selected
- [ ] Computer restarted after VS installation
- [ ] `flutter doctor -v` shows Visual Studio ready

### After Building
- [ ] Build completed successfully
- [ ] Output files exist
- [ ] Tested on target platform
- [ ] All features work correctly
- [ ] Ready to distribute

---

## 🎉 Success!

Once you have your builds:

**Android APK:**
- Install on any Android phone (5.0+)
- All 35+ features work
- Data persists locally
- Share with users via APK file

**Windows EXE:**
- Run on any Windows PC (10+)
- All 35+ features work
- Data persists locally
- Share with users via ZIP file

Your app is production-ready! 🚀
