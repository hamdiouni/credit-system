@echo off
echo ========================================
echo Clear ALL App Data Script
echo ========================================
echo.
echo This will delete:
echo - Database files
echo - Shared preferences
echo - All cached data
echo.
pause

echo.
echo Clearing database...
if exist ".dart_tool\sqflite_common_ffi\databases" (
    rmdir /S /Q ".dart_tool\sqflite_common_ffi\databases"
    echo ✅ Database folder deleted
) else (
    echo ⚠️ Database folder not found
)

echo.
echo Clearing build cache...
if exist "build" (
    rmdir /S /Q "build"
    echo ✅ Build folder deleted
) else (
    echo ⚠️ Build folder not found
)

echo.
echo Clearing .dart_tool cache...
if exist ".dart_tool" (
    rmdir /S /Q ".dart_tool"
    echo ✅ .dart_tool folder deleted
) else (
    echo ⚠️ .dart_tool folder not found
)

echo.
echo ========================================
echo All data cleared!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter run -d windows
echo.
pause
