@echo off
cls
echo.
echo ============================================================
echo    BUILDING ANDROID APK - Credit Management App
echo ============================================================
echo.
echo This will build a release APK that you can install on
echo any Android phone (Android 5.0 or higher).
echo.
echo First build may take 5-10 minutes (downloading dependencies)
echo Subsequent builds will be much faster (1-2 minutes).
echo.
pause

echo.
echo [1/3] Cleaning previous builds...
call flutter clean
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo.
echo [2/3] Getting dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo.
echo [3/3] Building APK (please wait, this may take several minutes)...
echo.
call flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================
    echo    BUILD SUCCESSFUL!
    echo ============================================================
    echo.
    echo Your APK has been created at:
    echo %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo APK Size: Approximately 20-30 MB
    echo.
    echo NEXT STEPS:
    echo 1. Copy app-release.apk to your Android phone
    echo 2. Open the APK file on your phone
    echo 3. Allow "Install from Unknown Sources" if prompted
    echo 4. Tap "Install"
    echo 5. Open the app and enjoy!
    echo.
    echo Opening the output folder...
    start "" "%CD%\build\app\outputs\flutter-apk"
) else (
    echo.
    echo ============================================================
    echo    BUILD FAILED!
    echo ============================================================
    echo.
    echo Possible issues:
    echo - Android SDK not properly configured
    echo - Internet connection required for first build
    echo - Gradle dependencies download failed
    echo.
    echo Try running: flutter doctor -v
    echo.
)

echo.
pause
