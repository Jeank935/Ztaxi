# Contributing to Elite Taxi App

Thank you for considering contributing to Elite Taxi App! This document provides guidelines and instructions for contributing to the project.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include screenshots if applicable**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## Development Process

### Setting Up Development Environment

1. **Fork and Clone**
   ```bash
   git clone https://github.com/yourusername/elite_taxi_app.git
   cd elite_taxi_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

### Making Changes

1. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Write clean, readable code
   - Follow the existing code style
   - Add comments where necessary
   - Update documentation if needed

3. **Test Your Changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add: descriptive commit message"
   ```

### Commit Message Guidelines

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

**Commit Message Format:**
```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `Add:` New feature
- `Fix:` Bug fix
- `Update:` Updates to existing features
- `Remove:` Removing code or files
- `Refactor:` Code refactoring
- `Style:` Code style changes (formatting, etc.)
- `Docs:` Documentation changes
- `Test:` Adding or updating tests

**Example:**
```
Add: Google Maps integration for ride tracking

Implemented real-time location tracking using Google Maps API.
Added custom markers for pickup and drop-off locations.
Integrated route visualization with polylines.

Closes #123
```

## Code Style Guidelines

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guide:

- **Use meaningful names**: Variables, functions, and classes should have clear, descriptive names
- **Follow naming conventions**:
  - Classes: `PascalCase`
  - Variables and functions: `camelCase`
  - Constants: `lowerCamelCase` or `SCREAMING_CAPS`
- **Keep functions small**: A function should do one thing well
- **Use null safety**: Leverage Dart's null safety features
- **Document public APIs**: Use dartdoc comments for public classes and methods

### Code Formatting

Use `dart format` to format your code:
```bash
dart format lib/
```

### Import Organization

Organize imports in the following order:
1. Dart SDK imports
2. Flutter imports
3. Package imports
4. Relative imports

```dart
// Dart SDK
import 'dart:async';
import 'dart:io';

// Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Packages
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Local
import '../controller/auth_controller.dart';
import '../widgets/my_button.dart';
```

### Widget Organization

- Extract reusable widgets into separate files
- Keep widget files focused and small
- Use StatelessWidget when possible
- Organize widgets in logical folders

### State Management

- Use GetX for state management
- Keep controllers focused on specific features
- Use reactive programming where appropriate
- Don't create unnecessary controllers

## Testing Guidelines

### Writing Tests

- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for critical user flows

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/controller/auth_controller_test.dart
```

## Documentation

### Code Documentation

- Add dartdoc comments for public APIs
- Explain complex logic with inline comments
- Keep comments up-to-date with code changes

### README Updates

- Update README.md if adding new features
- Keep installation instructions current
- Update dependencies list when adding packages

## Review Process

1. All pull requests require at least one approval
2. CI checks must pass
3. Code must be reviewed for:
   - Correctness
   - Code style
   - Performance
   - Security

## Questions?

If you have questions about contributing, please:
- Open an issue with the `question` label
- Check existing issues and discussions
- Contact the maintainers

Thank you for contributing! 🎉
