@echo off
echo ========================================
echo Clear Database Script
echo ========================================
echo.

if exist ".dart_tool\sqflite_common_ffi\databases\credit_app.db" (
    echo Deleting database file...
    del /F ".dart_tool\sqflite_common_ffi\databases\credit_app.db"
    echo ✅ Database deleted successfully
) else (
    echo ⚠️ Database file not found (already clean)
)

echo.
echo ========================================
echo Done! You can now run the app.
echo ========================================
pause
