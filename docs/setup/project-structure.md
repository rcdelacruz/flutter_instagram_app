# Flutter Project Structure

Learn how to organize your Flutter project for scalability, maintainability, and team collaboration. This guide presents a **progressive approach** that starts simple and evolves as your app grows.

## Architecture Evolution Strategy

### **Start Simple** → **Scale Smart**

1. **Small Projects (< 10 screens)**: Use **Flat Structure**
2. **Medium Projects (10-30 screens)**: Introduce **Feature Grouping**
3. **Large Projects (30+ screens)**: Adopt **Clean Architecture**

---

## Phase 1: Flat Structure (Recommended Start)

**Perfect for**: New projects, MVPs, small teams, learning

```
flutter_rork_app/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── app.dart                        # App configuration
│   ├── screens/                        # App screens
│   │   ├── auth/                       # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/                       # Home screens
│   │   │   ├── home_screen.dart
│   │   │   ├── feed_screen.dart
│   │   │   └── profile_screen.dart
│   │   └── shared/                     # Shared screens
│   │       ├── splash_screen.dart
│   │       └── error_screen.dart
│   ├── widgets/                        # Reusable widgets
│   │   ├── common/                     # Common widgets
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   └── loading_indicator.dart
│   │   ├── cards/                      # Card widgets
│   │   │   ├── post_card.dart
│   │   │   └── user_card.dart
│   │   └── forms/                      # Form widgets
│   │       ├── login_form.dart
│   │       └── register_form.dart
│   ├── models/                         # Data models
│   │   ├── user.dart
│   │   ├── post.dart
│   │   └── comment.dart
│   ├── services/                       # Business logic services
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   └── storage_service.dart
│   ├── providers/                      # State management
│   │   ├── auth_provider.dart
│   │   ├── feed_provider.dart
│   │   └── user_provider.dart
│   ├── utils/                          # Utility functions
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   └── validators.dart
│   └── config/                         # Configuration
│       ├── app_config.dart
│       ├── theme.dart
│       └── routes.dart
├── assets/                             # Static assets
│   ├── images/                         # Image files
│   ├── icons/                          # Icon files
│   ├── fonts/                          # Custom fonts
│   └── animations/                     # Lottie animations
├── test/                               # Test files
│   ├── unit/                           # Unit tests
│   ├── widget/                         # Widget tests
│   └── integration/                    # Integration tests
├── docs/                               # Documentation
├── android/                            # Android-specific code
├── ios/                                # iOS-specific code
├── web/                                # Web-specific code
├── pubspec.yaml                        # Dependencies
├── analysis_options.yaml              # Linting rules
└── README.md                           # Project documentation
```

### **Flat Structure Benefits**
- **Simple to understand** and navigate
- **Fast development** for small teams
- **Easy refactoring** when starting out
- **Minimal cognitive overhead**
- **Perfect for rapid prototyping**

---

## Phase 2: Feature Grouping (Growing Projects)

**Perfect for**: 10-30 screens, multiple developers, clear feature boundaries

```
flutter_rork_app/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── app.dart                        # App configuration
│   ├── features/                       # Feature modules
│   │   ├── auth/                       # Authentication feature
│   │   │   ├── screens/                # Auth screens
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── widgets/                # Auth-specific widgets
│   │   │   │   ├── auth_form.dart
│   │   │   │   └── social_login_button.dart
│   │   │   ├── providers/              # Auth state management
│   │   │   │   └── auth_provider.dart
│   │   │   ├── services/               # Auth services
│   │   │   │   └── auth_service.dart
│   │   │   └── models/                 # Auth models
│   │   │       └── user.dart
│   │   ├── feed/                       # Feed feature
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   └── models/
│   │   ├── profile/                    # Profile feature
│   │   │   ├── screens/
│   │   │   ├── widgets/
│   │   │   ├── providers/
│   │   │   ├── services/
│   │   │   └── models/
│   │   └── chat/                       # Chat feature
│   │       ├── screens/
│   │       ├── widgets/
│   │       ├── providers/
│   │       ├── services/
│   │       └── models/
│   ├── shared/                         # Shared across features
│   │   ├── widgets/                    # Common widgets
│   │   ├── services/                   # Shared services
│   │   ├── models/                     # Global models
│   │   ├── providers/                  # Global providers
│   │   └── utils/                      # Utility functions
│   ├── core/                           # Core functionality
│   │   ├── config/                     # App configuration
│   │   ├── constants/                  # App constants
│   │   ├── theme/                      # App theming
│   │   ├── routes/                     # Navigation
│   │   └── errors/                     # Error handling
│   └── generated/                      # Generated files
├── assets/                             # Static assets
├── test/                               # Test files
└── [config files...]                   # Configuration files
```

### **Feature Grouping Benefits**
- **Clear feature boundaries**
- **Easier team collaboration**
- **Reduced merge conflicts**
- **Better code organization**
- **Preparation for clean architecture**

---

## Phase 3: Clean Architecture (Large Projects)

**Perfect for**: 30+ screens, large teams, complex business logic

