Branding assets live in this folder.

Add these files (PNG, recommended 1024x1024 for icons):
- `app_icon.png` (main launcher icon)
- `app_icon_foreground.png` (Android adaptive icon foreground)
- `splash_logo.png` (native splash logo - light)
- `splash_logo_dark.png` (native splash logo - dark)

After adding them, run:
- `flutter pub get`
- `dart run flutter_launcher_icons`
- `dart run flutter_native_splash:create`

Recommended splash logo size:
- 512x512 PNG (transparent background)
- Keep plenty of padding around the mark (it will be centered).
