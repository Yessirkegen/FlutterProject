# Travel Manager App

A comprehensive Flutter application for managing your travel plans, tracking expenses, and keeping all your travel memories in one place.

## Features

- **Trip Planning**: Create and organize your trips with detailed information
- **Offline Mode**: Access your trips even without internet connection
- **Multi-language Support**: Available in English, Russian, and Kazakh
- **Theme Customization**: Choose between light and dark themes
- **Authentication**: Secure login and registration with Firebase
- **Trip History**: View and filter your past trips
- **Cloud Sync**: Synchronize your data across devices

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (version 2.17.0 or higher)
- Firebase account for backend services

### Installation

1. Clone the repository
```
git clone https://github.com/yourusername/travel_manager.git
```

2. Navigate to the project directory
```
cd travel_manager
```

3. Install dependencies
```
flutter pub get
```

4. Configure Firebase
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the configuration files
   - Enable Authentication and Firestore in the Firebase console

5. Run the app
```
flutter run
```

## Architecture

The app follows a clean architecture approach with:

- **Presentation Layer**: UI components and state management
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Repositories and data sources

## Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **Firebase**: Authentication and cloud storage
- **Hive**: Local database for offline support
- **Connectivity Plus**: Network connectivity detection

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Icons by Material Design
- Special thanks to all contributors
