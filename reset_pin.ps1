# PIN Reset Tool for Credit App
# This script directly updates the SQLite database with a new PIN

Write-Host "🔐 Credit App - PIN Reset Tool" -ForegroundColor Cyan
Write-Host "=" * 50

# Database path
$dbPath = ".\.dart_tool\sqflite_common_ffi\databases\credit_app.db"

# Check if database exists
if (-not (Test-Path $dbPath)) {
    Write-Host "❌ Database not found at: $dbPath" -ForegroundColor Red
    Write-Host "   Make sure you've run the app at least once." -ForegroundColor Yellow
    pause
    exit
}

Write-Host "✅ Database found" -ForegroundColor Green
Write-Host ""

# Function to hash PIN using SHA256
function Get-PinHash {
    param([string]$pin)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($pin)
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha256.ComputeHash($bytes)
    return [System.BitConverter]::ToString($hash).Replace("-", "").ToLower()
}

# Load SQLite assembly
try {
    # Try to use System.Data.SQLite if available
    Add-Type -Path "System.Data.SQLite.dll" -ErrorAction Stop
} catch {
    Write-Host "⚠️  System.Data.SQLite not found. Attempting alternative method..." -ForegroundColor Yellow
    
    # Alternative: Use sqlite3.exe if available
    $sqlite3 = Get-Command sqlite3.exe -ErrorAction SilentlyContinue
    
    if (-not $sqlite3) {
        Write-Host ""
        Write-Host "❌ SQLite tools not found." -ForegroundColor Red
        Write-Host ""
        Write-Host "MANUAL RESET INSTRUCTIONS:" -ForegroundColor Yellow
        Write-Host "1. Download DB Browser for SQLite from: https://sqlitebrowser.org/" -ForegroundColor White
        Write-Host "2. Open the database file: $dbPath" -ForegroundColor White
        Write-Host "3. Go to 'Browse Data' tab, select 'users' table" -ForegroundColor White
        Write-Host "4. Find your user and click 'Edit' on the pinHash field" -ForegroundColor White
        Write-Host ""
        Write-Host "PIN HASHES (SHA256):" -ForegroundColor Cyan
        Write-Host "  PIN 1234 = 03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4" -ForegroundColor White
        Write-Host "  PIN 0000 = 96cae35ce8a9b0244178bf28e4966c2ce1b8385723a96a6b838858cdd6ca0a1e" -ForegroundColor White
        Write-Host "  PIN 1111 = 0ffe1abd1a08215353c233d6e009613e95eec4253832a761af28ff37ac5a150c" -ForegroundColor White
        Write-Host ""
        pause
        exit
    }
}

# Get list of users
Write-Host "📋 Fetching users from database..." -ForegroundColor Cyan

try {
    $users = & sqlite3.exe $dbPath "SELECT id, username, role FROM users WHERE isActive = 1;"
    
    if (-not $users) {
        Write-Host "❌ No active users found in database." -ForegroundColor Red
        Write-Host "   Create a user first using the app." -ForegroundColor Yellow
        pause
        exit
    }
    
    Write-Host ""
    Write-Host "Current Users:" -ForegroundColor Green
    Write-Host "-" * 50
    
    $userList = @()
    $index = 1
    foreach ($line in $users) {
        $parts = $line -split '\|'
        if ($parts.Count -ge 3) {
            $userId = $parts[0]
            $username = $parts[1]
            $role = $parts[2]
            Write-Host "$index. $username ($role)" -ForegroundColor White
            $userList += @{Index=$index; Id=$userId; Username=$username; Role=$role}
            $index++
        }
    }
    Write-Host "-" * 50
    Write-Host ""
    
    # Get username to reset
    $username = Read-Host "👤 Enter username to reset PIN"
    
    $selectedUser = $userList | Where-Object { $_.Username -eq $username }
    
    if (-not $selectedUser) {
        Write-Host "❌ User '$username' not found." -ForegroundColor Red
        pause
        exit
    }
    
    # Get new PIN
    Write-Host ""
    $newPin = Read-Host "🔢 Enter new PIN (4-6 digits)"
    
    # Validate PIN
    if ($newPin.Length -lt 4 -or $newPin.Length -gt 6) {
        Write-Host "❌ Invalid PIN. Must be 4-6 digits." -ForegroundColor Red
        pause
        exit
    }
    
    if ($newPin -notmatch '^\d+$') {
        Write-Host "❌ PIN must contain only numbers." -ForegroundColor Red
        pause
        exit
    }
    
    # Hash the PIN
    $pinHash = Get-PinHash -pin $newPin
    
    Write-Host ""
    Write-Host "🔐 PIN Hash: $pinHash" -ForegroundColor Gray
    
    # Update database
    Write-Host ""
    Write-Host "💾 Updating database..." -ForegroundColor Cyan
    
    $updateQuery = "UPDATE users SET pinHash = '$pinHash' WHERE username = '$username';"
    & sqlite3.exe $dbPath $updateQuery
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ PIN reset successfully!" -ForegroundColor Green
        Write-Host "   Username: $username" -ForegroundColor White
        Write-Host "   New PIN: $newPin" -ForegroundColor White
        Write-Host ""
        Write-Host "🎉 You can now login with this PIN!" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Failed to update database." -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host ""
pause
