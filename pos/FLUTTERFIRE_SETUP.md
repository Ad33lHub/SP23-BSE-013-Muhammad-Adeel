# FlutterFire CLI Setup Instructions

## Important: Complete Firebase Configuration

The `firebase_options.dart` file has been created with your project ID (`smart-pos-7c76c`), but you need to run FlutterFire CLI to populate it with the actual API keys and configuration.

## Steps to Complete Setup

### 1. Make sure FlutterFire CLI is in your PATH

Add the Pub cache bin directory to your PATH:

**Windows PowerShell (temporary - current session):**
```powershell
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

**Windows PowerShell (permanent):**
```powershell
[System.Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";$env:LOCALAPPDATA\Pub\Cache\bin", "User")
```

### 2. Run FlutterFire Configure

```bash
flutterfire configure
```

This will:
- ✅ Connect to your Firebase project `smart-pos-7c76c`
- ✅ Generate platform-specific configuration
- ✅ Update `firebase_options.dart` with actual API keys
- ✅ Create/update `google-services.json` for Android
- ✅ Create/update `GoogleService-Info.plist` for iOS (if configured)

### 3. Select Platforms

When prompted, select the platforms you want to support:
- ✅ **android** (required)
- iOS (optional)
- web (optional)
- macos (optional)

### 4. Verify Configuration

After running `flutterfire configure`, check that:
- `lib/firebase_options.dart` contains actual API keys (not "YOUR_*_API_KEY")
- `android/app/google-services.json` exists
- All values are properly populated

### 5. Run the App

```bash
flutter pub get
flutter run
```

## Alternative: Manual Configuration

If FlutterFire CLI doesn't work, you can manually configure Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project `smart-pos-7c76c`
3. Add an Android app:
   - Package name: `com.example.pos`
   - Download `google-services.json`
   - Place in `android/app/`
4. Get the configuration values and update `firebase_options.dart` manually

## Troubleshooting

**Issue: Command 'flutterfire' not found**
- Solution: Add Pub cache to PATH (see step 1 above)

**Issue: No Firebase projects found**
- Solution: Make sure you're logged in to Firebase CLI
- Run: `firebase login`

**Issue: Project not listed**
- Solution: Specify project explicitly
- Run: `flutterfire configure --project=smart-pos-7c76c`

## Next Steps After Configuration

1. Enable Authentication in Firebase Console
2. Enable Firestore Database
3. Test the app with sign-up and login
