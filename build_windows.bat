@echo off
cls
echo.
echo ============================================================
echo    BUILDING WINDOWS DESKTOP EXE - Credit Management App
echo ============================================================
echo.
echo This will build a Windows executable that can run on
echo any Windows PC without installation.
echo.
pause

echo.
echo Checking Visual Studio installation...
echo.
call flutter doctor -v | findstr /C:"Visual Studio"

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
echo [3/3] Building Windows executable (please wait)...
echo.
call flutter build windows --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================================
    echo    BUILD SUCCESSFUL!
    echo ============================================================
    echo.
    echo Your executable has been created at:
    echo %CD%\build\windows\x64\runner\Release\credit_app.exe
    echo.
    echo Folder Size: Approximately 15-20 MB
    echo.
    echo NEXT STEPS:
    echo 1. Copy the entire "Release" folder
    echo 2. Share it with anyone
    echo 3. They can run credit_app.exe directly (no installation needed)
    echo.
    echo IMPORTANT: You must share the entire Release folder,
    echo not just the EXE file. It needs the DLL files too.
    echo.
    echo Opening the output folder...
    start "" "%CD%\build\windows\x64\runner\Release"
) else (
    echo.
    echo ============================================================
    echo    BUILD FAILED!
    echo ============================================================
    echo.
    echo Visual Studio Build Tools are incomplete or missing.
    echo.
    echo TO FIX THIS ISSUE:
    echo.
    echo 1. Download Visual Studio 2022 Community (FREE) from:
    echo    https://visualstudio.microsoft.com/downloads/
    echo.
    echo 2. During installation, make sure to select:
    echo    [X] Desktop development with C++
    echo.
    echo 3. After installation completes:
    echo    - Restart your computer
    echo    - Run this script again
    echo.
    echo 4. To verify the fix worked, run:
    echo    flutter doctor -v
    echo.
    echo    You should see:
    echo    [√] Visual Studio - develop Windows apps
    echo.
)

echo.
pause
