# Contacts App

A modern Google Contacts style app built with Flutter. The app supports offline contact management using SQLite and uses GetX for routing, dependency injection, and reactive state management.

## Features

- View all contacts
- Add new contacts
- Edit existing contacts
- Delete contacts with confirmation
- View contact profile/details
- Mark and unmark favorite contacts
- Separate Favorites tab
- Search contacts by name, phone, and email
- Call a contact directly from the app
- Responsive UI for different screen sizes
- Material 3 based light and dark theme support
- App launcher icon and native splash setup

## Tech Stack

- Flutter
- Dart
- GetX
- SQLite using sqflite
- Material 3
- url_launcher
- image_picker
- google_fonts

## Project Structure

```text
lib/
  core/          App constants, theme, spacing, utilities
  controllers/   GetX controllers and reactive state
  database/      SQLite database setup, schema, and DAO
  features/      Feature based UI modules
  models/        Data models
  routes/        App routes and GetX bindings
  screens/       Screen entry files and compatibility exports
  services/      Business logic and service layer
  widgets/       Shared reusable UI widgets
```

## Architecture

The app follows a clean layered flow:

```text
UI -> Controller -> Service -> Database
```

- UI files only handle presentation and user interaction.
- Controllers manage reactive state and call services.
- Services contain app logic and database operations.
- Database files handle SQLite queries and mapping.

This structure keeps the app easier to maintain and ready for future features like advanced filtering, sorting, contact import/export, and cloud sync.

## How To Run

1. Install Flutter.
2. Clone the project.
3. Install packages:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

## Build APK

To generate a debug APK:

```bash
flutter build apk --debug
```

To generate a release APK:

```bash
flutter build apk --release
```

The APK will be available inside:

```text
build/app/outputs/flutter-apk/
```

## Notes

- The app uses SQLite, so contacts are stored offline on the device.
- Calling depends on the device having a working dialer app.
- Some emulators may not support phone calling properly.
- For best testing, use a real Android device.



## Deliverables Checklist

- Source code on GitHub
- README documentation
- APK file from `build/app/outputs/flutter-apk/`
- Screenshots or a short video demo showing contacts, favorites, add/edit/delete, contact details, and calling

