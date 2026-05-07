# contacts_app

Simple Google Contacts style Flutter app (foundation only).

Tech used:
- Flutter (Material 3)
- GetX (routing + state + DI)
- SQLite (sqflite)

## Getting Started

This project is only a clean starter structure.
CRUD is not implemented yet.

### Run
- `flutter pub get`
- `flutter run`

### Main folders (lib/)
- `core/` : app constants, theme, spacing, utils
- `models/` : data models (example: `Contact`)
- `database/` : sqflite open + schema
- `services/` : service layer (business/use-cases later)
- `controllers/` : GetX controllers (reactive state)
- `routes/` : routes + GetX bindings
- `screens/` : UI screens (Splash, Home, Favorites)
- `widgets/` : reusable UI widgets

### Notes
- Splash loads first, then opens Home.
- Home has a simple bottom navigation (Contacts / Favorites).
- Tap a contact to open the details screen (call, edit, delete, favorite).
- SQLite CRUD is implemented (add/edit/delete/favorite).
