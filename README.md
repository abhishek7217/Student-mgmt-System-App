# Student Management System

A Flutter application for managing student admissions, records, fee payments, and user profiles from a single mobile-friendly interface.

## Overview

The application provides a local student administration workflow. Users can create an account, sign in with an email address or mobile number, manage their profile, register students, track fee balances, and attach fee receipts.

## Features

- User registration with validation for personal and account details
- Login using email or mobile number
- Profile management for all registration fields
- Email protection during profile updates
- Profile image selection from the camera or device gallery
- Student admission and record management
- Course-based fee calculation
- Submitted and remaining fee tracking
- Fee receipt upload from the camera or device gallery
- Student record editing and deletion
- Dashboard statistics for students and pending fees
- Responsive, scrollable forms for phone, tablet, and desktop layouts
- Local session persistence and automatic login state restoration

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State management:** Provider
- **Local preferences:** SharedPreferences
- **Local database:** SQLite through sqflite
- **Media selection:** image_picker
- **Supported targets:** Android, iOS, Web, Linux, macOS, and Windows (subject to platform-specific Flutter support)

## Project Structure

```text
lib/
|-- models/       Data models
|-- providers/    Application state and persistence coordination
|-- routes/       Named route configuration
|-- screens/      Login, registration, dashboard, admission, and profile views
|-- services/     SQLite database access
`-- utils/        Shared validation logic

assets/images/    Application image assets
test/              Flutter widget tests
```

## Prerequisites

Install the following before running the project:

- Flutter SDK compatible with Dart SDK `3.12.2` or later
- Android Studio and an Android emulator or connected device for Android development
- Xcode for iOS and macOS development
- A desktop toolchain for Windows, Linux, or macOS desktop builds

Verify the Flutter installation with:

```bash
flutter doctor
```

## Getting Started

Clone the repository and install dependencies:

```bash
git clone https://github.com/abhishek7217/Student-mgmt-System-App.git
cd Student-mgmt-System-App
flutter pub get
```

List available devices and run the application:

```bash
flutter devices
flutter run
```

To run on a specific device:

```bash
flutter run -d <device-id>
```

## Quality Checks

Run the analyzer and test suite before opening a pull request:

```bash
flutter analyze
flutter test
```

The repository includes a smoke test that verifies the application starts on its splash screen.

## Data and Privacy

This project currently uses local storage only:

- User account details are stored with SharedPreferences.
- Student admission records are stored in a local SQLite database.
- Image and receipt paths refer to files selected on the device.
- There is no remote backend, cloud synchronization, or server-side authentication.

For production use, credentials should be replaced with a secure authentication service and sensitive data should not be stored as plain local preferences.

## Development Notes

- Database schema changes must increment the database version and add an upgrade migration in `DatabaseHelper`.
- New screens should be registered in `lib/routes/routes.dart` when named navigation is required.
- Forms should remain scrollable and avoid fixed vertical positioning to support different screen sizes and keyboard states.

## License

This repository is currently intended for private and educational use. Add a project-specific license before distributing it publicly.
