# ADSD Maintenance App

A Flutter-based maintenance management application with offline capabilities.

## Features

- User authentication (Admin/Technician roles)
- Report creation and management
- Offline support with local storage
- Data synchronization
- Camera and signature capture
- Statistics dashboard

## Building the App

### Prerequisites

- Flutter SDK (version 3.19.0 or higher)
- Android Studio
- JDK 17
- Android SDK 34
- Git
- Android device or emulator

### Local Build

1. Clone the repository:
   ```bash
   git clone https://github.com/AneesLayas/new_app.git
   cd new_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app in debug mode:
   ```bash
   flutter run
   ```

4. Build release APK:
   ```bash
   flutter build apk --release
   ```

### GitHub Actions Build

The app is automatically built using GitHub Actions when:
- Code is pushed to the main branch
- A pull request is created to the main branch
- The workflow is manually triggered

### Setting up GitHub Secrets
1. Run `setup_github_secrets.bat`
2. Follow the instructions to add the required secrets to your GitHub repository:
   - ANDROID_KEYSTORE_BASE64
   - ANDROID_KEYSTORE_PASSWORD
   - ANDROID_KEY_ALIAS
   - ANDROID_KEY_PASSWORD
   - ANDROID_HOME

### Build Artifacts
After a successful build, the APK will be available as a build artifact in the GitHub Actions run.

## Development

### Project Structure
- `lib/` - Flutter source code
- `android/` - Android-specific configurations
- `.github/workflows/` - GitHub Actions workflows

### Dependencies
See `pubspec.yaml` for a complete list of dependencies.

## Testing

### Manual Testing Checklist

1. Installation
   - [ ] App installs successfully
   - [ ] App launches without crashes

2. Authentication
   - [ ] Login works for both admin and technician roles
   - [ ] Logout functions correctly
   - [ ] Session persistence works

3. Report Management
   - [ ] Create new report
   - [ ] View report list
   - [ ] Edit existing report
   - [ ] Delete report
   - [ ] Search and filter reports

4. Offline Features
   - [ ] App works without internet
   - [ ] Data syncs when connection is restored
   - [ ] Local storage works correctly

5. Media Features
   - [ ] Camera capture works
   - [ ] Signature capture works
   - [ ] Image preview works

### Automated Testing

Run the test suite:
```bash
flutter test
```

## Troubleshooting

### Common Build Issues
1. **Gradle Build Fails**
   - Clean the project: `flutter clean`
   - Delete build folder: `rm -rf build/`
   - Update dependencies: `flutter pub upgrade`

2. **Signing Issues**
   - Verify keystore configuration
   - Check GitHub secrets are properly set

3. **SDK Issues**
   - Verify Android SDK installation
   - Check ANDROID_HOME environment variable

### Getting Help
If you encounter any issues:
1. Check the GitHub Actions logs
2. Verify all secrets are properly configured
3. Ensure local builds work before pushing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary and confidential. 