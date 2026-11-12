# ============================================================================
# Firebase Setup Verification Script
# ============================================================================
# This script verifies that all Firebase dependencies are properly installed
# and the project is ready to compile
# ============================================================================

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Firebase Setup Verification" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Test 1: Check if web/WEB-INF/lib directory exists
Write-Host "[1/5] Checking lib directory..." -NoNewline
if (Test-Path "web\WEB-INF\lib") {
    Write-Host " PASS" -ForegroundColor Green
} else {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "  Directory web\WEB-INF\lib does not exist" -ForegroundColor Red
    $allPassed = $false
}

# Test 2: Check if all required JARs are present
Write-Host "[2/5] Checking Firebase JARs..." -NoNewline
$requiredJars = @(
    "firebase-admin-9.2.0.jar",
    "google-auth-library-oauth2-http-1.19.0.jar",
    "google-auth-library-credentials-1.19.0.jar",
    "google-http-client-1.43.3.jar",
    "google-http-client-gson-1.43.3.jar",
    "google-api-client-2.2.0.jar",
    "gson-2.10.1.jar",
    "guava-32.1.3-jre.jar",
    "api-common-2.15.0.jar",
    "grpc-context-1.58.0.jar",
    "opencensus-api-0.31.1.jar",
    "opencensus-contrib-http-util-0.31.1.jar"
)

$missingJars = @()
foreach ($jar in $requiredJars) {
    $jarPath = "web\WEB-INF\lib\$jar"
    if (!(Test-Path $jarPath)) {
        $missingJars += $jar
    }
}

if ($missingJars.Count -eq 0) {
    Write-Host " PASS" -ForegroundColor Green
    Write-Host "  All 12 Firebase JARs present" -ForegroundColor Gray
} else {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "  Missing JARs:" -ForegroundColor Red
    foreach ($jar in $missingJars) {
        Write-Host "    - $jar" -ForegroundColor Red
    }
    $allPassed = $false
}

# Test 3: Check if project.properties has been updated
Write-Host "[3/5] Checking project.properties..." -NoNewline
$propsFile = "nbproject\project.properties"
if (Test-Path $propsFile) {
    $content = Get-Content $propsFile -Raw
    if ($content -match "firebase-admin-9.2.0.jar") {
        Write-Host " PASS" -ForegroundColor Green
        Write-Host "  Firebase JARs configured in classpath" -ForegroundColor Gray
    } else {
        Write-Host " FAIL" -ForegroundColor Red
        Write-Host "  Firebase JARs not found in javac.classpath" -ForegroundColor Red
        $allPassed = $false
    }
} else {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "  File not found: $propsFile" -ForegroundColor Red
    $allPassed = $false
}

# Test 4: Check if Firebase Java files exist
Write-Host "[4/5] Checking Firebase integration files..." -NoNewline
$firebaseFiles = @(
    "src\java\com\paperwise\servlet\GoogleAuthServlet.java",
    "src\java\com\paperwise\util\FirebaseUtil.java",
    "src\java\com\paperwise\listener\FirebaseInitializer.java"
)

$missingFiles = @()
foreach ($file in $firebaseFiles) {
    if (!(Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Host " PASS" -ForegroundColor Green
    Write-Host "  All Firebase integration files present" -ForegroundColor Gray
} else {
    Write-Host " FAIL" -ForegroundColor Red
    Write-Host "  Missing files:" -ForegroundColor Red
    foreach ($file in $missingFiles) {
        Write-Host "    - $file" -ForegroundColor Red
    }
    $allPassed = $false
}

# Test 5: Check if config directory structure is ready
Write-Host "[5/5] Checking configuration directory..." -NoNewline
if (Test-Path "config") {
    if (Test-Path "config\firebase-service-account.json") {
        Write-Host " PASS" -ForegroundColor Green
        Write-Host "  Firebase service account key found" -ForegroundColor Gray
    } else {
        Write-Host " WARN" -ForegroundColor Yellow
        Write-Host "  config\ directory exists but firebase-service-account.json missing" -ForegroundColor Yellow
        Write-Host "  Download from: https://console.firebase.google.com/project/paperwise-34ce6/settings/serviceaccounts/adminsdk" -ForegroundColor Gray
    }
} else {
    Write-Host " WARN" -ForegroundColor Yellow
    Write-Host "  config\ directory not found (create it and add firebase-service-account.json)" -ForegroundColor Yellow
}

# Summary
Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "STATUS: READY TO BUILD" -ForegroundColor Green
    Write-Host ""
    Write-Host "All checks passed! Your project is configured correctly." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart NetBeans IDE" -ForegroundColor White
    Write-Host "2. Open PaperWise_AJT project" -ForegroundColor White
    Write-Host "3. Right-click project -> Clean and Build" -ForegroundColor White
    Write-Host "4. Verify no compilation errors" -ForegroundColor White
    Write-Host "5. Add firebase-service-account.json to config\ directory" -ForegroundColor White
    Write-Host "6. Deploy to Tomcat and test" -ForegroundColor White
} else {
    Write-Host "STATUS: NEEDS ATTENTION" -ForegroundColor Red
    Write-Host ""
    Write-Host "Some checks failed. Please review the errors above." -ForegroundColor Red
    Write-Host "Refer to FIREBASE_DEPENDENCIES_INSTALLED.md for troubleshooting." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""
