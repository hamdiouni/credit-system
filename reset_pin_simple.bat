@echo off
echo ========================================
echo Credit App - Quick PIN Reset
echo ========================================
echo.
echo Your database is at:
echo .dart_tool\sqflite_common_ffi\databases\credit_app.db
echo.
echo OPTION 1: Use Common PINs (Quick)
echo =====================================
echo Copy one of these PIN hashes and update your database:
echo.
echo PIN: 1234
echo Hash: 03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4
echo.
echo PIN: 0000
echo Hash: 96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e
echo.
echo PIN: 1111
echo Hash: 0ffe1abd1a08215353c233d6e009613e95eec4253832a761af28ff37ac5a150c
echo.
echo PIN: 9999
echo Hash: ad0234829205b9033196ba818f7a872b2896130c6626018a5e8a5b9e1c3e9f5f
echo.
echo.
echo OPTION 2: Download DB Browser for SQLite
echo =====================================
echo 1. Download from: https://sqlitebrowser.org/
echo 2. Open: .dart_tool\sqflite_common_ffi\databases\credit_app.db
echo 3. Browse Data -^> users table
echo 4. Edit the pinHash field for your user
echo 5. Paste one of the hashes above
echo 6. Save changes
echo.
echo.
echo OPTION 3: Use PowerShell Script (Advanced)
echo =====================================
echo Run: powershell -ExecutionPolicy Bypass -File reset_pin.ps1
echo.
pause
