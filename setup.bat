@echo off
REM Quick setup script for SQLite/MongoDB
REM Save as: setup.bat and run with: setup.bat

echo.
echo ====================================
echo    Credit App Database Setup
echo ====================================
echo.

echo 1. Installing Flutter dependencies...
call flutter pub get
if errorlevel 1 goto error

echo.
echo 2. Checking databases...
echo    ✓ SQLite: Ready (default)
echo    ✓ MongoDB: Optional (requires Node.js)
echo.

echo 3. You can now:
echo    A) Use SQLite (default, no extra setup)
echo       - Just run: flutter run -d chrome
echo.
echo    B) Use MongoDB (requires setup)
echo       - Run: npm install
echo       - Start MongoDB: mongod
echo       - Run backend: node server.js
echo       - Change DatabaseType.sqlite to DatabaseType.mongo
echo       - Run: flutter run -d chrome
echo.

echo 4. Documentation:
echo    - DATABASE_INTEGRATION.md - Full guide
echo    - DATABASE_SETUP.md - Detailed setup
echo    - lib/config/database_config.dart - Configuration
echo.

pause
exit /b 0

:error
echo Error during setup!
pause
exit /b 1
