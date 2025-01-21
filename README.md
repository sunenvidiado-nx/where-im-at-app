# Where I'm At

A Flutter app to share your current location with trusted contacts. Just tap, and let everyone know where you're at! 📍🌍

## Features ✨
- 🌍 Real-time location tracking
- 👥 Location sharing with friends
- 🗺️ Interactive map view
- 🔐 User authentication

## Prerequisites 🛠️
- Flutter v3.27+

## Getting Started 🚀

### Installation 📦
1. Clone the repository
```bash
git clone https://github.com/sunenvidiado-nx/where-im-at-app.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Create .env file
```bash
cp .env.example .env
```

4. Run code generation
```bash
# Generate code for build runner
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n
```

5. Set up Firebase
```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure Firebase (follow the interactive prompts)
flutterfire configure
```

6. Set up Stadia Maps
- Create a free account at [Stadia Maps](https://stadiamaps.com/), generate an API key, and add it to your `.env` file as `STADIA_MAPS_API_KEY`.

### Running the App ▶️
```bash
flutter run
```

## Technologies 🔧
- Flutter & Dart 🦋
- Firebase (Authentication, Firestore, Firebase Storage)
- Stadia Maps
- OpenStreetMap
- OpenMapTiles

## License 📄
Distributed under the BSD 3-Clause License. See [`LICENSE`](LICENSE) for more information.
