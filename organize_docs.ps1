# Documentation Organization Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Organizing Credit System Documentation" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create folders if they don't exist
$folders = @(
    "docs/user-guides",
    "docs/development/changelog",
    "docs/development/architecture",
    "docs/development/phases",
    "docs/deployment",
    "docs/maintenance",
    "docs/troubleshooting"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
        Write-Host "[CREATE] $folder" -ForegroundColor Green
    }
}

# Move user guides
Write-Host "`n[USER GUIDES]" -ForegroundColor Yellow
$userGuides = @(
    @{src="USER_GUIDE_ENGLISH.md"; dst="docs/user-guides/"},
    @{src="USER_GUIDE_ARABIC.md"; dst="docs/user-guides/"},
    @{src="QUICK_START_GUIDE.md"; dst="docs/user-guides/"},
    @{src="INSTALL_ON_PHONE.md"; dst="docs/user-guides/"},
    @{src="RUN_ON_MOBILE.md"; dst="docs/user-guides/"}
)

foreach ($file in $userGuides) {
    if (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move deployment docs
Write-Host "`n[DEPLOYMENT]" -ForegroundColor Yellow
$deployment = @(
    @{src="HOW_TO_USE_ON_ANOTHER_PC.txt"; dst="docs/deployment/"},
    @{src="BUILD_GUIDE.md"; dst="docs/deployment/"},
    @{src="QUICK_BUILD_GUIDE.md"; dst="docs/deployment/"},
    @{src="BUILD_ANDROID_AND_DESKTOP.md"; dst="docs/deployment/"},
    @{src="DEPLOYMENT_CHECKLIST.md"; dst="docs/deployment/"},
    @{src="BUILDS_READY.txt"; dst="docs/deployment/"},
    @{src="APK_READY.md"; dst="docs/deployment/"},
    @{src="YOUR_APK_IS_READY.md"; dst="docs/deployment/"},
    @{src="BUILD_RESULTS.md"; dst="docs/deployment/"}
)

foreach ($file in $deployment) {
    if (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move changelog/releases
Write-Host "`n[CHANGELOG]" -ForegroundColor Yellow
$changelog = @(
    @{src="UX_IMPROVEMENTS_COMPLETE.txt"; dst="docs/development/changelog/"},
    @{src="FINAL_FIX_COMPLETE.txt"; dst="docs/development/changelog/"},
    @{src="FINAL_UPDATES_COMPLETE.md"; dst="docs/development/changelog/"},
    @{src="ALL_ISSUES_FIXED.md"; dst="docs/development/changelog/"},
    @{src="WEB_COMPATIBILITY_FIX.md"; dst="docs/development/changelog/"},
    @{src="ARABIC_PDF_ERRORS_FIXED.md"; dst="docs/development/changelog/"},
    @{src="CRITICAL_TRANSACTION_BUG_FIXED.md"; dst="docs/development/changelog/"},
    @{src="ALL_FIXES_COMPLETE.md"; dst="docs/development/changelog/"}
)

foreach ($file in $changelog) {
    if (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move development phases
Write-Host "`n[DEVELOPMENT PHASES]" -ForegroundColor Yellow
$phases = @(
    @{src="PHASE9_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE10_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE11_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE12_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE13_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE14_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="PHASE11_QUICK_START.md"; dst="docs/development/phases/"},
    @{src="ENTERPRISE_UPGRADES_COMPLETE.md"; dst="docs/development/phases/"},
    @{src="UPGRADES_PHASE*.md"; dst="docs/development/phases/"}
)

foreach ($file in $phases) {
    if ($file.src -like "*`**") {
        # Handle wildcards
        Get-ChildItem -Path $file.src -ErrorAction SilentlyContinue | ForEach-Object {
            Move-Item -Path $_.FullName -Destination $file.dst -Force
            Write-Host "  Moved: $($_.Name)" -ForegroundColor Gray
        }
    } elseif (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move maintenance docs
Write-Host "`n[MAINTENANCE]" -ForegroundColor Yellow
$maintenance = @(
    @{src="MAINTENANCE_GUIDE.md"; dst="docs/maintenance/"},
    @{src="DATA_PERSISTENCE_GUIDE.md"; dst="docs/maintenance/"},
    @{src="QUICK_TEST_GUIDE.md"; dst="docs/maintenance/"}
)

foreach ($file in $maintenance) {
    if (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move troubleshooting docs
Write-Host "`n[TROUBLESHOOTING]" -ForegroundColor Yellow
$troubleshooting = @(
    @{src="FIX_VISUAL_STUDIO.md"; dst="docs/troubleshooting/"},
    @{src="WINDOWS_FORMAT_EXCEPTION_FIX.md"; dst="docs/troubleshooting/"},
    @{src="WEB_AUTH_FIX.md"; dst="docs/troubleshooting/"},
    @{src="LOGIN_FIX_APPLIED.md"; dst="docs/troubleshooting/"},
    @{src="ARABIC_PDF_*FIX*.md"; dst="docs/troubleshooting/"}
)

foreach ($file in $troubleshooting) {
    if ($file.src -like "*`**") {
        Get-ChildItem -Path $file.src -ErrorAction SilentlyContinue | ForEach-Object {
            Move-Item -Path $_.FullName -Destination $file.dst -Force
            Write-Host "  Moved: $($_.Name)" -ForegroundColor Gray
        }
    } elseif (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Move architecture docs
Write-Host "`n[ARCHITECTURE]" -ForegroundColor Yellow
$architecture = @(
    @{src="PROJECT_ANALYSIS_REPORT.md"; dst="docs/development/architecture/"},
    @{src="PROJECT_STATUS_COMPLETE.md"; dst="docs/development/architecture/"},
    @{src="PLATFORM_SUPPORT.md"; dst="docs/development/architecture/"}
)

foreach ($file in $architecture) {
    if (Test-Path $file.src) {
        Move-Item -Path $file.src -Destination $file.dst -Force
        Write-Host "  Moved: $($file.src)" -ForegroundColor Gray
    }
}

# Clean up session/status files (move to archive)
Write-Host "`n[ARCHIVING SESSION FILES]" -ForegroundColor Yellow
$archive = "docs/development/archive"
if (-not (Test-Path $archive)) {
    New-Item -ItemType Directory -Path $archive -Force | Out-Null
}

$sessionFiles = Get-ChildItem -Path "." -Filter "SESSION_*.md" -ErrorAction SilentlyContinue
$sessionFiles += Get-ChildItem -Path "." -Filter "START_*.md" -ErrorAction SilentlyContinue
$sessionFiles += Get-ChildItem -Path "." -Filter "TEST_*.md" -ErrorAction SilentlyContinue
$sessionFiles += Get-ChildItem -Path "." -Filter "READY_*.md" -ErrorAction SilentlyContinue
$sessionFiles += Get-ChildItem -Path "." -Filter "ALL_*.md" -ErrorAction SilentlyContinue

foreach ($file in $sessionFiles) {
    if (Test-Path $file.FullName) {
        Move-Item -Path $file.FullName -Destination $archive -Force
        Write-Host "  Archived: $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Documentation organization complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Structure:" -ForegroundColor Cyan
Write-Host "  docs/user-guides/          - User documentation"
Write-Host "  docs/development/changelog/ - Version history"
Write-Host "  docs/development/phases/    - Development phases"
Write-Host "  docs/deployment/            - Build & deployment"
Write-Host "  docs/maintenance/           - Maintenance guides"
Write-Host "  docs/troubleshooting/       - Problem solving"
Write-Host ""
