@echo off
echo ========================================
echo   Backup Database Before Clean
echo ========================================
echo.

set BACKUP_FILE=database_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%.db
set BACKUP_FILE=%BACKUP_FILE: =0%

echo Creating backup...
if exist .dart_tool\sqflite_common_ffi\databases\credit_app.db (
    copy .dart_tool\sqflite_common_ffi\databases\credit_app.db %BACKUP_FILE%
    echo.
    echo ✅ Database backed up to: %BACKUP_FILE%
    echo.
    echo Now running flutter clean...
    flutter clean
    echo.
    echo ========================================
    echo Clean complete!
    echo.
    echo To restore your data after rebuilding:
    echo   1. Run the app once to create database
    echo   2. Close the app
    echo   3. Run: restore_database.bat
    echo ========================================
) else (
    echo ⚠️ No database found to backup
    echo Running flutter clean anyway...
    flutter clean
)

pause
