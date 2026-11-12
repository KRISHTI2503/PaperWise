# Test compilation script for DownloadPaperServlet

Write-Host "Testing DownloadPaperServlet.java compilation..." -ForegroundColor Cyan

# Set up classpath with required JARs
$servletApi = "C:\Program Files\Apache Software Foundation\Tomcat 10.1\lib\servlet-api.jar"
$classpath = "build\web\WEB-INF\classes;lib\postgresql-42.7.10.jar"

if (Test-Path $servletApi) {
    $classpath = "$classpath;$servletApi"
}

# Try to compile just the DownloadPaperServlet
$sourceFile = "src\java\com\paperwise\servlet\DownloadPaperServlet.java"

Write-Host "Compiling $sourceFile..." -ForegroundColor Yellow

javac -cp $classpath -d "build\web\WEB-INF\classes" `
    -sourcepath "src\java" `
    $sourceFile 2>&1 | Tee-Object -Variable compileOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Compilation successful!" -ForegroundColor Green
    Write-Host "DownloadPaperServlet.java compiled without errors." -ForegroundColor Green
} else {
    Write-Host "`n✗ Compilation failed!" -ForegroundColor Red
    Write-Host $compileOutput -ForegroundColor Red
}

exit $LASTEXITCODE
