# Development Scripts

Collection of useful scripts and automation tools for Flutter development workflow.

## Overview

Development scripts automate repetitive tasks, improve productivity, and ensure consistency across the development team. This guide covers essential scripts for Flutter projects.

## Build Scripts

### 1. Build Automation

```bash
#!/bin/bash
# scripts/build.sh

set -e

echo "🚀 Starting Flutter build process..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Run code generation
echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run tests
echo "🧪 Running tests..."
flutter test

# Build for different platforms
echo "📱 Building for platforms..."

# Android
echo "Building Android APK..."
flutter build apk --release

echo "Building Android App Bundle..."
flutter build appbundle --release

# iOS (only on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Building iOS..."
    flutter build ios --release --no-codesign
fi

# Web
echo "Building Web..."
flutter build web --release

echo "✅ Build process completed!"
```

### 2. Development Build

```bash
#!/bin/bash
# scripts/dev-build.sh

echo "🔧 Development build starting..."

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run in debug mode
flutter run --debug

echo "✅ Development build ready!"
```

## Testing Scripts

### 1. Comprehensive Test Runner

```bash
#!/bin/bash
# scripts/test.sh

set -e

echo "🧪 Running comprehensive test suite..."

# Unit tests
echo "Running unit tests..."
flutter test test/unit/ --coverage

# Widget tests
echo "Running widget tests..."
flutter test test/widget/

# Integration tests
echo "Running integration tests..."
flutter test integration_test/

# Generate coverage report
echo "Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ All tests completed!"
echo "📊 Coverage report available at coverage/html/index.html"
```

### 2. Quick Test Script

```bash
#!/bin/bash
# scripts/quick-test.sh

# Run only unit tests for quick feedback
flutter test test/unit/ --reporter=compact

echo "✅ Quick tests completed!"
```

## Code Quality Scripts

### 1. Linting and Formatting

```bash
#!/bin/bash
# scripts/lint.sh

echo "🔍 Running code quality checks..."

# Format code
echo "Formatting code..."
dart format lib/ test/ --set-exit-if-changed

# Analyze code
echo "Analyzing code..."
flutter analyze

# Check for unused dependencies
echo "Checking for unused dependencies..."
flutter pub deps

echo "✅ Code quality checks completed!"
```

### 2. Pre-commit Hook

```bash
#!/bin/bash
# scripts/pre-commit.sh

echo "🔒 Running pre-commit checks..."

# Format code
dart format lib/ test/ --set-exit-if-changed
if [ $? -ne 0 ]; then
    echo "❌ Code formatting failed"
    exit 1
fi

# Analyze code
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Code analysis failed"
    exit 1
fi

# Run quick tests
flutter test test/unit/ --reporter=compact
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-commit checks passed!"
```

## Asset Management Scripts

### 1. Asset Generation

```bash
#!/bin/bash
# scripts/generate-assets.sh

echo "🎨 Generating app assets..."

# Generate app icons
flutter pub run flutter_launcher_icons:main

# Generate splash screens
flutter pub run flutter_native_splash:create

# Generate localization files
flutter gen-l10n

echo "✅ Assets generated successfully!"
```

### 2. Image Optimization

```bash
#!/bin/bash
# scripts/optimize-images.sh

echo "🖼️ Optimizing images..."

# Find and optimize PNG files
find assets/images -name "*.png" -exec pngquant --force --ext .png {} \;

# Find and optimize JPEG files
find assets/images -name "*.jpg" -exec jpegoptim --max=85 {} \;

echo "✅ Image optimization completed!"
```

## Database Scripts

### 1. Database Migration

```bash
#!/bin/bash
# scripts/migrate-db.sh

echo "🗄️ Running database migrations..."

# Run Supabase migrations
supabase db reset

# Seed database with test data
supabase db seed

echo "✅ Database migration completed!"
```

### 2. Database Backup

```bash
#!/bin/bash
# scripts/backup-db.sh

BACKUP_DIR="backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.sql"

echo "💾 Creating database backup..."

mkdir -p $BACKUP_DIR

# Create backup
supabase db dump > $BACKUP_FILE

echo "✅ Database backup created: $BACKUP_FILE"
```

## Deployment Scripts

### 1. Production Deployment

```bash
#!/bin/bash
# scripts/deploy-prod.sh

set -e

echo "🚀 Starting production deployment..."

# Ensure we're on main branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo "❌ Must be on main branch for production deployment"
    exit 1
fi

# Ensure working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working directory must be clean"
    exit 1
fi

# Run tests
./scripts/test.sh

# Build production assets
./scripts/build.sh

# Deploy to app stores (placeholder)
echo "📱 Deploying to app stores..."
# Add actual deployment commands here

echo "✅ Production deployment completed!"
```

### 2. Staging Deployment

```bash
#!/bin/bash
# scripts/deploy-staging.sh

echo "🎭 Deploying to staging..."

# Build for staging
flutter build web --dart-define=ENVIRONMENT=staging

# Deploy to staging server
# Add your staging deployment commands here

echo "✅ Staging deployment completed!"
```

## Development Utilities

### 1. Project Setup

