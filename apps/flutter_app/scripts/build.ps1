# Automated build script for Aura Flutter app (PowerShell)
# Handles code generation, cleaning, and optimization

param(
    [switch]$BuildApk,
    [switch]$SkipTests,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Color functions
function Write-Step($message) {
    Write-Host "`n🔵 $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Warning($message) {
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

try {
    Write-Host "🚀 Starting Aura build process..." -ForegroundColor Cyan
    
    # Change to script directory
    Set-Location $PSScriptRoot\..
    
    # Clean previous builds
    Write-Step "Cleaning previous builds..."
    flutter clean
    if ($LASTEXITCODE -ne 0) { throw "Flutter clean failed" }
    
    dart pub get
    if ($LASTEXITCODE -ne 0) { throw "Package installation failed" }
    
    Write-Success "Clean completed"
    
    # Run code generation
    Write-Step "Running code generation..."
    dart run build_runner clean
    if ($LASTEXITCODE -ne 0) { throw "Build runner clean failed" }
    
    if ($Verbose) {
        dart run build_runner build --delete-conflicting-outputs --verbose
    } else {
        dart run build_runner build --delete-conflicting-outputs
    }
    if ($LASTEXITCODE -ne 0) { throw "Code generation failed" }
    
    Write-Success "Code generation completed"
    
    # Run static analysis
    Write-Step "Running static analysis..."
    flutter analyze --fatal-infos
    if ($LASTEXITCODE -ne 0) { 
        Write-Warning "Static analysis found issues - check output above"
        # Don't fail the build for analysis issues in development
    } else {
        Write-Success "Static analysis passed"
    }
    
    # Format code
    Write-Step "Formatting code..."
    dart format lib\ --set-exit-if-changed
    if ($LASTEXITCODE -ne 0) { 
        Write-Warning "Code formatting changes were applied"
    } else {
        Write-Success "Code formatting verified"
    }
    
    # Run tests if they exist and not skipped
    if (-not $SkipTests) {
        if (Test-Path "test" -PathType Container) {
            $testFiles = Get-ChildItem -Path "test" -Recurse -Filter "*.dart"
            if ($testFiles.Count -gt 0) {
                Write-Step "Running tests..."
                flutter test
                if ($LASTEXITCODE -ne 0) { throw "Tests failed" }
                Write-Success "All tests passed"
            } else {
                Write-Warning "No test files found, skipping test execution"
            }
        } else {
            Write-Warning "Test directory not found, skipping test execution"
        }
    } else {
        Write-Warning "Tests skipped by user request"
    }
    
    Write-Success "Build process completed successfully!"
    Write-Success "Generated files updated and code analyzed"
    
    # Optional: Build APK
    if ($BuildApk) {
        Write-Step "Building debug APK..."
        flutter build apk --debug
        if ($LASTEXITCODE -ne 0) { throw "APK build failed" }
        Write-Success "Debug APK built successfully!"
    }
    
    Write-Host "`n🎉 All done! Your Aura app is ready for development." -ForegroundColor Green
    
} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    Write-Host "`nTo get more information, run with -Verbose flag" -ForegroundColor Yellow
    exit 1
}

# Usage examples
Write-Host "`nUsage examples:" -ForegroundColor Cyan
Write-Host "  .\build.ps1                    # Standard build"
Write-Host "  .\build.ps1 -BuildApk          # Build with APK generation"
Write-Host "  .\build.ps1 -SkipTests         # Skip test execution"
Write-Host "  .\build.ps1 -Verbose           # Detailed output"
