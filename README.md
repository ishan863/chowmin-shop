# ChowMin Shop - Food Delivery App

A modern Flutter food delivery application with admin panel and customer features.

## Features

### Customer Features
- Phone number authentication
- Browse menu with categories
- Add items to cart
- Place orders with multiple payment options
- Track order status
- Order history
- Profile management
- Light/Dark theme toggle

### Admin Features
- Admin dashboard
- Menu management (add/edit/delete items)
- Order management
- Analytics and reports
- Offers management

## Tech Stack
- **Frontend**: Flutter
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
- **State Management**: Provider
- **Navigation**: GetX
- **Payments**: Razorpay

## Setup Instructions

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase account

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd chowmin_shop
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Enable Authentication (Phone sign-in)
- Create Firestore Database
- Enable Cloud Storage
- Download `google-services.json` for Android
- Replace the placeholder config in `lib/firebase_options.dart`

4. Run the app
```bash
flutter run
```

## Admin Access
To access admin features, login with these phone numbers:
- `9999999999`
- `1234567890`
- `9876543210`

## Project Structure
```
lib/
├── config/          # App configuration
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
├── utils/           # Utilities
└── widgets/         # Reusable widgets
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License
This project is licensed under the MIT License.