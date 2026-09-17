# Deployment Checklist 🚀

## Pre-Deployment Verification

### Code Quality ✅
- [x] Flutter analyze passes (only info-level warnings)
- [x] No compilation errors
- [x] All imports are used
- [x] No deprecated API usage (except expected dart:html)

### Localization ✅
- [x] All UI text uses l10n keys
- [x] English translations complete
- [x] Arabic translations complete
- [x] French translations complete
- [x] No hardcoded strings in UI

### Features ✅
- [x] Customer CRUD operations work
- [x] Credit transactions work
- [x] Payment transactions work
- [x] Overpayment with balance credit works
- [x] Balance credit displays correctly
- [x] PDF export works in all languages
- [x] Search functionality works
- [x] Language switching works

---

## Platform-Specific Deployment

### Web Deployment 🌐

#### Build Command
```bash
flutter build web --release
```

#### Output Location
```
build/web/
```

#### Deployment Steps
1. Run build command
2. Test locally: `flutter run -d chrome --release`
3. Upload `build/web/` contents to web server
4. Configure web server for Flutter routing
5. Test on production URL

#### Web Server Configuration (nginx example)
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/build/web;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

### Android Deployment 📱

#### Prerequisites
- [ ] Android SDK installed
- [ ] Signing key generated
- [ ] `key.properties` configured

#### Build Command
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### Output Location
```
build/app/outputs/flutter-apk/app-release.apk
# or
build/app/outputs/bundle/release/app-release.aab
```

#### Deployment Steps
1. Generate signing key (first time only)
2. Configure `android/key.properties`
3. Update `android/app/build.gradle.kts` with signing config
4. Run build command
5. Test APK on physical device
6. Upload to Google Play Console

#### Signing Key Generation
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

---

### Windows Deployment 💻

#### Prerequisites
- [ ] Windows SDK installed
- [ ] Visual Studio 2022 or later

#### Build Command
```bash
flutter build windows --release
```

#### Output Location
```
build/windows/runner/Release/
```

#### Deployment Steps
1. Run build command
2. Test executable on Windows machine
3. Create installer (optional - use Inno Setup or similar)
4. Distribute installer or zip file

#### Creating Installer (Inno Setup)
```iss
[Setup]
AppName=Credit Manager
AppVersion=1.0.0
DefaultDirName={pf}\CreditManager
DefaultGroupName=Credit Manager
OutputDir=installer
OutputBaseFilename=CreditManagerSetup

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs
```

---

## Database Setup

### MongoDB Connection

#### Development
```javascript
mongodb://localhost:27017/credit_app
```

#### Production
Update `server.js` or `server.cjs`:
```javascript
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/credit_app';
```

#### Environment Variables
```bash
# .env file
MONGODB_URI=mongodb://your-production-server:27017/credit_app
PORT=3000
```

---

## Server Deployment

### Node.js Server

#### Start Server
```bash
node server.js
# or
node server.cjs
```

#### Production with PM2
```bash
# Install PM2
npm install -g pm2

# Start server
pm2 start server.js --name credit-app-server

# Save configuration
pm2 save

# Setup auto-restart on reboot
pm2 startup
```

#### Server Configuration
- Port: 3000 (default)
- CORS: Enabled for all origins (configure for production)
- MongoDB: localhost:27017 (configure for production)

---

## Testing Checklist

### Manual Testing
- [ ] Test in English language
- [ ] Test in Arabic language (RTL)
- [ ] Test in French language
- [ ] Add customer
- [ ] Add credit transaction
- [ ] Add payment transaction
- [ ] Test overpayment with balance credit
- [ ] Export PDF in all languages
- [ ] Search customers
- [ ] Delete customer (with/without transactions)
- [ ] Test on different screen sizes
- [ ] Test on mobile device (if Android)
- [ ] Test on desktop (if Windows)

### Performance Testing
- [ ] Load 100+ customers
- [ ] Load 1000+ transactions
- [ ] Test search with many customers
- [ ] Test PDF export with many transactions
- [ ] Monitor memory usage
- [ ] Check for memory leaks

### Security Testing
- [ ] Test phone number uniqueness
- [ ] Test input validation
- [ ] Test SQL injection (should be prevented)
- [ ] Test XSS attacks (should be prevented)
- [ ] Verify no sensitive data in logs

---

## Post-Deployment Verification

### Smoke Tests
1. [ ] App loads successfully
2. [ ] Can add customer
3. [ ] Can add transaction
4. [ ] Can export PDF
5. [ ] Language switching works
6. [ ] No console errors

### Monitoring
- [ ] Setup error logging
- [ ] Setup performance monitoring
- [ ] Setup uptime monitoring
- [ ] Setup database backups

---

## Rollback Plan

### If Deployment Fails

1. **Identify Issue**
   - Check error logs
   - Check browser console
   - Check server logs

2. **Quick Fix or Rollback**
   - If quick fix possible: Deploy hotfix
   - If not: Rollback to previous version

3. **Rollback Steps**
   - Restore previous build
   - Restart server
   - Verify functionality
   - Investigate issue offline

---

## Environment-Specific Configuration

### Development
```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = 'http://localhost:3000';
  static const bool isProduction = false;
}
```

### Production
```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = 'https://api.your-domain.com';
  static const bool isProduction = true;
}
```

---

## Version Management

### Current Version
```yaml
# pubspec.yaml
version: 1.0.0+1
```

### Version Numbering
- Major.Minor.Patch+BuildNumber
- Example: 1.0.0+1
- Increment for each release

### Release Notes Template
```markdown
## Version 1.0.0

### New Features
- Customer management
- Credit/Payment tracking
- Balance credit support
- Multi-language support (EN, AR, FR)
- PDF export

### Bug Fixes
- None (initial release)

### Known Issues
- None
```

---

## Support & Maintenance

### Documentation
- [x] User guide created
- [x] Developer documentation
- [x] API documentation (if applicable)
- [x] Deployment guide (this file)

### Backup Strategy
- [ ] Daily database backups
- [ ] Weekly full backups
- [ ] Backup retention: 30 days
- [ ] Test restore procedure

### Update Strategy
- [ ] Monthly security updates
- [ ] Quarterly feature updates
- [ ] Annual major version updates

---

## Contact & Support

### Technical Support
- Developer: [Your Name]
- Email: [Your Email]
- Phone: [Your Phone]

### Emergency Contacts
- Database Admin: [Name/Contact]
- Server Admin: [Name/Contact]
- DevOps: [Name/Contact]

---

## Final Checklist

Before going live:

- [ ] All tests pass
- [ ] Code reviewed
- [ ] Documentation complete
- [ ] Backups configured
- [ ] Monitoring setup
- [ ] Support team trained
- [ ] Rollback plan tested
- [ ] Performance acceptable
- [ ] Security verified
- [ ] Stakeholders notified

---

**Status**: Ready for deployment ✅

**Last Updated**: February 1, 2026
