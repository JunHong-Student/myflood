# MyFlood Malaysia

MyFlood Malaysia is a Flutter mobile application developed to provide real-time and historical flood monitoring and analytics for Malaysia. Designed as an academic prototype, the application supports SDG 9 (Industry, Innovation and Infrastructure) by leveraging existing government data to present public flood tracking and climate patterns in an accessible, mobile-friendly interface.

## Main Features

- **Live Flood Information**: Real-time tracking of active flood threats and current river warnings across Malaysian states.
- **Malaysia Flood Map**: Interactive geographical visualization of current flood risk stations, focused specifically on Malaysia.
- **Historical Flood Analytics**: Visualized tracking of past flood events by state (2000-2010).
- **Seasonal Flood Patterns**: Insights into monthly flood and flash-flood seasonality and average rainfall.
- **Cloud-Backed Data**: Processed historical and seasonal flood statistics are stored in Firebase Cloud Firestore and accessed as read-only data by the application.

## Data Sources

The application leverages distinct datasets for live and historical features:
- **Live Active Threats**: Retrieved directly from the existing live Malaysian government flood API.
- **Historical Statistics**: Extracted from government/JPS dataset archives for comprehensive historical state tracking.
- **Seasonal Analysis**: Derived from the Kaggle Malaysia flood dataset.

*Note: Raw analytical datasets are processed completely offline. The application queries securely aggregated, read-only statistical documents directly from Firestore.*

## Technology Stack

- **Flutter / Dart**: Frontend application framework.
- **Firebase & Cloud Firestore**: Backend configuration and NoSQL database for historical analytics.
- **Provider**: State management.
- **flutter_map & latlong2**: Interactive mapping.
- **fl_chart**: Data visualization and charts.

## Firebase Configuration

The Firebase project (`myflood-malaysia`) is fully configured and linked to this repository via `firebase_options.dart`. 
The application reads from two Firestore collections that are configured for public read-only access:
- `reko_historical_stats`
- `kaggle_monthly_stats`

*(For security and data integrity, Firestore security rules strictly deny all write access, while read access is permitted exclusively for these analytics collections).*

## Getting Started

To clone and run the project locally, ensure you have the Flutter SDK installed and an Android emulator/device configured.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/JunHong-Student/myflood.git
   cd myflood
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify the environment:**
   ```bash
   flutter doctor
   ```

4. **Run the application:**
   ```bash
   flutter run
   ```

5. **Build a debug APK:**
   ```bash
   flutter build apk --debug
   ```

## Project Structure

The codebase is organized cleanly to separate core logic from the UI layer:

```
lib/
├── core/
│   ├── models/        # Data models (e.g., FloodData)
│   ├── providers/     # State management (e.g., FloodDataProvider, FavoritesProvider)
│   ├── services/      # API integration (e.g., FloodApiService)
│   ├── theme/         # App colors, typography, and styling constants
│   └── widgets/       # Reusable components (e.g., AppShell, StatusBadge)
├── screens/
│   ├── auth/          # Authentication layouts
│   ├── home/          # Main application tabs (Dashboard, Map, Analytics, Records, Favorites)
│   └── splash/        # Application boot screen
├── firebase_options.dart  # Firebase initialization configurations
└── main.dart              # Application entry point
```

## Development Notes

- **Data Integrity**: Raw CSV datasets, offline aggregation scripts, and local temporary files are intentionally untracked in Git to keep the repository clean.
- **Security**: The application relies on read-only endpoints and zero hardcoded credentials or API secrets. Security rules are handled natively on the Firebase servers.

## Status

**Prototype / Assignment Project**
This repository reflects a completed working prototype designed for academic evaluation. It accurately implements the outlined features but is not intended for commercial release.
