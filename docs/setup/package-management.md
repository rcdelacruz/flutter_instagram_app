# Flutter Package Management

Comprehensive guide to managing dependencies, packages, and libraries in Flutter projects for production-grade applications.

## Package Management Fundamentals

### pub.dev - The Official Package Repository

Flutter uses **pub.dev** as the official package repository, similar to npm for JavaScript or PyPI for Python.

- **Official packages**: Maintained by the Flutter team
- **Community packages**: Maintained by the community
- **Verified publishers**: Packages from trusted organizations

### pubspec.yaml - The Dependency File

The `pubspec.yaml` file is the heart of Flutter package management:

```yaml
name: flutter_instagram_app
description: A production-grade Flutter Instagram clone
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: ">=3.35.0"

dependencies:
  flutter:
    sdk: flutter

  # Production dependencies
  riverpod: ^2.4.0
  go_router: ^12.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Development-only dependencies
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
```

## Essential Packages for Instagram Clone

### State Management

```yaml
dependencies:
  # Riverpod - Modern state management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0

  # Alternative: BLoC pattern
  flutter_bloc: ^8.1.0

  # Alternative: Provider (simpler)
  provider: ^6.1.0
```

### Navigation

```yaml
dependencies:
  # Go Router - Declarative routing
  go_router: ^12.0.0

  # Alternative: Auto Route
  auto_route: ^7.8.0
```

### Network & API

```yaml
dependencies:
  # Dio - HTTP client
  dio: ^5.3.0

  # Supabase - Backend as a Service
  supabase_flutter: ^2.0.0

  # HTTP - Simple HTTP client
  http: ^1.1.0

  # Connectivity - Network status
  connectivity_plus: ^5.0.0
```

### UI & Styling

```yaml
dependencies:
  # Image handling
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0

  # SVG support
  flutter_svg: ^2.0.0

  # Animations
  lottie: ^2.7.0

  # Screen adaptation
  flutter_screenutil: ^5.9.0

  # Icons
  cupertino_icons: ^1.0.0
  font_awesome_flutter: ^10.6.0
```

### Storage & Persistence

```yaml
dependencies:
  # Simple key-value storage
  shared_preferences: ^2.2.0

  # Secure storage
  flutter_secure_storage: ^9.0.0

  # SQLite database
  sqflite: ^2.3.0

  # Object box (alternative)
  objectbox_flutter_libs: ^2.0.0
```

### Development Tools

```yaml
dev_dependencies:
  # Testing
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0

  # Code generation
  build_runner: ^2.4.0
  json_annotation: ^4.8.0
  json_serializable: ^6.7.0

  # Linting
  flutter_lints: ^3.0.0
  very_good_analysis: ^5.1.0

  # Code coverage
  coverage: ^1.7.0
```

## Package Installation Commands

### Adding Dependencies

```bash
# Add a package
flutter pub add package_name

# Add a dev dependency
flutter pub add --dev package_name

# Add with specific version
flutter pub add package_name:^1.0.0

# Add multiple packages
flutter pub add riverpod go_router dio
```

### Removing Dependencies

```bash
# Remove a package
flutter pub remove package_name

# Remove multiple packages
flutter pub remove package1 package2
```

### Updating Dependencies

```bash
# Get dependencies
flutter pub get

# Update all packages
flutter pub upgrade

# Update specific package
flutter pub upgrade package_name

# Update with major version changes
flutter pub upgrade --major-versions
```

## Version Constraints

### Semantic Versioning

Flutter follows semantic versioning (semver):

```yaml
dependencies:
  # Caret constraint (recommended)
  package_name: ^1.2.3  # >=1.2.3 <2.0.0

  # Exact version
  package_name: 1.2.3

  # Range constraint
  package_name: '>=1.2.3 <2.0.0'

  # Any version (not recommended)
  package_name: any
```

### Best Practices for Versioning

