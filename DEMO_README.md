# ShopSocial Demo App

This is a simplified demonstration version of the ShopSocial app showing core functionality.

## Features Implemented

- **Authentication**: Login and registration with mock authentication
- **Home Screen**: View groups and events in a tabbed interface
- **Group Details**: View group information, events, expenses, and members
- **Event Details**: View event information and attendance
- **Chat**: Group chat functionality with message sending
- **Create Menu**: UI for creating new groups, events, and expenses

## How to Run

1. Make sure Flutter is installed on your machine
2. Run `flutter pub get` to install dependencies
3. Start an emulator or connect a physical device
4. Run `flutter run` to launch the app

## Demo Credentials

You can use any of these mock users to log in:

- **Email**: john.doe@example.com
- **Email**: jane.smith@example.com
- **Email**: alex.johnson@example.com

(Any password will work in this demo)

## Project Structure

- `lib/demo/`: Contains all the demo app code
  - `app.dart`: Main app configuration with routing
  - `auth_service.dart`: Mock authentication service
  - `data_service.dart`: Data repository for fetching mock data
  - `widgets.dart`: Reusable UI components
  - Various screen implementations

## Notes

This is a simplified version of the full app, focusing on the core user experience and functionality. The following features are mocked:
- Authentication (no actual backend)
- Data persistence (all data is loaded from JSON files)
- Creating new groups/events/expenses (UI only)

The full implementation would connect to a real backend service and implement complete CRUD operations.
