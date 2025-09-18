# Code Quality

Comprehensive guide to maintaining high code quality in Flutter applications through linting, formatting, and best practices.

## Overview

Code quality is essential for maintainable, scalable Flutter applications. This guide covers static analysis, formatting, linting rules, and quality metrics.

## Static Analysis Configuration

### 1. Analysis Options

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
    - "lib/generated/**"
  
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  
  errors:
    invalid_annotation_target: ignore
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    # Error rules
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - test_types_in_equals
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks
    - valid_regexps
    
    # Style rules
    - always_declare_return_types
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - always_require_non_null_named_parameters
    - annotate_overrides
    - avoid_annotating_with_dynamic
    - avoid_bool_literals_in_conditional_expressions
    - avoid_catches_without_on_clauses
    - avoid_catching_errors
    - avoid_double_and_int_checks
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_implementing_value_types
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_redundant_argument_values
    - avoid_renaming_method_parameters
    - avoid_return_types_on_setters
    - avoid_returning_null
    - avoid_returning_null_for_void
    - avoid_setters_without_getters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_unnecessary_containers
    - avoid_unused_constructor_parameters
    - avoid_void_async
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cascade_invocations
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - file_names
    - flutter_style_todos
    - implementation_imports
    - join_return_with_assignment
    - leading_newlines_in_multiline_strings
    - library_names
    - library_prefixes
    - lines_longer_than_80_chars
    - missing_whitespace_between_adjacent_strings
    - no_runtimeType_toString
    - non_constant_identifier_names
    - null_closures
    - omit_local_variable_types
    - one_member_abstracts
    - only_throw_errors
    - overridden_fields
    - package_api_docs
    - package_prefixed_library_names
    - parameter_assignments
    - prefer_adjacent_string_concatenation
    - prefer_asserts_in_initializer_lists
    - prefer_asserts_with_message
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_constructors_over_static_methods
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_expression_function_bodies
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_foreach
    - prefer_function_declarations_over_variables
    - prefer_generic_function_type_aliases
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_operators
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_iterable_whereType
    - prefer_null_aware_operators
    - prefer_relative_imports
    - prefer_single_quotes
    - prefer_spread_collections
    - prefer_typing_uninitialized_variables
    - provide_deprecation_message
    - public_member_api_docs
    - recursive_getters
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - sort_unnamed_constructors_first
    - type_annotate_public_apis
    - type_init_formals
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_null_in_if_null_operators
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_raw_strings
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_rethrow_when_possible
    - use_setters_to_change_properties
    - use_string_buffers
    - use_to_and_as_if_applicable
    - void_checks
```

### 2. Custom Lint Rules

```dart
// lib/analysis/custom_lint_rules.dart
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class NoHardcodedStringsRule extends DartLintRule {
  const NoHardcodedStringsRule() : super(code: _code);

  static const _code = LintCode(
    name: 'no_hardcoded_strings',
    problemMessage: 'Avoid hardcoded strings. Use localization instead.',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addStringLiteral((node) {
      if (_isHardcodedString(node)) {
        reporter.reportErrorForNode(code, node);
      }
    });
  }

  bool _isHardcodedString(StringLiteral node) {
    // Check if string is user-facing text
    final value = node.stringValue;
    if (value == null || value.length < 3) return false;
    
    // Skip if it's a key or technical string
    if (value.contains('_') || value.contains('.')) return false;
    
    // Check if it contains user-facing text
    return RegExp(r'^[A-Z][a-z\s]+').hasMatch(value);
  }
}
```

## Code Formatting

### 1. Dart Format Configuration

```yaml
# .dart_tool/dart_format_options.yaml
line_length: 80
indent: 2
```

### 2. Format Scripts

```bash
#!/bin/bash
# scripts/format.sh

echo "🎨 Formatting Dart code..."

# Format all Dart files
dart format lib/ test/ --set-exit-if-changed

# Check if formatting was applied
if [ $? -eq 0 ]; then
    echo "✅ Code is properly formatted"
