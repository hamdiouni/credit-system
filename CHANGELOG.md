# Changelog

All notable changes to the Credit System project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-02-16

### Added
- Auto-focus on text fields when screens open
- Auto-scroll to action buttons as user types
- Keyboard optimization with proper input types
- Smooth animations for scrolling (500ms ease-in-out)
- Offline-only mode with all online features commented out

### Changed
- Removed connectivity checking to improve performance
- Simplified connection status widget for offline operation
- Commented out http, mongo_dart, and connectivity_plus dependencies
- Improved text input flow with Next/Done actions

### Fixed
- Keyboard not appearing automatically on text fields
- Manual scrolling required to reach Save buttons
- Slow app startup due to connectivity checks

### Performance
- Faster app initialization
- Reduced app size
- Smoother UI animations
- Lower battery consumption

## [1.0.1] - 2026-02-16

### Fixed
- **Critical**: Balance credit consumption bug - balance now properly reduces debt
  - Example: 10 TND balance + 12 TND debt now correctly shows 2 TND debt
- PDF documentation generation errors (emoji and border radius issues)
- Debt calculator treating BALANCE_CREDIT transactions incorrectly

### Changed
- Transaction provider logic for balance credit consumption
- Only remaining debt is added as credit transaction
- Balance credit fully consumed before adding new debt

## [1.0.0] - 2026-02-15

### Added
- Multi-user authentication with PIN
- Customer management (CRUD operations)
- Credit/Debt tracking with 70+ grocery items in 12 categories
- Payment recording with overpayment protection
- Automatic balance credit system
- Transaction history with edit/delete capabilities
- PDF export for customer statements
- CSV export for transaction data
- Backup and restore functionality
- Multi-language support (English, Arabic, French, Tunisian)
- RTL layout support for Arabic languages
- Audit logging for all user actions
- Performance monitoring and health checks
- Error logging and tracking
- In-app user documentation with diagrams
- Offline-first architecture
- Cross-platform support (Android, Windows, Web)

### Features by Category

#### Customer Management
- Add customers with name and phone
- Edit customer information
- Delete customers (with debt validation)
- Search customers by name
- View customer debt and transaction history

#### Transaction Management
- Record credit/purchases with itemized lists
- Process payments with amount validation
- Handle overpayments with balance credit
- Edit and delete transactions
- Filter and sort transaction history

#### Reporting & Export
- Generate PDF customer statements
- Export transactions to CSV
- Multi-language PDF support
- Professional formatting with Arabic support

#### Data Management
- Create full database backups (JSON)
- Restore from backup with validation
- Data migration tools
- Audit trail of all operations

#### Localization
- 4 languages: English, Arabic, French, Tunisian (Derja)
- RTL/LTR layout switching
- Localized number formatting
- Localized date/time display

#### Security
- PIN-based authentication
- Multi-user support
- Role-based access (Admin/Cashier)
- Audit logging
- Local data storage (no cloud)

### Technical Details
- Built with Flutter 3.0+
- SQLite database (sqflite)
- Provider state management
- Clean architecture pattern
- Offline-first design

---

## Release Notes

For detailed information about each release:
- [v1.0.2 Details](docs/development/changelog/UX_IMPROVEMENTS_COMPLETE.txt)
- [v1.0.1 Details](docs/development/changelog/FINAL_FIX_COMPLETE.txt)
- [v1.0.0 Details](docs/development/changelog/FINAL_UPDATES_COMPLETE.md)

## Upgrade Guide

### From v1.0.1 to v1.0.2
1. Install new version (Android: install APK, Windows: extract ZIP)
2. Data is preserved automatically
3. No manual migration needed
4. Test auto-focus and auto-scroll features

### From v1.0.0 to v1.0.1
1. Install new version
2. Data is preserved
3. Test balance credit consumption with: 10 TND balance + 12 TND debt = 2 TND

## Known Issues

### v1.0.2
- None reported

### v1.0.1
- None reported

### v1.0.0
- Balance credit not reducing debt (fixed in v1.0.1)
- PDF generation errors in some languages (fixed in v1.0.1)

## Future Releases

### Planned for v1.1.0
- iOS support
- Cloud sync (optional)
- Dashboard with charts
- SMS reminders
- Barcode scanning

### Planned for v1.2.0
- Multi-store support
- Employee permissions
- Advanced reporting
- Custom receipt templates

### Planned for v2.0.0
- Online payment integration
- WhatsApp integration
- API for third-party apps
- Mobile POS features

---

**Note**: All dates use YYYY-MM-DD format (ISO 8601)
