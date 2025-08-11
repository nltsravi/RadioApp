#!/bin/bash

# QSO Log Build Script
# This script helps build and test the QSO Log app

set -e

echo "🚀 QSO Log Build Script"
echo "========================"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "RadioApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Function to build for simulator
build_simulator() {
    echo "📱 Building for iOS Simulator..."
    xcodebuild \
        -project RadioApp.xcodeproj \
        -scheme RadioApp \
        -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
        -configuration Debug \
        build
}

# Function to build for device
build_device() {
    echo "📱 Building for iOS Device..."
    xcodebuild \
        -project RadioApp.xcodeproj \
        -scheme RadioApp \
        -destination 'generic/platform=iOS' \
        -configuration Release \
        build
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."
    xcodebuild \
        -project RadioApp.xcodeproj \
        -scheme RadioApp \
        -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
        test
}

# Function to clean build
clean_build() {
    echo "🧹 Cleaning build..."
    xcodebuild \
        -project RadioApp.xcodeproj \
        clean
}

# Function to show project info
show_info() {
    echo "📋 Project Information:"
    echo "  - Project: RadioApp"
    echo "  - Target: iOS 17.0+"
    echo "  - Architecture: Swift 5.9+, SwiftUI, Core Data"
    echo "  - Features: CloudKit sync, ADIF import/export"
    echo ""
    echo "📁 Project Structure:"
    echo "  - Models/: Data models and catalogs"
    echo "  - ViewModels/: Business logic"
    echo "  - Views/: SwiftUI views"
    echo "  - Services/: ADIF and other services"
    echo "  - RadioApp.xcdatamodeld/: Core Data model"
}

# Function to show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  simulator    Build for iOS Simulator"
    echo "  device       Build for iOS Device"
    echo "  test         Run tests"
    echo "  clean        Clean build"
    echo "  info         Show project information"
    echo "  help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 simulator"
    echo "  $0 test"
    echo "  $0 clean"
}

# Main script logic
case "${1:-help}" in
    "simulator")
        build_simulator
        ;;
    "device")
        build_device
        ;;
    "test")
        run_tests
        ;;
    "clean")
        clean_build
        ;;
    "info")
        show_info
        ;;
    "help"|*)
        show_help
        ;;
esac

echo ""
echo "✅ Build script completed!"
