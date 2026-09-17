# Contributing to Credit System

This project is currently **not accepting public contributions** as it is a proprietary product. However, this document outlines guidelines for team members and authorized developers.

## Code of Conduct

- Write clean, readable code
- Follow Dart and Flutter best practices
- Write tests for new features
- Document your changes
- Keep commits atomic and meaningful

## Development Setup

### Prerequisites
- Flutter 3.0 or higher
- Dart 3.0 or higher
- Android SDK (for Android development)
- Visual Studio (for Windows development)
- SQLite development libraries

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/credit-system.git
cd credit-system

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── data/              # Data layer (database, DAOs, repositories)
├── domain/            # Domain layer (models, services, entities)
├── presentation/      # Presentation layer (screens, widgets)
├── providers/         # State management with Provider
├── services/          # App services (PDF, backup, auth, etc.)
├── utils/             # Utilities and helpers
├── l10n/              # Localization files
└── widgets/           # Reusable widgets
```

## Coding Standards

### Dart Style Guide
- Follow official Dart style guidelines
- Use `const` constructors where possible
- Avoid magic numbers
- Write meaningful variable names

### Naming Conventions
- Classes: `PascalCase` (e.g., `AddCreditScreen`)
- Variables: `camelCase` (e.g., `amountController`)
- Constants: `camelCase` (e.g., `maxRetries`)
- Private members: prefix with `_` (e.g., `_isLoading`)

### Documentation
- Add comments for complex logic
- Use documentation comments (`///`) for public APIs
- Include examples in documentation
- Keep documentation up-to-date

## Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that don't affect code meaning
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `perf`: Code change that improves performance
- `test`: Adding missing tests
- `chore`: Changes to build process or dependencies

### Example
```
feat(transaction): add balance credit consumption

Implement automatic balance credit consumption when adding new debt.
When a customer has balance credit and new debt is added, the balance
is automatically consumed to reduce the actual debt amount.

Fixes #123
```

## Testing Requirements

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

### Manual Testing Checklist
- [ ] Feature works on Android
- [ ] Feature works on Windows
- [ ] Feature works on Web
- [ ] All languages display correctly
- [ ] RTL works for Arabic
- [ ] Offline functionality works

## Code Review Process

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Write/update tests
4. Update documentation
5. Commit with meaningful messages
6. Push to your fork
7. Create a Pull Request

### PR Requirements
- Clear description of changes
- Link to related issues
- Screenshots for UI changes
- Test results
- Updated documentation

## Performance Considerations

- Minimize rebuilds with proper state management
- Use `const` constructors
- Lazy load data
- Optimize database queries
- Cache frequently used data
- Profile before optimizing

## Security Guidelines

- Never commit sensitive data
- Use environment variables for secrets
- Validate all user input
- Use parameterized queries
- Keep dependencies updated
- Review security advisories

## Localization

When adding new strings:

1. Add to `lib/l10n/app_en.arb`
2. Add translations to other ARB files
3. Update generated localization files
4. Test in all 4 languages

## Database Changes

For schema changes:

1. Create migration script
2. Update database helper
3. Update DAOs/repositories
4. Test backup/restore
5. Document changes

## Debugging

### Enable Debug Logging
```dart
import 'package:credit_app/services/app_logger.dart';

AppLogger.info('Message', context: 'YourClass');
```

### Common Issues

**Issue**: Build fails with dependency errors
**Solution**: Run `flutter clean && flutter pub get`

**Issue**: Database locked error
**Solution**: Close all instances of the app

**Issue**: Hot reload doesn't work
**Solution**: Use `flutter run` to restart

## Release Process

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Tag release: `git tag v1.0.0`
4. Build apps:
   ```bash
   flutter build apk --release
   flutter build windows --release
   ```
5. Create GitHub release with binaries

## Questions or Need Help?

- Check the [documentation](docs/)
- Review existing issues
- Ask the team lead
- Check Flutter documentation

## License

By contributing to this project, you agree that your contributions will be licensed under the project's proprietary license.

---

**Note**: This is a proprietary project. All contributions are the property of the project owner.
