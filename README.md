# ADSD Maintenance App

A simplified Flutter application for managing maintenance records with user authentication and basic CRUD operations.

## Features

✅ **User Authentication**
- Login with username/password
- User registration
- Form validation
- Clean, modern UI

✅ **Maintenance Records Management**
- View all maintenance records
- Add new records
- Edit existing records
- Delete records
- Status tracking (Pending, In Progress, Completed)
- Priority levels (Low, Medium, High)

✅ **Modern UI/UX**
- Material Design 3
- Responsive layout
- Loading states
- Error handling
- Confirmation dialogs

## Project Structure

```
lib/
├── main.dart                 # App entry point with login page
├── pages/
│   ├── homepage.dart         # Main dashboard with records list
│   ├── registration_page.dart # User registration form
│   ├── add_record_page.dart  # Add new maintenance record
│   └── edit_record_page.dart # Edit existing record
└── services/
    ├── auth_service.dart     # Authentication logic
    └── data_service.dart     # Data management (CRUD operations)
```

## Getting Started

### Prerequisites
- Flutter SDK (3.19.0 or later)
- Dart SDK
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd maintenance_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## Usage

### Login
- Enter any username and password (demo mode accepts any non-empty credentials)
- Click "Login" to access the main dashboard
- Use "Register" link to create new accounts

### Managing Records
- **View Records**: Main dashboard shows all maintenance records
- **Add Record**: Tap the "+" button to create new records
- **Edit Record**: Tap on any record or use the menu to edit
- **Delete Record**: Use the menu (⋮) to delete records
- **Refresh**: Pull down to refresh or use the refresh button

### Record Fields
- **Equipment Name**: Name/ID of the equipment
- **Location**: Where the equipment is located
- **Issue Description**: Details about the maintenance issue
- **Status**: Pending, In Progress, or Completed
- **Priority**: Low, Medium, or High

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### CI/CD
The project includes GitHub Actions workflow for:
- Code analysis
- Running tests
- Building APK
- Artifact upload

## Architecture

This app follows a simplified architecture pattern:

- **Pages**: UI screens and user interactions
- **Services**: Business logic and data management
- **Models**: Data structures (currently using Map<String, dynamic> for simplicity)

### Key Design Decisions

1. **Simplified Structure**: Removed complex database integrations, offline sync, and advanced features to focus on core functionality
2. **Demo Data**: Uses in-memory data storage for demonstration purposes
3. **Material Design 3**: Modern, clean UI following Google's design guidelines
4. **Form Validation**: Comprehensive input validation and error handling
5. **Responsive Design**: Works on different screen sizes

## Customization

### Adding Real Backend
To connect to a real backend:

1. Update `auth_service.dart` to call your authentication API
2. Update `data_service.dart` to call your CRUD APIs
3. Add proper error handling and network connectivity checks
4. Consider adding offline storage with SQLite

### Styling
- Colors and themes are defined in `main.dart`
- Individual page styling can be customized in respective page files
- Uses Material Design 3 color scheme

### Adding Features
The modular structure makes it easy to add:
- Image attachments
- User roles and permissions
- Advanced filtering and search
- Notifications
- Reports and analytics

## Dependencies

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  path: ^1.8.3
  http: ^1.1.0
  connectivity_plus: ^5.0.2
  image_picker: ^1.0.4
  signature: ^5.4.1
  path_provider: ^2.1.1
  intl: ^0.18.1
  uuid: ^4.2.1
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues:
1. Check the GitHub Issues page
2. Create a new issue with detailed description
3. Include steps to reproduce any bugs

---

**Note**: This is a simplified demonstration app. For production use, implement proper authentication, data persistence, and security measures. 