# Watch script for continuous code generation during development
# Automatically regenerates code when source files change

param(
    [switch]$Verbose,
    [switch]$OnlyRiverpod
)

$ErrorActionPreference = "Stop"

function Write-Info($message) {
    Write-Host "ℹ️  $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

try {
    Write-Host "👀 Starting Aura development watch mode..." -ForegroundColor Cyan
    
    # Change to script directory
    Set-Location $PSScriptRoot\..
    
    # Ensure packages are installed
    Write-Info "Ensuring packages are up to date..."
    dart pub get
    if ($LASTEXITCODE -ne 0) { throw "Package installation failed" }
    
    # Initial clean build
    Write-Info "Running initial clean build..."
    dart run build_runner clean
    if ($LASTEXITCODE -ne 0) { throw "Build runner clean failed" }
    
    Write-Success "Initial setup completed"
    
    # Start watch mode
    Write-Host "`n🔄 Starting watch mode... (Press Ctrl+C to stop)" -ForegroundColor Green
    Write-Host "Files will be automatically regenerated when you save changes." -ForegroundColor Yellow
    
    if ($OnlyRiverpod) {
        Write-Info "Watching only Riverpod files..."
        if ($Verbose) {
            dart run build_runner watch --verbose --build-filter="riverpod_generator:*"
        } else {
            dart run build_runner watch --build-filter="riverpod_generator:*"
        }
    } else {
        Write-Info "Watching all generated files..."
        if ($Verbose) {
            dart run build_runner watch --verbose
        } else {
            dart run build_runner watch
        }
    }
    
} catch {
    Write-Error "Watch mode failed: $($_.Exception.Message)"
    exit 1
}

# Note: This script runs continuously until stopped with Ctrl+C
