# ============================================
# Push Credit System to GitHub
# ============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Pushing Credit System to GitHub" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if gh is available
Write-Host "[1/3] Checking GitHub CLI..." -ForegroundColor Yellow
$ghPath = Get-Command gh -ErrorAction SilentlyContinue

if ($ghPath) {
    Write-Host "✓ GitHub CLI found!" -ForegroundColor Green
    
    # Step 2: Create repository and push
    Write-Host ""
    Write-Host "[2/3] Creating repository on GitHub..." -ForegroundColor Yellow
    
    gh repo create credit-system `
        --public `
        --description "Professional offline-first credit management app for small businesses. Built with Flutter. Supports Android, Windows, Web. Features: Multi-language (EN/AR/FR), PDF/CSV export, Backup/Restore, Multi-user auth, 35+ features." `
        --source=. `
        --remote=origin `
        --push
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Repository created and code pushed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "  SUCCESS! Your code is now on GitHub!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Repository URL:" -ForegroundColor Yellow
        Write-Host "https://github.com/hamdiouni/credit-system" -ForegroundColor White
        Write-Host ""
        Write-Host "View your project:" -ForegroundColor Yellow
        gh repo view --web
    } else {
        Write-Host ""
        Write-Host "✗ Failed to create repository" -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host "1. Repository 'credit-system' already exists" -ForegroundColor White
        Write-Host "2. GitHub CLI not authenticated (run: gh auth login)" -ForegroundColor White
        Write-Host ""
        Write-Host "Manual alternative:" -ForegroundColor Yellow
        Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
        Write-Host "2. Name: credit-system" -ForegroundColor White
        Write-Host "3. Make it Public" -ForegroundColor White
        Write-Host "4. DO NOT add README, .gitignore, or license" -ForegroundColor White
        Write-Host "5. Then run: git push -u origin main" -ForegroundColor White
    }
} else {
    Write-Host "✗ GitHub CLI (gh) not found in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Manual steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: credit-system" -ForegroundColor White
    Write-Host "3. Description: Professional offline-first credit management app" -ForegroundColor White
    Write-Host "4. Choose: Public (for portfolio)" -ForegroundColor White
    Write-Host "5. DO NOT check any boxes (README, .gitignore, license)" -ForegroundColor White
    Write-Host "6. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    Write-Host "Then run this command:" -ForegroundColor Yellow
    Write-Host "git push -u origin main" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
