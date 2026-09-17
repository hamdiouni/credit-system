# ============================================
# Professional Documentation Reorganization
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Organizing Documentation Structure" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$moved = 0
$kept = 0

# Files to KEEP in root (essential project files)
$keepInRoot = @(
    "README.md",
    "CHANGELOG.md",
    "CONTRIBUTING.md",
    "LICENSE",
    ".gitignore",
    ".gitattributes"
)

# Move development/progress files
$devFiles = @(
    "PHASE9_STARTED.md",
    "PHASE9_PROGRESS_80PERCENT.md",
    "PHASE11_PROGRESS.md",
    "PHASE11_INTEGRATION_COMPLETE.md",
    "PHASE13_STARTED.md",
    "PHASE13_PROGRESS_UPDATE.md",
    "PHASE13_QUICK_REFERENCE.md",
    "CURRENT_PROGRESS_CHECKPOINT.md",
    "ENTERPRISE_UPGRADES_STARTED.md",
    "ENTERPRISE_UPGRADES_STATUS.md",
    "ENTERPRISE_UPGRADES_FINAL_PLAN.md",
    "REMAINING_PHASES_ROADMAP.md"
)

Write-Host "[1/7] Moving development progress files..." -ForegroundColor Yellow
foreach ($file in $devFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/development/phases/" -Force
        Write-Host "  OK $file -> docs/development/phases/" -ForegroundColor Green
        $moved++
    }
}

# Move changelog/status files
$changelogFiles = @(
    "UX_IMPROVEMENTS_COMPLETE.txt",
    "FINAL_FIX_COMPLETE.txt",
    "FINAL_UPDATES_COMPLETE.md",
    "AUTO_BALANCE_AND_LANGUAGE_FIX.md",
    "BALANCE_CREDIT_UI_UPDATE.md",
    "BALANCE_FIX_COMPLETE.md",
    "BOTH_BUILDS_COMPLETE.md",
    "CSV_AND_PDF_FIXES.md",
    "DELETE_CUSTOMER_UPDATE.md",
    "FINAL_UPDATE_SUMMARY.md",
    "LETTER_JOINING_FIX.md",
    "NAVIGATION_FIX_APPLIED.md",
    "OVERPAYMENT_FIX.md",
    "REFACTORING_COMPLETE.md",
    "TRANSACTION_FIX_APPLIED.md",
    "TRANSLATION_AND_GUIDES_COMPLETE.md",
    "TRANSLATION_FIXES.md",
    "UPDATE_ICON_GUIDE.md",
    "UPDATES_COMPLETE.md",
    "UPGRADES_COMPLETE.md",
    "WEB_TRANSACTION_FIX.md"
)

Write-Host "[2/7] Moving changelog files..." -ForegroundColor Yellow
foreach ($file in $changelogFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/development/changelog/" -Force
        Write-Host "  OK $file -> docs/development/changelog/" -ForegroundColor Green
        $moved++
    }
}

# Move architecture/design files
$archFiles = @(
    "ARCHITECTURE.md",
    "BUSINESS_RULES.md",
    "DATA_FLOW_VISUAL.md",
    "DATABASE_INTEGRATION.md",
    "DATABASE_SETUP.md",
    "DATABASE_SUMMARY.md"
)

Write-Host "[3/7] Moving architecture files..." -ForegroundColor Yellow
foreach ($file in $archFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/development/architecture/" -Force
        Write-Host "  OK $file -> docs/development/architecture/" -ForegroundColor Green
        $moved++
    }
}

# Move deployment/build files
$deployFiles = @(
    "ANSWER_ANDROID_DESKTOP.md",
    "WINDOWS_APP_READY.md",
    "build_log.txt"
)

Write-Host "[4/7] Moving deployment files..." -ForegroundColor Yellow
foreach ($file in $deployFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/deployment/" -Force
        Write-Host "  OK $file -> docs/deployment/" -ForegroundColor Green
        $moved++
    }
}

