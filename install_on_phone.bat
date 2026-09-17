@echo off
echo ========================================
echo   Install Credit App on Your Phone
echo ========================================
echo.

echo Step 1: Checking if phone is connected...
adb devices
echo.

echo If you see your device listed above, press any key to continue...
echo If NOT, make sure:
echo   1. USB Debugging is enabled on your phone
echo   2. Phone is connected via USB cable
echo   3. You allowed USB debugging on your phone
echo.
pause

echo.
echo Step 2: Installing app on your phone...
echo This will take 1-2 minutes...
echo.

flutter run --release

echo.
echo ========================================
echo Installation complete!
echo The app is now installed on your phone.
echo You can disconnect the USB cable.
echo ========================================
pause
