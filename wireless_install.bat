@echo off
echo ========================================
echo   Wireless Installation Setup
echo ========================================
echo.

echo FIRST TIME SETUP (USB cable required):
echo.
echo Step 1: Connect your phone via USB cable
echo Step 2: Make sure USB debugging is enabled
echo.
pause

echo.
echo Enabling wireless debugging...
adb tcpip 5555

echo.
echo ========================================
echo Now disconnect the USB cable!
echo ========================================
echo.
pause

echo.
echo Enter your phone's IP address (find it in Settings → About Phone → Status):
set /p PHONE_IP="IP Address: "

echo.
echo Connecting to %PHONE_IP%:5555...
adb connect %PHONE_IP%:5555

echo.
echo Checking connection...
adb devices

echo.
echo If you see your device listed, press any key to install the app...
pause

echo.
echo Installing app wirelessly...
flutter run --release

echo.
echo ========================================
echo Installation complete!
echo.
echo To disconnect wireless mode:
echo   adb disconnect
echo ========================================
pause