else
    echo "❌ Code formatting issues found"
    echo "Run 'dart format lib/ test/' to fix formatting"
    exit 1
fi
```

### 3. IDE Configuration

```json
// .vscode/settings.json
{
  "dart.lineLength": 80,
  "dart.insertArgumentPlaceholders": false,
  "dart.showTodos": true,
  "dart.runPubGetOnPubspecChanges": true,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.formatOnType": true,
  "editor.rulers": [80],
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true
}
```

## Code Metrics

### 1. Complexity Analysis

```dart
// lib/analysis/complexity_analyzer.dart
class ComplexityAnalyzer {
  static void analyzeFile(String filePath) {
    final file = File(filePath);
    final content = file.readAsStringSync();
    
    final lines = content.split('\n');
    final codeLines = lines.where((line) => 
      line.trim().isNotEmpty && 
      !line.trim().startsWith('//') &&
      !line.trim().startsWith('/*')
    ).length;
    
    final methods = RegExp(r'\w+\s*\([^)]*\)\s*{').allMatches(content).length;
    final classes = RegExp(r'class\s+\w+').allMatches(content).length;
    
    print('File: $filePath');
    print('Lines of code: $codeLines');
    print('Methods: $methods');
    print('Classes: $classes');
    
    if (codeLines > 500) {
      print('⚠️  File is too large (>500 lines)');
    }
    
    if (methods > 20) {
      print('⚠️  Too many methods in file (>20)');
    }
  }
}
```

### 2. Test Coverage Analysis

```bash
#!/bin/bash
# scripts/coverage-analysis.sh

echo "📊 Analyzing test coverage..."

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html

# Extract coverage percentage
COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')

echo "Current coverage: $COVERAGE%"

# Check coverage threshold
THRESHOLD=80
if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
    echo "❌ Coverage below threshold ($THRESHOLD%)"
    exit 1
else
    echo "✅ Coverage meets threshold"
fi
```

## Documentation Standards

### 1. Documentation Comments

```dart
// lib/models/user.dart

/// Represents a user in the application.
/// 
/// This class contains all user-related information including
/// authentication details and profile data.
/// 
/// Example:
/// ```dart
/// final user = User(
///   id: '123',
///   email: 'user@example.com',
///   name: 'John Doe',
/// );
/// ```
class User {
  /// The unique identifier for the user.
  final String id;
  
  /// The user's email address.
  /// 
  /// Must be a valid email format and unique across the system.
  final String email;
  
  /// The user's display name.
  /// 
  /// Can be null if the user hasn't set a display name.
  final String? name;
  
  /// Creates a new [User] instance.
  /// 
  /// The [id] and [email] parameters are required.
  /// The [name] parameter is optional.
  const User({
    required this.id,
    required this.email,
    this.name,
  });
  
  /// Creates a [User] from a JSON map.
  /// 
  /// Throws [FormatException] if the JSON is invalid.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
    );
  }
  
  /// Converts this [User] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
```

### 2. README Standards

```markdown
# Feature Name

Brief description of what this feature does.

## Usage

```dart
// Example usage
final feature = FeatureName();
await feature.doSomething();
```

## API Reference

### Methods

#### `doSomething()`

Description of what this method does.

**Parameters:**
- `param1` (String): Description of parameter
- `param2` (int, optional): Description of optional parameter

**Returns:**
- `Future<bool>`: Description of return value

**Throws:**
- `Exception`: When something goes wrong

## Testing

```bash
flutter test test/features/feature_name_test.dart
```
```

## Quality Gates

### 1. Pre-commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Running pre-commit quality checks..."

# Check formatting
dart format lib/ test/ --set-exit-if-changed
if [ $? -ne 0 ]; then
    echo "❌ Code formatting failed"
    exit 1
fi

# Run static analysis
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Static analysis failed"
    exit 1
fi

# Run tests
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ All quality checks passed"
```

### 2. CI/CD Quality Checks

