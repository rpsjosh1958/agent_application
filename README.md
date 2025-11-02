# 📱 Insurance Agent Flutter App

A comprehensive Flutter mobile application designed for insurance agents to efficiently collect, manage, and track prospect information.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)

## ✨ Features

- 📝 **Multi-step Form**: Comprehensive prospect data collection
- 📸 **Image Capture**: Selfie, ID cards (front/back) with camera/gallery support
- 🌍 **Ghana-Specific Fields**: GhanaPost GPS, local nationality options
- 🔍 **Search & Filter**: Quick prospect lookup with date categorization
- 💾 **Offline Storage**: Local data persistence using SharedPreferences
- 🎨 **Clean UI**: iOS-style Cupertino design with collapsible sections
- ✅ **Form Validation**: Real-time feedback with visual error indicators
- 📱 **Responsive**: Works on all screen sizes

## 🎥 Screenshots

*[Add screenshots here when deploying]*

## 🏗️ Architecture

```
lib/
├── models/          # Data models with JSON serialization
├── screens/         # UI screens (Home, Form, Details)
├── services/        # Business logic & storage
├── widgets/         # Reusable custom widgets
├── constants/       # App-wide colors & text styles
└── utils/           # Helper functions
```

## �� Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- iOS Simulator / Android Emulator

### Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/insurance-agent-flutter-app.git

# Navigate to project directory
cd insurance-agent-flutter-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📦 Dependencies

- `image_picker` - Camera/gallery image selection
- `image_cropper` - Image editing and cropping
- `shared_preferences` - Local key-value storage
- `country_calling_code_kit` - International phone codes
- `intl` - Date formatting and localization

## 🛠️ Key Features Implementation

### Form Management
- **Multi-step wizard**: Personal details → Selfie → ID cards → Summary
- **Field validation**: Required fields, format checks, error messages
- **Draft saving**: Auto-save form progress locally

### Data Persistence
```dart
// Save prospect
await StorageService.saveProspect(prospect);

// Retrieve all prospects
final prospects = await StorageService.getAllProspects();
```

### Image Handling
- Camera capture with compression
- Gallery selection
- Circular crop for selfies
- File path storage

## 🎯 Use Cases

1. **Insurance Agents**: Collect prospect data during field visits
2. **Sales Teams**: Manage customer pipeline offline
3. **KYC Collection**: Store identity verification documents
4. **Onboarding**: Multi-step customer registration flows

## 🔮 Future Enhancements

- [ ] Backend API integration
- [ ] Cloud storage for images
- [ ] Export to PDF
- [ ] Analytics dashboard
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Biometric authentication

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

## 📝 Code Quality

- **Clean Architecture**: Separation of concerns
- **Reusable Widgets**: DRY principle
- **Constants**: Centralized styling
- **Documentation**: Inline comments and guides

## 👨‍💻 Developer

**Your Name**
- GitHub: [@yourhandle](https://github.com/yourhandle)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)
- Email: your.email@example.com

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Cupertino design guidelines
- Open source package maintainers

---

**Built with ❤️ using Flutter**
