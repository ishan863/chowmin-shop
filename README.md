# ChowMin Shop - Food Delivery App

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

🍜 Complete Flutter Food Delivery App with Admin Panel | Firebase | Razorpay

A modern Flutter food delivery application with comprehensive admin panel and customer features.

## 🚀 Features

### 👥 Customer Features
- 📱 Phone number authentication
- 🍽️ Browse menu with categories  
- 🛒 Add items to cart with animations
- 💳 Multiple payment options (UPI, Razorpay, COD)
- 📍 Track order status in real-time
- 📋 Order history and favorites
- 👤 Profile management
- 🌓 Light/Dark theme toggle
- 🎉 Beautiful animations and confetti effects

### 👨‍💼 Admin Features
- 📊 Comprehensive admin dashboard
- 🍕 Menu management (add/edit/delete items)
- 📦 Order management and tracking
- 💰 Revenue analytics and reports
- 🎯 Offers and promotions management
- 📈 Real-time business insights

## 🛠️ Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase
  - Authentication (Phone number)
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging
- **State Management**: Provider
- **Navigation**: GetX
- **Payments**: Razorpay Integration
- **Animations**: Custom Flutter animations
- **UI**: Material Design 3

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio / VS Code
- Firebase account
- Razorpay account (for payments)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/ishan863/chowmin-shop.git
cd chowmin-shop
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a new Firebase project
   - Enable Authentication (Phone sign-in)
   - Create Firestore Database (Test mode initially)
   - Enable Cloud Storage
   - Download `google-services.json` for Android
   - Replace the config in `lib/firebase_options.dart` with your project details

4. **Configure Razorpay** (Optional)
   - Get Razorpay API keys
   - Update payment configuration

5. **Run the app**
```bash
flutter run
```

## 🔐 Admin Access

To access admin features, login with these phone numbers:
- `9999999999`
- `1234567890` 
- `9876543210`

## 📁 Project Structure

```
lib/
├── config/          # App configuration & routes
├── models/          # Data models
├── providers/       # State management (Provider)
├── screens/         # UI screens
│   ├── admin/       # Admin panel screens
│   ├── auth/        # Authentication screens
│   └── customer/    # Customer app screens
├── services/        # Business logic & API calls
├── utils/           # Utilities & helpers
├── widgets/         # Reusable UI components
├── firebase_options.dart # Firebase configuration
└── main.dart        # App entry point
```

## 🎯 Key Features Implemented

- ✅ **62 Files** with **11,876+ lines** of clean code
- ✅ **Firebase Integration** (Auth, Firestore, Storage, FCM)
- ✅ **Razorpay Payment Gateway** integration
- ✅ **Real-time Order Tracking** with status updates
- ✅ **Admin Dashboard** with analytics
- ✅ **Cart Management** with animations
- ✅ **Theme System** (Light/Dark mode)
- ✅ **Notification System** (Local + Push)
- ✅ **Address Management** for delivery
- ✅ **Coupon System** for discounts
- ✅ **Multi-language Support** ready
- ✅ **Responsive Design** for all screen sizes

## 🔧 Configuration

### Firebase Setup
1. Create Firebase project
2. Enable Phone Authentication
3. Set up Firestore with these collections:
   - `users` - Customer data
   - `admins` - Admin accounts  
   - `menu_items` - Food items
   - `orders` - Order management
   - `offers` - Promotions

### Payment Setup
Update payment methods in checkout screen with your:
- UPI ID
- Razorpay credentials
- Other payment gateways

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Razorpay for payment integration
- Material Design for UI guidelines

## 📞 Contact

**Goura Hari Patel** - [@ishan863](https://github.com/ishan863)

Project Link: [https://github.com/ishan863/chowmin-shop](https://github.com/ishan863/chowmin-shop)

---

⭐ **Star this repository if you find it helpful!** ⭐