```yaml
# .github/workflows/quality.yml
name: Code Quality

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Check formatting
        run: dart format lib/ test/ --set-exit-if-changed
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage below 80%: $COVERAGE%"
            exit 1
          fi
```

## Code Review Guidelines

### 1. Review Checklist

```markdown
## Code Review Checklist

### Functionality
- [ ] Code does what it's supposed to do
- [ ] Edge cases are handled
- [ ] Error handling is appropriate

### Code Quality
- [ ] Code follows project conventions
- [ ] No code duplication
- [ ] Functions are small and focused
- [ ] Variable names are descriptive

### Performance
- [ ] No obvious performance issues
- [ ] Efficient algorithms used
- [ ] Memory usage is reasonable

### Testing
- [ ] Tests cover new functionality
- [ ] Tests are meaningful and not just for coverage
- [ ] Integration tests for complex features

### Documentation
- [ ] Public APIs are documented
- [ ] Complex logic is explained
- [ ] README updated if needed

### Security
- [ ] No sensitive data exposed
- [ ] Input validation is present
- [ ] Authentication/authorization checked
```

### 2. Review Tools

```dart
// lib/tools/review_helper.dart
class ReviewHelper {
  /// Checks if a class is too large
  static bool isClassTooLarge(String classContent) {
    final lines = classContent.split('\n').length;
    return lines > 300;
  }
  
  /// Checks if a method is too complex
  static bool isMethodTooComplex(String methodContent) {
    final cyclomaticComplexity = _calculateCyclomaticComplexity(methodContent);
    return cyclomaticComplexity > 10;
  }
  
  /// Checks for potential code smells
  static List<String> findCodeSmells(String code) {
    final smells = <String>[];
    
    if (code.contains('TODO')) {
      smells.add('Contains TODO comments');
    }
    
    if (RegExp(r'catch\s*\(\s*\w+\s*\)\s*\{\s*\}').hasMatch(code)) {
      smells.add('Empty catch blocks');
    }
    
    if (code.split('\n').any((line) => line.length > 120)) {
      smells.add('Lines longer than 120 characters');
    }
    
    return smells;
  }
  
  static int _calculateCyclomaticComplexity(String code) {
    // Simplified complexity calculation
    final keywords = ['if', 'else', 'while', 'for', 'switch', 'case', 'catch'];
    int complexity = 1; // Base complexity
    
    for (final keyword in keywords) {
      complexity += RegExp('\\b$keyword\\b').allMatches(code).length;
    }
    
    return complexity;
  }
}
```

## Automated Quality Tools

### 1. Quality Dashboard

```dart
// lib/tools/quality_dashboard.dart
class QualityMetrics {
  final double testCoverage;
  final int lintIssues;
  final int codeSmells;
  final double maintainabilityIndex;
  
  const QualityMetrics({
    required this.testCoverage,
    required this.lintIssues,
    required this.codeSmells,
    required this.maintainabilityIndex,
  });
  
  bool get isHealthy => 
    testCoverage >= 80 &&
    lintIssues == 0 &&
    codeSmells < 5 &&
    maintainabilityIndex >= 70;
}
```

### 2. Quality Reports

```bash
#!/bin/bash
# scripts/quality-report.sh

echo "📊 Generating quality report..."

# Create report directory
mkdir -p reports

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o reports/coverage

# Run static analysis
flutter analyze > reports/analysis.txt 2>&1

# Generate metrics
echo "Quality Report - $(date)" > reports/quality-summary.txt
echo "================================" >> reports/quality-summary.txt

# Coverage
COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}')
echo "Test Coverage: $COVERAGE" >> reports/quality-summary.txt

# Analysis issues
ISSUES=$(flutter analyze 2>&1 | grep -c "info •")
echo "Analysis Issues: $ISSUES" >> reports/quality-summary.txt

echo "✅ Quality report generated in reports/"
```

Code quality is an ongoing process that requires consistent effort and the right tools. Establish quality standards early and enforce them through automation.
