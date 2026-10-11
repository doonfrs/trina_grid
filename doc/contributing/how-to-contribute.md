# How to Contribute

Thank you for your interest in contributing to TrinaGrid! This guide will help you get started with contributing to the project.

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Git
- A GitHub account

### Setting Up the Development Environment

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/trina_grid.git
   cd trina_grid
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/doonfrs/trina_grid.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## Making Changes

### 1. Create a Feature Branch

Always create a new branch for your changes:

```bash
git checkout -b feature/your-feature-name
# or for bug fixes:
git checkout -b fix/your-bug-description
```

### 2. Make Your Changes

- Follow the existing code style and conventions
- Write clear, descriptive commit messages
- Test your changes thoroughly
- Update documentation if needed

### 3. Testing

Run the tests to ensure your changes don't break anything:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

For bugs that only show up in a real app window (scrolling, alignment, focus, keyboard), also add an end to end test that runs the grid in a desktop app and saves screenshots. See [End to End Testing](e2e-testing.md).

### 4. Commit Your Changes

Use clear, descriptive commit messages:

```bash
git add .
git commit -m "feat: add new column type for date picker

- Implements TrinaDateColumn for date selection
- Adds date picker renderer
- Includes unit tests and documentation"
```

### 5. Push and Create a Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub with:
- A clear title describing the change
- A detailed description of what was changed and why
- Any relevant issue numbers
- Screenshots or GIFs for UI changes

## Code Style Guidelines

### Dart/Flutter

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Documentation

- Update relevant documentation files
- Add examples for new features
- Include code samples in markdown files
- Update the changelog for significant changes

## Types of Contributions

### Bug Fixes

- Reproduce the bug with a minimal example
- Fix the issue
- Add tests to prevent regression
- Update documentation if needed

### New Features

- Discuss the feature in an issue first
- Implement the feature with tests
- Add documentation and examples
- Consider backward compatibility

### Documentation

- Fix typos and grammar
- Add missing information
- Improve existing examples
- Create new guides

### Testing

- Add unit tests for new features
- Improve test coverage
- Add integration tests
- Test on different platforms

## Pull Request Process

1. **Ensure your code follows the project's style guidelines**
2. **Add tests for new functionality**
3. **Update documentation as needed**
4. **Make sure all tests pass**
5. **Request review from maintainers**

## Getting Help

If you need help or have questions:

- **Open an issue** for bugs or feature requests
- **Join discussions** in existing issues
- **Ask questions** in the GitHub discussions
- **Check the documentation** for existing guides

## Recognition

All contributors will be:
- Added to the [Contributors](contributors.md) page
- Recognized in release notes
- Listed in the project's GitHub contributors

## Code of Conduct

Please read and follow our [Code of Conduct](code-of-conduct.md) to ensure a welcoming and inclusive environment for all contributors.

---

Thank you for contributing to TrinaGrid! Your contributions help make this project better for everyone. 🎉
