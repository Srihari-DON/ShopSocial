# ShopSocial App Setup

Follow these steps to run the ShopSocial demo on your system:

## Prerequisites

1. **Install Flutter**:
   - Download the Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Extract the zip file to a location on your computer (e.g., `C:\flutter`)
   - Add Flutter's `bin` folder to your PATH environment variable
   - Run `flutter doctor` to verify the installation

2. **Install Android Studio or Visual Studio**:
   - Download from [developer.android.com/studio](https://developer.android.com/studio)
   - Set up an Android emulator or connect a physical device

## Running the ShopSocial Demo

1. **Clone the repository**:
   ```
   git clone https://github.com/Srihari-DON/ShopSocial.git
   cd ShopSocial
   ```

2. **Install dependencies**:
   ```
   flutter pub get
   ```

3. **Run the app**:
   ```
   flutter run
   ```

## Troubleshooting

- If you get a "Flutter command not found" error, make sure Flutter is properly added to your PATH
- If the app fails to build, try running `flutter clean` and then `flutter pub get` again
- For device connection issues, run `flutter doctor` and follow its recommendations

## App Features

- User authentication (login/register)
- Social shopping groups
- Event planning and calendar
- Expense tracking
- In-app messaging
