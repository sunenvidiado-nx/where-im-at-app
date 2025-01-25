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

3. Set up API Keys
- Create a free account at [https://stadiamaps.com](https://stadiamaps.com/) and generate an API key
- Get a Geocoding API key from [https://geocode.maps.co](https://geocode.maps.co/)

4. Create and configure `.env` file
```bash
cp .env.example .env
```
Open the generated `.env` file and replace the placeholder values:
```
STADIA_MAPS_API_KEY=your_stadia_maps_api_key_here
GEOCODING_API_KEY=your_maps_co_api_key_here
```
Make sure to:
- Replace `your_stadia_maps_api_key_here` with your actual Stadia Maps API key
- Replace `your_maps_co_api_key_here` with your actual Geocoding API key

5. Run code generation
```bash
# Generate code for build runner
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n
```

6. Set up Firebase
```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure Firebase (follow the interactive prompts)
flutterfire configure
```

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
