@echo off
REM Testing Script for SQLite & MongoDB Data Verification
REM Run this after you've added data through the app

echo.
echo ====================================
echo  Credit App Data Verification Test
echo ====================================
echo.

echo STEP 1: Check SQLite Database File
echo ====================================
echo.
echo Looking for SQLite database at:
echo C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db
echo.

if exist "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db" (
    echo ✓ SQLite database file FOUND!
    echo.
    echo File location:
    dir "C:\Users\HP\AppData\Local\credit_app\databases\credit_app.db"
    echo.
    echo To view the data:
    echo 1. Download SQLite Browser: https://sqlitebrowser.org/
    echo 2. Open the database file above
    echo 3. View "customers" and "transactions" tables
    echo.
) else (
    echo ✗ SQLite database file NOT found yet.
    echo   Add a customer in the app first!
    echo.
)

echo STEP 2: Check MongoDB Setup
echo ====================================
echo.
echo To verify MongoDB data:
echo.
echo A) If using SQLite (default):
echo    - Data is already saved locally
echo    - No additional setup needed
echo.
echo B) If using MongoDB:
echo    1. Make sure backend is running:
echo       node server.js
echo.
echo    2. Check MongoDB connection:
echo       mongosh
echo       use credit_app
echo       show collections
echo       db.customers.find()
echo.

echo.
echo STEP 3: Verify App is Running
echo ====================================
echo.
netstat -ano | findstr ":52325" > nul
if %errorlevel% == 0 (
    echo ✓ Flutter dev server is running on port 52325
    echo   Open browser: http://localhost:52325
) else (
    echo ✗ Flutter dev server NOT running
    echo   Start with: flutter run -d chrome
)

netstat -ano | findstr ":3000" > nul
if %errorlevel% == 0 (
    echo ✓ MongoDB backend server is running on port 3000
    echo   API available at: http://localhost:3000/api
) else (
    echo - MongoDB backend server not running (OK if using SQLite)
)

echo.
echo STEP 4: Quick Test
echo ====================================
echo.
echo Try these in your browser:
echo.
echo SQLite (local database - always works):
echo   1. Open: http://localhost:52325
echo   2. Click "+ Add Customer"
echo   3. Enter name and phone
echo   4. Click "Save"
echo   5. Refresh page - data should still be there!
echo.
echo MongoDB (if backend is running):
echo   1. Make sure: node server.js is running in another terminal
echo   2. Change DatabaseType.mongo in lib/config/database_config.dart
echo   3. Restart: flutter run -d chrome
echo   4. Add customer through app
echo   5. Check MongoDB with: mongosh ^> use credit_app ^> db.customers.find()
echo.

echo.
echo ====================================
echo Testing complete!
echo ====================================
echo.
pause
