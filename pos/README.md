# Smart POS & Inventory Management System

A modern Point of Sale (POS) and Full Inventory Management application built with Flutter and Firebase backend. Features glassmorphic UI design with dark blue iPhone-style aesthetics, online/offline mode support, and comprehensive inventory management capabilities.

## 📱 Features

### Current Features
- ✅ Modern glassmorphic UI with dark blue gradient backgrounds
- ✅ User authentication (Login/Signup)
- ✅ Firebase Authentication
- ✅ Cloud Firestore database
- ✅ Real-time auth state management
- ✅ Form validation
- ✅ Smooth animations and transitions
- ✅ Responsive design

### Upcoming Features
- 🔄 Offline mode with SQLite
- 🔄 Online/Offline sync
- 🔄 Product management
- 🔄 Inventory tracking
- 🔄 Sales & POS system
- 🔄 Customer management
- 🔄 Reports and analytics
- 🔄 Cloud backup & restore

## 🛠️ Technology Stack

### Frontend
- **Flutter** 3.38.4
- **State Management**: Provider
- **Local Storage**: SharedPreferences, SQLite
- **UI Components**: Custom glassmorphic widgets

### Backend
- **Firebase Authentication** - Email/Password authentication
- **Cloud Firestore** - NoSQL cloud database
- **Firebase Core** - Firebase SDK integration

## 📋 Prerequisites

- Flutter SDK 3.38.4 or higher
- Dart SDK 3.10.3 or higher
- Firebase account (free tier available)
- Android Studio / VS Code
- Git

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd pos
```

### 2. Firebase Setup

**Important:** You need to set up Firebase before the app will work. Follow the detailed instructions in `FIREBASE_SETUP.md`.

Quick summary:
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Authentication (Email/Password method)
3. Create a Firestore database
4. Download and add configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/` (for iOS)

### 3. Flutter Setup

#### Step 1: Install Dependencies
```bash
flutter pub get
```

#### Step 2: Run the App
```bash
# For development
flutter run

# For release APK
flutter build apk --release
```

## 📁 Project Structure

```
pos/
├── lib/                        # Flutter App
│   ├── config/
│   │   └── theme.dart         # App theme & colors
│   ├── models/                # Data models
│   ├── screens/
│   │   ├── splash_screen.dart # Splash screen
│   │   ├── login_screen.dart  # Login screen
│   │   └── signup_screen.dart # Signup screen
│   ├── services/
│   │   └── auth_service.dart  # Firebase auth service
│   ├── widgets/
│   │   ├── glassmorphic_container.dart
│   │   ├── custom_text_field.dart
│   │   └── gradient_button.dart
│   └── main.dart              # App entry point
│
├── FIREBASE_SETUP.md          # Firebase setup guide
└── README.md
```

## 🎨 Design

The app features a modern glassmorphic design inspired by iPhone aesthetics:
- **Dark blue gradient backgrounds** (similar to iOS)
- **Frosted glass effects** with backdrop blur
- **Smooth animations** and transitions
- **Premium UI components** with gradient buttons
- **Consistent color scheme** throughout the app

### Color Palette
- Primary Dark Blue: #0A1128
- Secondary Dark Blue: #1C2951
- Accent Blue: #3E5C9A
- Light Blue: #6B8DD6

## 🔌 Firebase Services

### Authentication
- Email/Password authentication
- Real-time auth state changes
- Secure token management (handled by Firebase SDK)

### Firestore Database
- Users collection with user profiles
- Real-time data synchronization
- Offline persistence support

## 📱 Screenshots

_Screenshots will be added here_

## 🧪 Testing

### Testing Authentication
1. Run the app
2. Create a new account using the signup screen
3. Verify user appears in Firebase Console → Authentication
4. Log in with created credentials
5. Test logout functionality
6. Verify session persistence (close/reopen app)

## 👥 Team

- **Developer**: [Your Name]
- **Course**: Mobile Application Development
- **Institution**: [Your Institution]

## 📝 License

This project is created for educational purposes as part of a lab assignment.

## 🚨 Important Notes

- **Firebase configuration is required** - Follow `FIREBASE_SETUP.md` before running the app
- Add `google-services.json` to `android/app/` for Android builds
- Firebase handles authentication tokens automatically
- User data is stored in Firestore, not locally
- Firestore security rules should be configured for production use

## 📞 Support

For issues or questions, contact [Your Email]

---

**Version**: 1.0.0 (Commit 1)  
**Last Updated**: January 2026
