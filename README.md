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
- Android Studio / VS Code
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
- A pull request is created
- Manually triggered from the Actions tab

To download the latest build:
1. Go to the [Actions](https://github.com/AneesLayas/new_app/actions) tab
2. Select the latest successful workflow run
3. Download the APK from the artifacts section

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

1. Build Issues
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. Sync Issues
   - Check internet connection
   - Verify API server is running
   - Clear app data and cache

3. Installation Issues
   - Enable "Install from Unknown Sources"
   - Check device compatibility
   - Verify APK signature

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is proprietary and confidential. 