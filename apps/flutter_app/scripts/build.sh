#!/bin/bash
# Automated build script for Aura Flutter app
# Handles code generation, cleaning, and optimization

set -e

echo "🚀 Starting Aura build process..."

# Change to Flutter app directory
cd "$(dirname "$0")"

# Function to print colored output
print_step() {
    echo -e "\n\033[1;34m$1\033[0m"
}

print_success() {
    echo -e "\033[1;32m✅ $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m❌ $1\033[0m"
}

# Function to handle errors
handle_error() {
    print_error "Build failed at step: $1"
    exit 1
}

# Clean previous builds
print_step "Cleaning previous builds..."
flutter clean || handle_error "Flutter clean"
dart pub get || handle_error "Package installation"

# Run code generation
print_step "Running code generation..."
dart run build_runner clean || handle_error "Build runner clean"
dart run build_runner build --delete-conflicting-outputs || handle_error "Code generation"

# Run static analysis
print_step "Running static analysis..."
flutter analyze --fatal-infos || handle_error "Static analysis"

# Format code
print_step "Formatting code..."
dart format lib/ --set-exit-if-changed || handle_error "Code formatting"

# Run tests if they exist
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    print_step "Running tests..."
    flutter test || handle_error "Tests"
else
    echo "⚠️  No tests found, skipping test execution"
fi

print_success "Build process completed successfully!"
print_success "Generated files updated and code analyzed"

# Optional: Build APK for testing
read -p "Do you want to build a debug APK? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Building debug APK..."
    flutter build apk --debug || handle_error "APK build"
    print_success "Debug APK built successfully!"
fi

echo "🎉 All done! Your Aura app is ready for development."
