# ShopSocial

A social shopping app with features for groups, events, chats, and expense sharing.

## Features

- User authentication
- Group management
- Event planning and calendar
- Real-time chat
- Expense tracking and splitting

## Tech Stack

- Flutter 3.7+
- Riverpod for state management
- GoRouter for navigation
- Material 3 theming
- Clean architecture

## Getting Started

For detailed setup instructions, see [SETUP.md](SETUP.md).

### Prerequisites

- Flutter SDK 3.7 or higher
- Dart 3.0 or higher

### Installation

1. Clone the repository
```
git clone https://github.com/Srihari-DON/ShopSocial.git
```

2. Navigate to the project directory
```
cd shop_social
```

3. Install dependencies
```
flutter pub get
```

4. Run the app
```
flutter run
```

## Demo Credentials

For testing the app, you can use the following credentials:
- Email: user@example.com
- Password: password

## Structure

The app follows a clean architecture approach with the following layers:

- **Models**: Data classes that define the structure of the app's data
- **Services**: Interfaces and mock implementations for backend functionality
- **Repositories**: Connects view models to services
- **ViewModels**: State management and business logic using Riverpod
- **Screens**: UI for different sections of the app
- **Widgets**: Reusable UI components

## Mock Data

The app uses mock data stored in JSON files for demonstration purposes. In a production environment, this would be replaced with real API calls.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Future Improvements

- Add real backend integration
- Implement offline-first functionality with local database
- Add unit and widget tests
- Support for push notifications
- Add analytics and crash reporting
