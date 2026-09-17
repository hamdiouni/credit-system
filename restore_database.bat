@echo off
echo ========================================
echo   Restore Database Backup
echo ========================================
echo.

echo Available backups:
dir /b database_backup_*.db 2>nul

if errorlevel 1 (
    echo.
    echo ❌ No backup files found!
    echo.
    pause
    exit /b
)

echo.
set /p BACKUP_FILE="Enter backup filename to restore: "

if not exist %BACKUP_FILE% (
    echo.
    echo ❌ File not found: %BACKUP_FILE%
    echo.
    pause
    exit /b
)

echo.
echo Restoring database from %BACKUP_FILE%...

if not exist .dart_tool\sqflite_common_ffi\databases (
    mkdir .dart_tool\sqflite_common_ffi\databases
)

copy %BACKUP_FILE% .dart_tool\sqflite_common_ffi\databases\credit_app.db

echo.
echo ========================================
echo ✅ Database restored successfully!
echo.
echo You can now run the app and your data will be there.
echo ========================================

pause
