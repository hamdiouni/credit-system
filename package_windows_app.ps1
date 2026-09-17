# Credit System - Windows App Packaging Script
# This script creates a portable distribution package

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Credit System - Windows App Packager" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Define paths
$sourcePath = "build\windows\x64\runner\Release"
$packageName = "CreditSystem_Windows_Portable"
$packagePath = "dist\$packageName"

# Check if source exists
if (-not (Test-Path $sourcePath)) {
    Write-Host "ERROR: Build folder not found!" -ForegroundColor Red
    Write-Host "Please run: flutter build windows --release" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/4] Creating distribution folder..." -ForegroundColor Green
# Remove old package if exists
if (Test-Path "dist") {
    Remove-Item -Path "dist" -Recurse -Force
}
New-Item -ItemType Directory -Path $packagePath -Force | Out-Null

Write-Host "[2/4] Copying application files..." -ForegroundColor Green
# Copy all files from Release folder
Copy-Item -Path "$sourcePath\*" -Destination $packagePath -Recurse -Force

Write-Host "[3/4] Creating README file..." -ForegroundColor Green
# Create README
$readmeContent = @"
========================================
CREDIT SYSTEM - WINDOWS PORTABLE APP
========================================

VERSION: 1.0.0
BUILD DATE: $(Get-Date -Format "yyyy-MM-dd HH:mm")

WHAT'S FIXED IN THIS VERSION:
- Balance credit now automatically reduces new debt
- PDF documentation works without errors in all languages
- All 4 languages supported: English, Arabic, French, Tunisian

========================================
INSTALLATION INSTRUCTIONS
========================================

NO INSTALLATION REQUIRED! This is a portable app.

1. Copy this entire folder to any location on your PC
2. Double-click "credit_app.exe" to run
3. That's it!

========================================
SYSTEM REQUIREMENTS
========================================

- Windows 10 or Windows 11 (64-bit)
- No additional software needed
- All required DLL files are included

========================================
FIRST TIME SETUP
========================================

1. Run credit_app.exe
2. Create your first user account
3. Set a 4-digit PIN code
4. Start managing your customers!

========================================
DATA STORAGE
========================================

Your data is stored locally in:
C:\Users\[YourUsername]\AppData\Roaming\credit_app\

This folder contains:
- credit_app.db (your database)
- logs\ (application logs)
- backups\ (automatic backups)

========================================
TRANSFERRING TO ANOTHER PC
========================================

METHOD 1: Fresh Start (Recommended for new PC)
1. Copy this entire folder to the new PC
2. Run credit_app.exe
3. Create a new user account
4. Use "Restore Backup" to import your data

METHOD 2: Transfer with Data
1. Copy this entire folder to the new PC
2. On OLD PC: Go to Settings > Backup & Restore > Create Backup
3. Save the backup file (credit_app_backup_YYYYMMDD.json)
4. Copy the backup file to the new PC
5. On NEW PC: Run credit_app.exe
6. Create a new user account
7. Go to Settings > Backup & Restore > Restore Backup
8. Select your backup file

METHOD 3: Manual Database Transfer (Advanced)
1. Copy this entire folder to the new PC
2. On OLD PC: Copy the database from:
   C:\Users\[YourUsername]\AppData\Roaming\credit_app\credit_app.db
3. On NEW PC: Run credit_app.exe once (to create folders)
4. Close the app
5. Copy the database file to:
   C:\Users\[YourUsername]\AppData\Roaming\credit_app\credit_app.db
6. Run credit_app.exe again

========================================
FEATURES
========================================

- Multi-user support with PIN authentication
- Customer management (add, edit, delete)
- Credit/Debt tracking with 70+ grocery items
- Payment recording with overpayment protection
- Automatic balance credit consumption
- Transaction history with edit/delete
- PDF export (customer statements)
- CSV export (transaction data)
- Backup & Restore
- Multi-language: English, Arabic, French, Tunisian
- RTL support for Arabic languages
- In-app user documentation

========================================
SUPPORT & TROUBLESHOOTING
========================================

If the app doesn't start:
1. Make sure all files in this folder are present
2. Check if Windows Defender blocked the app
3. Right-click credit_app.exe > Properties > Unblock
4. Run as Administrator (if needed)

If you lost your PIN:
1. Close the app
2. Run the reset_pin.ps1 script (if available)
3. Or delete: C:\Users\[YourUsername]\AppData\Roaming\credit_app\credit_app.db
   (WARNING: This deletes all data!)

========================================
INCLUDED FILES
========================================

credit_app.exe                    - Main application
flutter_windows.dll               - Flutter runtime
connectivity_plus_plugin.dll      - Network connectivity
printing_plugin.dll               - PDF printing support
share_plus_plugin.dll             - File sharing
sqlite3.x64.windows.dll           - Database engine
pdfium.dll                        - PDF rendering
url_launcher_windows_plugin.dll   - URL handling
data\                             - Application resources

========================================
LICENSE & COPYRIGHT
========================================

Credit System - Customer Credit Management
Copyright (c) 2024
All rights reserved.

========================================
"@

Set-Content -Path "$packagePath\README.txt" -Value $readmeContent -Encoding UTF8

Write-Host "[4/4] Creating ZIP archive..." -ForegroundColor Green
$zipPath = "dist\$packageName.zip"
Compress-Archive -Path $packagePath -DestinationPath $zipPath -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "SUCCESS! Package created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "PACKAGE LOCATION:" -ForegroundColor Cyan
Write-Host "  Folder: dist\$packageName\" -ForegroundColor Yellow
Write-Host "  ZIP:    dist\$packageName.zip" -ForegroundColor Yellow
Write-Host ""
Write-Host "PACKAGE SIZE:" -ForegroundColor Cyan
$folderSize = (Get-ChildItem -Path $packagePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
$zipSize = (Get-Item $zipPath).Length / 1MB
Write-Host "  Folder: $([math]::Round($folderSize, 2)) MB" -ForegroundColor Yellow
Write-Host "  ZIP:    $([math]::Round($zipSize, 2)) MB" -ForegroundColor Yellow
Write-Host ""
Write-Host "TO DISTRIBUTE:" -ForegroundColor Cyan
Write-Host "  1. Share the ZIP file: $packageName.zip" -ForegroundColor White
Write-Host "  2. User extracts the ZIP on their PC" -ForegroundColor White
Write-Host "  3. User runs credit_app.exe" -ForegroundColor White
Write-Host ""
Write-Host "MOBILE APK LOCATION:" -ForegroundColor Cyan
Write-Host "  build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
Write-Host ""