# Move troubleshooting/fix files
$fixFiles = @(
    "ARABIC_FONT_SETUP.md",
    "ARABIC_LETTER_JOINING_GUIDE.md",
    "ARABIC_PDF_COMPLETE_SOLUTION.md",
    "ARABIC_PDF_QUICK_REFERENCE.md",
    "ARABIC_PDF_SOLUTION_DIAGRAM.md",
    "ARABIC_RTL_FIX.md",
    "ALTERNATIVE_ARABIC_PDF_SOLUTION.md",
    "CRITICAL_FIX_SUMMARY.md",
    "CRITICAL_ISSUES_ANALYSIS.md",
    "DESKTOP_PLATFORM_FIX.md",
    "FINAL_ARABIC_FIX.md",
    "FINAL_ARABIC_PDF_SUMMARY.md",
    "FINAL_FIX_SUMMARY.md",
    "FINAL_FIXES_COMPLETE.md",
    "FIXES_APPLIED_NOW.md",
    "PREDEFINED_ARABIC_SOLUTION.md",
    "REAL_SOLUTION.md",
    "RTL_FIX_SUMMARY.md",
    "SMART_ARABIC_FIX.md",
    "ULTIMATE_ARABIC_FIX.md",
    "URGENT_FIX_INSTRUCTIONS.md",
    "WEB_PLATFORM_FIX.md"
)

Write-Host "[5/7] Moving troubleshooting files..." -ForegroundColor Yellow
foreach ($file in $fixFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/troubleshooting/" -Force
        Write-Host "  OK $file -> docs/troubleshooting/" -ForegroundColor Green
        $moved++
    }
}

# Move testing/maintenance files
$testFiles = @(
    "CODE_VERIFICATION.md",
    "COMPREHENSIVE_TEST_PLAN.md",
    "DATA_VERIFICATION_GUIDE.md",
    "HOW_TO_TEST_PLATFORMS.md",
    "PLATFORM_STATUS_VERIFIED.md",
    "PLATFORM_TEST_RESULTS.md",
    "QUICK_DATA_VERIFY.md",
    "TESTING_WORKFLOW.md",
    "WEB_READY_TO_TEST.md"
)

Write-Host "[6/7] Moving testing/maintenance files..." -ForegroundColor Yellow
foreach ($file in $testFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/maintenance/" -Force
        Write-Host "  OK $file -> docs/maintenance/" -ForegroundColor Green
        $moved++
    }
}

# Archive session/status files (development logs)
$archiveFiles = @(
    "00_READ_ME_FIRST.md",
    "ACTIONS_TAKEN.md",
    "APP_DISTRIBUTION_AND_MONITORING_GUIDE.md",
    "COMPLETE_WORK_SUMMARY.md",
    "CURRENT_STATUS.md",
    "DELIVERABLES.md",
    "DELIVERY_COMPLETE.md",
    "DELIVERY_SUMMARY.md",
    "DO_THIS_NOW.md",
    "DOCUMENTATION_INDEX.md",
    "FILE_INDEX.md",
    "FINAL_COMPLETE_SUMMARY.md",
    "FINAL_IMPLEMENTATION_SUMMARY.md",
    "FINAL_PROJECT_SUMMARY.md",
    "FINAL_SESSION_SUMMARY.md",
    "FINAL_STATUS_ALL_PLATFORMS.md",
    "FINAL_SUMMARY.md",
    "IMPLEMENTATION_COMPLETE.md",
    "IMPLEMENTATION_GUIDE.md",
    "IMPLEMENTATION_SUMMARY.md",
    "MASTER_INDEX.md",
    "PROJECT_COMPLETION_REPORT.md",
    "PROJECT_INDEX.md",
    "QUICK_DB_START.md",
    "QUICK_DEMO.md",
    "QUICK_REFERENCE.md",
    "QUICK_START.md",
    "QUICK_STATUS.md",
    "RESTART_SERVER.md",
    "SUCCESS_APP_RUNNING.md",
    "WHAT_WE_BUILT.md",
    "WHERE_ARE_FEATURES.md"
)

Write-Host "[7/7] Archiving session files..." -ForegroundColor Yellow
foreach ($file in $archiveFiles) {
    if (Test-Path $file) {
        Move-Item $file "docs/development/archive/" -Force
        Write-Host "  OK $file -> docs/development/archive/" -ForegroundColor Green
        $moved++
    }
}

# Count files kept in root
Write-Host ""
Write-Host "Checking root files..." -ForegroundColor Yellow
foreach ($file in $keepInRoot) {
    if (Test-Path $file) {
        Write-Host "  Keeping $file in root" -ForegroundColor Cyan
        $kept++
    }
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Documentation Organization Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "  Files moved: $moved" -ForegroundColor White
Write-Host "  Files kept in root: $kept" -ForegroundColor White
Write-Host ""
Write-Host "Clean root directory with organized docs structure!" -ForegroundColor Green
Write-Host ""
