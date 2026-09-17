# Credit System - Customer Credit Management App

![Version](https://img.shields.io/badge/version-1.0.2-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows%20%7C%20Web-lightgrey)
![License](https://img.shields.io/badge/license-Proprietary-red)

A professional, offline-first credit management application for small businesses to track customer debt, payments, and inventory. Built with Flutter for cross-platform deployment.

## 🌟 Features

### Core Features
- **Customer Management**: Add, edit, and delete customers with contact information
- **Credit Tracking**: Record purchases on credit with 70+ predefined grocery items
- **Payment Recording**: Track payments with overpayment protection and balance credit
- **Transaction History**: View, edit, and delete all customer transactions
- **Balance Credit System**: Automatic balance credit consumption on new purchases

### Advanced Features
- **Multi-User Authentication**: PIN-based user management with role support
- **PDF Export**: Generate professional customer statements
- **CSV Export**: Export transaction data for analysis
- **Backup & Restore**: Create and restore complete database backups
- **Audit Logging**: Track all user actions for accountability
- **Multi-Language**: English, Arabic, French, and Tunisian (Derja)
- **RTL Support**: Full right-to-left layout for Arabic languages
- **Offline-First**: 100% offline operation, no internet required

### UX Enhancements (v1.0.2)
- **Auto-Focus**: Text fields automatically focused with keyboard ready
- **Auto-Scroll**: Smooth scrolling to action buttons as you type
- **Optimized Performance**: Faster startup, smoother animations
- **Keyboard Optimization**: Proper input types and flow

## 📱 Platforms

| Platform | Status | Build Size | Notes |
|----------|--------|------------|-------|
| Android | ✅ Ready | 64 MB | Android 5.0+ |
| Windows | ✅ Ready | 16 MB (ZIP) | Windows 10/11 |
| Web | ✅ Ready | TBD | Modern browsers |
| iOS | ⏳ Planned | - | Future release |
| macOS | ⏳ Planned | - | Future release |
| Linux | ⏳ Planned | - | Future release |

## 🚀 Quick Start

### For Users

#### Android
1. Download `app-release.apk` from releases
2. Install on your Android device
3. Create your first user account
4. Start managing customers!

#### Windows
1. Download `CreditSystem_Windows_Portable.zip` from releases
2. Extract anywhere on your PC
3. Run `credit_app.exe`
4. No installation needed!

See [User Guide](docs/user-guides/USER_GUIDE_ENGLISH.md) for detailed instructions.

### For Developers

```bash
# Clone repository
git clone https://github.com/yourusername/credit-system.git
cd credit-system

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for production
flutter build apk --release        # Android
flutter build windows --release    # Windows
flutter build web --release        # Web
```

## 📖 Documentation

### User Documentation
- [English User Guide](docs/user-guides/USER_GUIDE_ENGLISH.md)
- [Arabic User Guide](docs/user-guides/USER_GUIDE_ARABIC.md)
- [Quick Start Guide](docs/user-guides/QUICK_START_GUIDE.md)
- [How to Use on Another PC](docs/deployment/HOW_TO_USE_ON_ANOTHER_PC.txt)

### Developer Documentation
- [Project Architecture](docs/development/ARCHITECTURE.md)
- [Build Guide](docs/deployment/BUILD_GUIDE.md)
- [Deployment Checklist](docs/deployment/DEPLOYMENT_CHECKLIST.md)
- [Maintenance Guide](docs/maintenance/MAINTENANCE_GUIDE.md)

### Development Logs
- [UX Improvements](docs/development/changelog/UX_IMPROVEMENTS_COMPLETE.txt)
- [Balance Credit Fix](docs/development/changelog/FINAL_FIX_COMPLETE.txt)
- [All Releases](docs/development/changelog/)

## 🏗️ Architecture

```
credit_app/
├── lib/
│   ├── data/              # Data layer (DAOs, repositories)
│   ├── domain/            # Business logic (models, services)
│   ├── presentation/      # UI layer (screens, widgets)
│   ├── providers/         # State management (Provider)
│   ├── services/          # App services (PDF, backup, etc.)
│   ├── utils/             # Utilities and helpers
│   └── l10n/              # Localization files
├── docs/                  # Documentation
├── android/               # Android native code
├── windows/               # Windows native code
└── web/                   # Web specific files
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart 3.0+
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **PDF Generation**: pdf + printing
- **Localization**: intl + flutter_localizations
- **Platform Support**: sqflite_common_ffi (desktop)

## 📦 Key Dependencies

```yaml
dependencies:
  flutter: sdk
  provider: ^6.1.2
  sqflite: ^2.4.1
  pdf: ^3.11.1
  printing: ^5.13.4
  arabic_reshaper: ^0.0.1
  intl: ^0.20.2
  shared_preferences: ^2.3.4
```

## 🌐 Internationalization

Supported Languages:
- 🇬🇧 English (`en`)
- 🇸🇦 Arabic (`ar`)
- 🇫🇷 French (`fr`)
- 🇹🇳 Tunisian Arabic / Derja (`tn`)

RTL (Right-to-Left) fully supported for Arabic languages.

## 🔒 Security & Privacy

- **Offline-First**: All data stored locally, no cloud sync
- **PIN Protection**: 4-digit PIN for user authentication
- **Audit Trail**: Complete logging of all user actions
- **Data Encryption**: Database encryption available (optional)
- **No Tracking**: Zero telemetry or analytics

## 📊 Data Management

### Backup & Restore
- Create JSON backups of entire database
- Restore from backup with validation
- Export to multiple locations (USB, cloud, email)

### Data Export
- PDF: Customer statements with transaction history
- CSV: Transaction data for spreadsheet analysis
- Local file system access

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Check code quality
flutter analyze
```

## 📈 Roadmap

### v1.1.0 (Planned)
- [ ] iOS support
- [ ] Cloud sync (optional)
- [ ] Dashboard with charts
- [ ] SMS reminders
- [ ] Barcode scanning

### v1.2.0 (Planned)
- [ ] Multi-store support
- [ ] Employee permissions
- [ ] Advanced reporting
- [ ] Custom receipt templates

### v2.0.0 (Future)
- [ ] Online payment integration
- [ ] WhatsApp integration
- [ ] API for third-party apps
- [ ] Mobile POS features

## 🤝 Contributing

This is a proprietary project. Contributions are not currently accepted.

For bug reports or feature requests, contact the developer directly.

## 📄 License

Proprietary - All Rights Reserved

This software is not open source. Usage, modification, and distribution require explicit permission from the author.

## 👨‍💻 Author

**Your Name**
- Email: your.email@example.com
- Website: yourwebsite.com
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Arabic reshaper package for RTL support
- All users providing feedback

## 📞 Support

For support, email support@yourcompany.com or open an issue in the repository.

---

**Made with ❤️ using Flutter**

**Current Version**: 1.0.2 (UX Enhanced + Offline-Only)
**Last Updated**: February 2026
