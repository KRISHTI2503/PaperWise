# PowerShell script to test Docker environment variable injection
# Verifies no ${...} placeholders reach Java code

Write-Host "=== PaperWise Docker Environment Test ===" -ForegroundColor Cyan
Write-Host "Building Docker image..."

# Build the image
docker build -t paperwise-test .
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Starting container with FAKE values to test placeholder substitution ===" -ForegroundColor Cyan
Write-Host "All values are intentionally fake - we're testing that placeholders are resolved"
Write-Host ""

# Start container with fake values
docker run --rm -d `
  --name paperwise-test `
  -p 8080:8080 `
  -e JDBC_URL="jdbc:postgresql://fake-host.test:5432/fakedb?sslmode=require" `
  -e JDBC_USERNAME="fake_user" `
  -e JDBC_PASSWORD="fake_password_12345" `
  -e SUPABASE_URL="https://fake-project.supabase.co" `
  -e SUPABASE_KEY="fake_supabase_key_abc123xyz" `
  -e SUPABASE_BUCKET="fake-bucket" `
  -e APP_ENV="production" `
  paperwise-test

Write-Host "Container started. Waiting for Tomcat to initialize (20 seconds)..."
Start-Sleep -Seconds 20

Write-Host ""
Write-Host "=== Checking container logs for placeholder resolution ===" -ForegroundColor Cyan
Write-Host "Looking for evidence that environment variables were injected..."
Write-Host ""

# Get logs and filter for configuration lines
docker logs paperwise-test 2>&1 | Select-String -Pattern "✓|✗|WARNING|configured"

Write-Host ""
Write-Host "=== Testing /health endpoint ===" -ForegroundColor Cyan
try {
    $healthCheck = Invoke-WebRequest -Uri "http://localhost:8080/health" -UseBasicParsing -TimeoutSec 5
    if ($healthCheck.Content -eq "OK") {
        Write-Host "✓ Health endpoint returned: $($healthCheck.Content)" -ForegroundColor Green
    } else {
        Write-Host "✗ Health endpoint returned unexpected value: $($healthCheck.Content)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Checking Tomcat logs for unresolved placeholders ===" -ForegroundColor Cyan
Write-Host "If you see '\${JDBC_URL}' or similar, the test FAILED"
Write-Host ""

# Check if any ${...} made it into the logs (this would be BAD)
$logs = docker logs paperwise-test 2>&1 | Out-String
if ($logs -match '\$\{') {
    Write-Host "✗ FAILURE: Found unresolved placeholder in logs:" -ForegroundColor Red
    docker logs paperwise-test 2>&1 | Select-String -Pattern '\$\{'
} else {
    Write-Host "✓ SUCCESS: No unresolved placeholders found" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Checking for initialization errors ===" -ForegroundColor Cyan
$errors = docker logs paperwise-test 2>&1 | Select-String -Pattern "error|exception" | Where-Object { $_ -notmatch "removeAbandoned" } | Select-Object -First 5
if ($errors) {
    Write-Host "Found errors (expected with fake credentials):"
    $errors | ForEach-Object { Write-Host $_ }
} else {
    Write-Host "No initialization errors found"
}

Write-Host ""
Write-Host "=== Full Startup Log (first 30 lines) ===" -ForegroundColor Cyan
docker logs paperwise-test 2>&1 | Select-Object -First 30

Write-Host ""
Write-Host "=== Stopping test container ===" -ForegroundColor Cyan
docker stop paperwise-test | Out-Null

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host "Review the output above to confirm:" -ForegroundColor Yellow
Write-Host "1. All environment variables show '✓ configured'" -ForegroundColor Yellow
Write-Host "2. No '\${...}' placeholders appear in logs" -ForegroundColor Yellow
Write-Host "3. Health endpoint returns 'OK'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Expected behavior: Connection errors are NORMAL with fake credentials" -ForegroundColor Yellow
Write-Host "What we're testing: Placeholders are resolved BEFORE reaching Java code" -ForegroundColor Yellow