```yaml
dependencies:
  # Use caret constraints for stability
  riverpod: ^2.4.0

  # Pin critical packages if needed
  flutter:
    sdk: flutter

  # Use git dependencies for forks
  custom_package:
    git:
      url: https://github.com/user/custom_package.git
      ref: main

  # Use path dependencies for local packages
  local_package:
    path: ../local_package
```

## Package Categories

### UI Components

```yaml
dependencies:
  # Material Design
  flutter:
    sdk: flutter

  # Cupertino (iOS style)
  cupertino_icons: ^1.0.0

  # Custom UI libraries
  flutter_staggered_grid_view: ^0.7.0
  shimmer: ^3.0.0
  pull_to_refresh: ^2.0.0
```

### Utilities

```yaml
dependencies:
  # Date/time handling
  intl: ^0.18.0
  timeago: ^3.5.0

  # Functional programming
  dartz: ^0.10.0

  # Logging
  logger: ^2.0.0

  # UUID generation
  uuid: ^4.1.0
```

### Platform Integration

```yaml
dependencies:
  # Device info
  device_info_plus: ^9.1.0

  # Package info
  package_info_plus: ^4.2.0

  # URL launcher
  url_launcher: ^6.2.0

  # Share functionality
  share_plus: ^7.2.0

  # Permissions
  permission_handler: ^11.0.0
```

## Code Generation

### Setup for JSON Serialization

```yaml
dependencies:
  json_annotation: ^4.8.0

dev_dependencies:
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

### Running Code Generation

```bash
# One-time generation
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Dependency Management Best Practices

### 1. Regular Updates

```bash
# Check for outdated packages
flutter pub outdated

# Update regularly but test thoroughly
flutter pub upgrade --dry-run
flutter pub upgrade
```

### 2. Security Considerations

```bash
# Audit dependencies for security issues
flutter pub deps

# Check package scores on pub.dev
# Look for:
# - Popularity score
# - Pub points
# - Likes count
# - Maintenance status
```

### 3. Performance Impact

```yaml
# Prefer smaller, focused packages
dependencies:
  # Good: Specific functionality
  cached_network_image: ^3.3.0

  # Avoid: Large, monolithic packages
  # unless absolutely necessary
```

### 4. Dependency Conflicts

```bash
# Resolve conflicts
flutter pub deps
flutter pub upgrade --major-versions

# Use dependency overrides (last resort)
dependency_overrides:
  package_name: ^1.0.0
```

## Package Development

### Creating a Package

```bash
# Create a new package
flutter create --template=package my_package

# Create a plugin (with platform code)
flutter create --template=plugin my_plugin
```

### Package Structure

```
my_package/
├── lib/
│   ├── my_package.dart      # Main export file
│   └── src/                 # Implementation
├── test/                    # Tests
├── example/                 # Example app
├── pubspec.yaml            # Package metadata
├── README.md               # Documentation
├── CHANGELOG.md            # Version history
└── LICENSE                 # License file
```

## Troubleshooting

### Common Issues

**Dependency conflicts:**
```bash
# Clear pub cache
flutter pub cache clean

# Delete pubspec.lock and reinstall
rm pubspec.lock
flutter pub get
```

**Build failures:**
```bash
# Clean build
flutter clean
flutter pub get

# Regenerate code
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

**Version conflicts:**
```bash
# Check dependency tree
flutter pub deps

# Use dependency overrides
dependency_overrides:
  conflicting_package: ^1.0.0
```

## Production Considerations

### 1. Package Audit

Before production:
- Review all dependencies
- Check for security vulnerabilities
- Verify maintenance status
- Test thoroughly

### 2. Bundle Size Optimization

```yaml
# Use tree shaking
flutter build apk --tree-shake-icons

# Analyze bundle size
flutter build apk --analyze-size
```

### 3. License Compliance

```bash
# Generate license file
flutter pub deps --json > licenses.json
```

## Next Steps

After setting up package management:

1. ✅ Configure essential packages for your project
2. ✅ Set up code generation if needed
3. ✅ Implement dependency update workflow
4. ✅ Proceed to [Supabase Setup](supabase-setup.md)

Your Flutter package management is now configured for production-grade development!
