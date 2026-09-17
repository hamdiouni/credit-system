# Update App Icon Guide

## Icon Image Provided
You have a nice grocery basket icon (red basket with fruits and bottle).

## How to Update the Icon

### Method 1: Using Online Tool (Easiest)

1. **Go to**: https://icon.kitchen/ or https://appicon.co/
2. **Upload** your grocery basket image
3. **Generate** icons for all platforms
4. **Download** the generated icons
5. **Replace** the files in these folders:
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)
   - `web/icons/Icon-192.png` (192x192)
   - `web/icons/Icon-512.png` (512x512)
   - `web/favicon.png` (32x32)
   - `windows/runner/resources/app_icon.ico` (Windows icon)

### Method 2: Using flutter_launcher_icons Package

1. **Add to pubspec.yaml** (under dev_dependencies):
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. **Add configuration** (at the end of pubspec.yaml):
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  web:
    generate: true
  windows:
    generate: true
  image_path: "assets/icon/grocery_basket.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/grocery_basket.png"
```

3. **Create folder**: `assets/icon/`

4. **Save your grocery basket image** as `assets/icon/grocery_basket.png` (1024x1024 recommended)

5. **Run**:
```cmd
flutter pub get
flutter pub run flutter_launcher_icons
```

6. **Done!** Icons generated for all platforms

### Method 3: Manual Replacement

1. **Resize your image** to these sizes using any image editor:
   - 48x48 (mdpi)
   - 72x72 (hdpi)
   - 96x96 (xhdpi)
   - 144x144 (xxhdpi)
   - 192x192 (xxxhdpi)
   - 512x512 (web)

2. **Replace files** in the folders listed in Method 1

3. **Rebuild** the app

## After Updating Icons

Rebuild the APK:
```cmd
flutter clean
flutter build apk --release
```

The new APK will have your grocery basket icon!

## Current Status

✅ App name changed to "Credit System"
✅ Grocery categories added (12 categories, 70+ items)
✅ Items grouped by category with emojis
✅ All platforms updated (Android, Web, Windows)

⏳ Icon needs to be updated manually (follow guide above)

## Quick Icon Update (Recommended)

1. Go to https://icon.kitchen/
2. Upload your grocery basket image
3. Download "Android" and "Web" icon packs
4. Extract and copy files to the folders above
5. Run: `flutter build apk --release`