```bash
#!/bin/bash
# scripts/setup.sh

echo "⚙️ Setting up Flutter project..."

# Install Flutter dependencies
flutter pub get

# Install development tools
dart pub global activate flutter_gen
dart pub global activate build_runner

# Generate initial code
flutter packages pub run build_runner build

# Setup git hooks
cp scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Create necessary directories
mkdir -p coverage
mkdir -p logs
mkdir -p backups

echo "✅ Project setup completed!"
echo "🎉 You're ready to start developing!"
```

### 2. Clean Reset

```bash
#!/bin/bash
# scripts/clean-reset.sh

echo "🧹 Performing clean reset..."

# Flutter clean
flutter clean

# Remove generated files
rm -rf .dart_tool/
rm -rf build/
rm -rf coverage/

# Remove pub cache
flutter pub cache repair

# Reinstall dependencies
flutter pub get

# Regenerate code
flutter packages pub run build_runner build --delete-conflicting-outputs

echo "✅ Clean reset completed!"
```

## Monitoring Scripts

### 1. Performance Monitoring

```bash
#!/bin/bash
# scripts/monitor-performance.sh

echo "📊 Running performance monitoring..."

# Build profile version
flutter build apk --profile

# Run performance tests
flutter drive --target=test_driver/performance_test.dart --profile

echo "✅ Performance monitoring completed!"
```

### 2. Bundle Size Analysis

```bash
#!/bin/bash
# scripts/analyze-bundle.sh

echo "📦 Analyzing bundle size..."

# Build release version
flutter build apk --analyze-size

# Generate size analysis
flutter build apk --target-platform android-arm64 --analyze-size

echo "✅ Bundle size analysis completed!"
```

## Git Workflow Scripts

### 1. Feature Branch Creation

```bash
#!/bin/bash
# scripts/create-feature.sh

if [ -z "$1" ]; then
    echo "Usage: ./scripts/create-feature.sh <feature-name>"
    exit 1
fi

FEATURE_NAME=$1
BRANCH_NAME="feature/$FEATURE_NAME"

echo "🌿 Creating feature branch: $BRANCH_NAME"

# Create and switch to feature branch
git checkout -b $BRANCH_NAME

# Push branch to remote
git push -u origin $BRANCH_NAME

echo "✅ Feature branch created and pushed!"
```

### 2. Release Preparation

```bash
#!/bin/bash
# scripts/prepare-release.sh

if [ -z "$1" ]; then
    echo "Usage: ./scripts/prepare-release.sh <version>"
    exit 1
fi

VERSION=$1

echo "🏷️ Preparing release $VERSION..."

# Update version in pubspec.yaml
sed -i "s/version: .*/version: $VERSION/" pubspec.yaml

# Run tests
./scripts/test.sh

# Build release
./scripts/build.sh

# Create git tag
git add pubspec.yaml
git commit -m "Bump version to $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

echo "✅ Release $VERSION prepared!"
echo "📝 Don't forget to push: git push origin main --tags"
```

## Makefile Integration

```makefile
# Makefile

.PHONY: setup build test clean deploy

setup:
	@./scripts/setup.sh

build:
	@./scripts/build.sh

test:
	@./scripts/test.sh

clean:
	@./scripts/clean-reset.sh

lint:
	@./scripts/lint.sh

deploy-staging:
	@./scripts/deploy-staging.sh

deploy-prod:
	@./scripts/deploy-prod.sh

dev:
	@./scripts/dev-build.sh

assets:
	@./scripts/generate-assets.sh

help:
	@echo "Available commands:"
	@echo "  setup         - Set up the project"
	@echo "  build         - Build the application"
	@echo "  test          - Run all tests"
	@echo "  clean         - Clean and reset project"
	@echo "  lint          - Run linting and formatting"
	@echo "  deploy-staging - Deploy to staging"
	@echo "  deploy-prod   - Deploy to production"
	@echo "  dev           - Start development build"
	@echo "  assets        - Generate app assets"
```

## Package.json Scripts (for web developers)

```json
{
  "scripts": {
    "setup": "./scripts/setup.sh",
    "build": "./scripts/build.sh",
    "test": "./scripts/test.sh",
    "dev": "./scripts/dev-build.sh",
    "clean": "./scripts/clean-reset.sh",
    "lint": "./scripts/lint.sh",
    "deploy:staging": "./scripts/deploy-staging.sh",
    "deploy:prod": "./scripts/deploy-prod.sh"
  }
}
```

## Script Management Best Practices

### 1. Script Organization

```
scripts/
├── build.sh
├── test.sh
├── deploy-prod.sh
├── deploy-staging.sh
├── setup.sh
├── clean-reset.sh
├── lint.sh
├── pre-commit.sh
├── utils/
│   ├── common.sh
│   └── colors.sh
└── README.md
```

### 2. Common Utilities

```bash
# scripts/utils/common.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Flutter installation
check_flutter() {
    if ! command_exists flutter; then
        log_error "Flutter is not installed"
        exit 1
    fi
}
```

Development scripts are essential for maintaining a productive Flutter development workflow. Start with basic build and test scripts, then expand based on your team's needs.
