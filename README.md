# Insurance Agent Flutter App

A Flutter mobile application designed for insurance agents to onboard a customer they
meet on the field.

## Install dependencies
flutter pub get

## Run the app
flutter run

## Dependencies
- `image_picker` - Camera/gallery image selection
- `image_cropper` - Image editing and cropping
- `shared_preferences` - Local storage
- `intl` - Date formatting and localization
- `camera` - Camera preview in circular modal

## Form Management
- Multi-step: Personal details → Selfie → ID cards → Summary
- Field validation: Required fields, format checks, error messages
- Draft saving: Save form progress locally, incomplete can be editable

## Data Persistence
// Save prospect
await StorageService.saveProspect(prospect);

// Retrieve all prospects
final prospects = await StorageService.getAllProspects();