```
flutter_rork_app/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── app.dart                        # App configuration
│   ├── features/                       # Feature modules
│   │   ├── auth/                       # Authentication feature
│   │   │   ├── presentation/           # UI layer
│   │   │   │   ├── screens/
│   │   │   │   ├── widgets/
│   │   │   │   └── providers/
│   │   │   ├── domain/                 # Business logic layer
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── data/                   # Data layer
│   │   │       ├── models/
│   │   │       ├── repositories/
│   │   │       └── datasources/
│   │   ├── feed/                       # Feed feature
│   │   │   ├── presentation/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   └── profile/                    # Profile feature
│   │       ├── presentation/
│   │       ├── domain/
│   │       └── data/
│   ├── shared/                         # Shared across features
│   │   ├── presentation/               # Shared UI components
│   │   ├── domain/                     # Shared business logic
│   │   └── data/                       # Shared data layer
│   ├── core/                           # Core functionality
│   │   ├── config/                     # App configuration
│   │   ├── constants/                  # App constants
│   │   ├── theme/                      # App theming
│   │   ├── routes/                     # Navigation
│   │   ├── network/                    # Network configuration
│   │   ├── storage/                    # Local storage
│   │   ├── utils/                      # Utility functions
│   │   └── errors/                     # Error handling
│   └── generated/                      # Generated files
├── assets/                             # Static assets
├── test/                               # Test files
└── [config files...]                   # Configuration files
```

### **Clean Architecture Benefits**
- **Maximum scalability**
- **Team independence**
- **Clear separation of concerns**
- **Easier testing and maintenance**
- **Supports complex business logic**

---

## File Naming Conventions

### Dart Files
- **Screens**: `login_screen.dart`, `home_screen.dart`
- **Widgets**: `custom_button.dart`, `post_card.dart`
- **Models**: `user.dart`, `post.dart`
- **Services**: `auth_service.dart`, `api_service.dart`
- **Providers**: `auth_provider.dart`, `feed_provider.dart`
- **Utils**: `validators.dart`, `helpers.dart`

### Directories
- Use **snake_case** for directory names
- Group related files together
- Keep directory names descriptive but concise

## Import Organization

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter framework imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party package imports
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// 4. Internal imports (absolute paths)
import 'package:flutter_rork_app/features/auth/auth.dart';
import 'package:flutter_rork_app/shared/widgets/widgets.dart';

// 5. Relative imports (same feature)
import '../widgets/login_form.dart';
import 'register_screen.dart';
```

## Configuration Files

### pubspec.yaml Structure

```yaml
name: flutter_rork_app
description: A production-grade Flutter Instagram clone
version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: ">=3.35.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  
  # Navigation
  go_router: ^12.0.0
  
  # Network & API
  dio: ^5.3.0
  supabase_flutter: ^2.0.0
  
  # UI & Styling
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.0
  
  # Storage
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
  
  fonts:
    - family: CustomFont
      fonts:
        - asset: assets/fonts/CustomFont-Regular.ttf
        - asset: assets/fonts/CustomFont-Bold.ttf
          weight: 700
```

## Migration Guide

### 🔄 **Phase 1 → Phase 2 Migration**

1. **Create feature directories**:
   ```bash
   mkdir -p lib/features/{auth,feed,profile,chat}
   ```

2. **Move related files**:
   ```bash
   # Move auth-related files
   mv lib/screens/auth lib/features/auth/screens/
   mv lib/widgets/forms/login_form.dart lib/features/auth/widgets/
   ```

3. **Update imports** to use new paths
4. **Create shared directory** for common components

### 🔄 **Phase 2 → Phase 3 Migration**

1. **Create layer directories**:
   ```bash
   mkdir -p lib/features/auth/{presentation,domain,data}
   ```

2. **Separate concerns**:
   - Move UI to `presentation/`
   - Move business logic to `domain/`
   - Move data handling to `data/`

3. **Update imports** and dependencies
4. **Implement dependency injection**

## Best Practices

### 1. Code Organization
- **One class per file**
- **Group related functionality**
- **Use barrel exports** (index.dart files)
- **Keep files focused and small**

### 2. State Management
- **Choose appropriate state solution** for project size
- **Keep state close to where it's used**
- **Use immutable state objects**
- **Implement proper error handling**

### 3. Testing Structure
- **Mirror lib/ structure in test/**
- **Write tests for business logic**
- **Use widget tests for UI components**
- **Implement integration tests for user flows**

## Decision Matrix

| Project Size | Team Size | Complexity | Recommended Phase |
|--------------|-----------|------------|-------------------|
| 1-10 screens | 1-2 devs  | Simple     | **Phase 1** (Flat) |
| 10-30 screens| 2-5 devs  | Medium     | **Phase 2** (Feature) |
| 30+ screens  | 5+ devs   | Complex    | **Phase 3** (Clean) |

## Next Steps

1. **Assess your current project** using the decision matrix
2. **Choose the appropriate phase** for your project size and team
3. **Set up your project structure** following the templates
4. **Plan migration path** for future growth
5. **Proceed to [Supabase Setup](supabase-setup.md)**

---

**Pro Tip**: Start simple and evolve progressively. Each phase builds upon the previous one, making migration straightforward when the time comes.
