# ============================================================================
# Firebase Admin SDK Dependency Downloader for PaperWise
# ============================================================================
# This script downloads all required Firebase Admin SDK JARs
# Run this in PowerShell from the project root directory
# ============================================================================

Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Firebase Admin SDK Dependency Downloader" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

# Target directory
$libDir = "web\WEB-INF\lib"

# Create directory if it doesn't exist
if (!(Test-Path $libDir)) {
    Write-Host "Creating directory: $libDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $libDir | Out-Null
}

# Change to lib directory
Push-Location $libDir

Write-Host "Downloading Firebase Admin SDK and dependencies..." -ForegroundColor Green
Write-Host "Target directory: $(Get-Location)" -ForegroundColor Gray
Write-Host ""

# Define dependencies
$dependencies = @(
    @{
        Name = "Firebase Admin SDK"
        Url = "https://repo1.maven.org/maven2/com/google/firebase/firebase-admin/9.2.0/firebase-admin-9.2.0.jar"
        File = "firebase-admin-9.2.0.jar"
    },
    @{
        Name = "Google Auth OAuth2 HTTP"
        Url = "https://repo1.maven.org/maven2/com/google/auth/google-auth-library-oauth2-http/1.19.0/google-auth-library-oauth2-http-1.19.0.jar"
        File = "google-auth-library-oauth2-http-1.19.0.jar"
    },
    @{
        Name = "Google Auth Credentials"
        Url = "https://repo1.maven.org/maven2/com/google/auth/google-auth-library-credentials/1.19.0/google-auth-library-credentials-1.19.0.jar"
        File = "google-auth-library-credentials-1.19.0.jar"
    },
    @{
        Name = "Google HTTP Client"
        Url = "https://repo1.maven.org/maven2/com/google/http-client/google-http-client/1.43.3/google-http-client-1.43.3.jar"
        File = "google-http-client-1.43.3.jar"
    },
    @{
        Name = "Google HTTP Client Gson"
        Url = "https://repo1.maven.org/maven2/com/google/http-client/google-http-client-gson/1.43.3/google-http-client-gson-1.43.3.jar"
        File = "google-http-client-gson-1.43.3.jar"
    },
    @{
        Name = "Google API Client"
        Url = "https://repo1.maven.org/maven2/com/google/api-client/google-api-client/2.2.0/google-api-client-2.2.0.jar"
        File = "google-api-client-2.2.0.jar"
    },
    @{
        Name = "Gson"
        Url = "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar"
        File = "gson-2.10.1.jar"
    },
    @{
        Name = "Guava"
        Url = "https://repo1.maven.org/maven2/com/google/guava/guava/32.1.3-jre/guava-32.1.3-jre.jar"
        File = "guava-32.1.3-jre.jar"
    },
    @{
        Name = "API Common"
        Url = "https://repo1.maven.org/maven2/com/google/api/api-common/2.15.0/api-common-2.15.0.jar"
        File = "api-common-2.15.0.jar"
    },
    @{
        Name = "gRPC Context"
        Url = "https://repo1.maven.org/maven2/io/grpc/grpc-context/1.58.0/grpc-context-1.58.0.jar"
        File = "grpc-context-1.58.0.jar"
    },
    @{
        Name = "OpenCensus API"
        Url = "https://repo1.maven.org/maven2/io/opencensus/opencensus-api/0.31.1/opencensus-api-0.31.1.jar"
        File = "opencensus-api-0.31.1.jar"
    },
    @{
        Name = "OpenCensus HTTP Util"
        Url = "https://repo1.maven.org/maven2/io/opencensus/opencensus-contrib-http-util/0.31.1/opencensus-contrib-http-util-0.31.1.jar"
        File = "opencensus-contrib-http-util-0.31.1.jar"
    }
)

# Download each dependency
$successCount = 0
$failCount = 0
$skippedCount = 0

foreach ($dep in $dependencies) {
    Write-Host "[$($dependencies.IndexOf($dep) + 1)/$($dependencies.Count)] " -NoNewline -ForegroundColor Cyan
    Write-Host "$($dep.Name)" -ForegroundColor White
    
    # Check if file already exists
    if (Test-Path $dep.File) {
        Write-Host "  ✓ Already exists: $($dep.File)" -ForegroundColor Yellow
        $skippedCount++
    } else {
        try {
            Write-Host "  → Downloading..." -ForegroundColor Gray -NoNewline
            Invoke-WebRequest -Uri $dep.Url -OutFile $dep.File -ErrorAction Stop
            Write-Host " ✓ Done" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Host " ✗ Failed" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            $failCount++
        }
    }
    Write-Host ""
}

# Return to original directory
Pop-Location

# Summary
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "Download Summary" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "✓ Successfully downloaded: $successCount" -ForegroundColor Green
Write-Host "⊘ Skipped (already exists): $skippedCount" -ForegroundColor Yellow
if ($failCount -gt 0) {
    Write-Host "✗ Failed: $failCount" -ForegroundColor Red
}
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "All dependencies are ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Restart NetBeans IDE" -ForegroundColor White
    Write-Host "2. Right-click project → Clean and Build" -ForegroundColor White
    Write-Host "3. Verify Firebase imports work in Java files" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "Some dependencies failed to download." -ForegroundColor Red
    Write-Host "Please download them manually from Maven Central:" -ForegroundColor Yellow
    Write-Host "https://repo1.maven.org/maven2/" -ForegroundColor Blue
    Write-Host ""
}

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
