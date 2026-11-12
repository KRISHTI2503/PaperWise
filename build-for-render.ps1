# PowerShell script to build PaperWise for Render deployment
# Run this before deploying to Render

Write-Host "`n=== PaperWise Build for Render ===" -ForegroundColor Cyan
Write-Host "Building WAR file for cloud deployment`n" -ForegroundColor Gray

# Check if dist directory exists
if (Test-Path "dist") {
    Write-Host "[1/4] Cleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force "dist"
}

# Clean and build
Write-Host "[2/4] Running ant clean compile war..." -ForegroundColor Yellow
ant clean compile war

# Check if WAR was created
if (Test-Path "dist/PaperWise_AJT.war") {
    $warSize = (Get-Item "dist/PaperWise_AJT.war").Length / 1MB
    Write-Host "[3/4] ✓ WAR file created: dist/PaperWise_AJT.war ($([math]::Round($warSize, 2)) MB)" -ForegroundColor Green
    
    # Check if Dockerfile exists
    if (Test-Path "Dockerfile") {
        Write-Host "[4/4] ✓ Dockerfile found" -ForegroundColor Green
        Write-Host "`n=== Build Complete ===" -ForegroundColor Cyan
        Write-Host "`nNext steps:" -ForegroundColor White
        Write-Host "1. Commit changes: git add . && git commit -m 'Build for Render'" -ForegroundColor Gray
        Write-Host "2. Push to GitHub: git push origin main" -ForegroundColor Gray
        Write-Host "3. Deploy to Render: https://dashboard.render.com" -ForegroundColor Gray
        Write-Host "`nSee DEPLOYMENT_GUIDE.md for detailed instructions`n" -ForegroundColor Gray
    } else {
        Write-Host "[4/4] ✗ Dockerfile not found!" -ForegroundColor Red
        Write-Host "Error: Dockerfile is required for Render deployment" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[3/4] ✗ Build failed - WAR file not created" -ForegroundColor Red
    Write-Host "Check NetBeans Output tab for errors" -ForegroundColor Red
    exit 1
}
