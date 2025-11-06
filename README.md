# Insurance Agent Flutter App

A Flutter mobile application designed for insurance agents to onboard a customer they
meet on the field.

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Dependencies

- `image_picker` - Camera/gallery image selection
- `image_cropper` - Image editing and cropping
- `shared_preferences` - Local key-value storage
- `intl` - Date formatting and localization
- `camera` - Camera preview in circular modal

## Key Features Implementation

### Form Management
- **Multi-step wizard**: Personal details → Selfie → ID cards → Summary
- **Field validation**: Required fields, format checks, error messages
- **Draft saving**: Save form progress locally

### Data Persistence
// Save prospect
await StorageService.saveProspect(prospect);

// Retrieve all prospects
final prospects = await StorageService.getAllProspects();
```