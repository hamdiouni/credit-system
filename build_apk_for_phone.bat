@echo off
echo ========================================
echo   Build APK for Manual Installation
echo ========================================
echo.

echo Building release APK...
echo This will take 2-3 minutes...
echo.

flutter build apk --release

echo.
echo ========================================
echo APK built successfully!
echo.
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo.
echo To install on your phone:
echo   1. Copy app-release.apk to your phone
echo   2. Open the file on your phone
echo   3. Tap "Install" (you may need to allow "Install from unknown sources")
echo.
echo Opening APK folder...
echo ========================================

start build\app\outputs\flutter-apk

pause
