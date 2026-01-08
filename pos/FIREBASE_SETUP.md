# Firebase Configuration Required

## Setup Instructions

To complete the Firebase setup, you need to:

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" or select an existing project
   - Follow the setup wizard

2. **Enable Firebase Authentication**
   - In Firebase Console, go to **Authentication**
   - Click "Get Started"
   - Enable "Email/Password" sign-in method

3. **Enable Firestore Database**
   - In Firebase Console, go to **Firestore Database**
   - Click "Create database"
   - Choose "Start in production mode" or "test mode" (for development)
   - Select a location for your database

4. **Register Android App**
   - In Firebase Console, go to Project Settings
   - Click "Add app" and select Android
   - Package name: `com.example.pos`
   - Download the `google-services.json` file
   - **Place it in**: `android/app/google-services.json`

5. **Register iOS App (Optional)**
   - In Firebase Console, go to Project Settings
   - Click "Add app" and select iOS
   - Bundle ID: `com.example.pos`
   - Download the `GoogleService-Info.plist` file
   - **Place it in**: `ios/Runner/GoogleService-Info.plist`

6. **Firestore Security Rules (Optional but Recommended)**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

## After Configuration

Once you've added the configuration files, run:

```bash
flutter pub get
flutter run
```

## Important Notes

- The `google-services.json` file is already in `.gitignore` to protect your Firebase credentials
- Never commit Firebase configuration files to public repositories
- Users from the old PHP/MySQL system will need to create new accounts
