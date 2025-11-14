# Firebase Integration TODO

## Status: ⚠️ CONFIGURATION REQUIRED

The HealPray app has been prepared for Firebase integration with the `flowsense-cycle-app` project, but requires manual configuration file downloads from the Firebase Console.

---

## ✅ Completed Steps

1. ✅ Updated README with comprehensive documentation and ZyraFlow branding
2. ✅ Updated Privacy Policy screen with ZyraFlow Inc. copyright
3. ✅ Updated About screen with ZyraFlow Inc. branding
4. ✅ Created Firebase Integration Guide (`FIREBASE_INTEGRATION.md`)
5. ✅ Created Firebase verification script (`scripts/verify_firebase.sh`)
6. ✅ Bundle ID standardized to `com.healpray.healpray`
7. ✅ App code prepared for Firebase initialization

---

## 🔴 REQUIRED: Manual Steps

### Step 1: Download Firebase Configuration Files

You **MUST** manually download the Firebase configuration files from the Firebase Console:

#### For Android:
1. Visit: https://console.firebase.google.com/project/flowsense-cycle-app/settings/general
2. Scroll to "Your apps" section
3. **Option A**: If HealPray Android app exists:
   - Click the Android app
   - Download `google-services.json`
4. **Option B**: If HealPray Android app does NOT exist:
   - Click "Add app" → Android
   - Package name: `com.healpray.healpray`
   - App nickname: `HealPray` (optional)
   - Download `google-services.json`
5. Save the file to: `android/app/google-services.json`

#### For iOS:
1. Visit: https://console.firebase.google.com/project/flowsense-cycle-app/settings/general
2. Scroll to "Your apps" section
3. **Option A**: If HealPray iOS app exists:
   - Click the iOS app
   - Download `GoogleService-Info.plist`
4. **Option B**: If HealPray iOS app does NOT exist:
   - Click "Add app" → iOS
   - Bundle ID: `com.healpray.healpray`
   - App nickname: `HealPray` (optional)
   - Download `GoogleService-Info.plist`
5. Save the file to: `ios/Runner/GoogleService-Info.plist`

---

### Step 2: Verify Configuration

After downloading both files, run the verification script:

```bash
./scripts/verify_firebase.sh
```

This will check:
- ✓ Files are in the correct locations
- ✓ Package name/Bundle ID matches `com.healpray.healpray`
- ✓ Firebase project ID is `flowsense-cycle-app`

---

### Step 3: Enable Firebase in Code

Once configuration files are in place, enable Firebase initialization in `lib/main.dart`:

**Current code (lines 50-66):**
```dart
// Initialize Firebase (disabled for development)
try {
  AppLogger.info('⚠️ Firebase initialization skipped in development mode');
  // Firebase will be enabled when:
  // 1. Firebase project is properly configured with API keys in .env
  // 2. google-services.json (Android) and GoogleService-Info.plist (iOS) are added
  // 3. DefaultFirebaseOptions.currentPlatform is generated via flutterfire configure
  // Uncomment below when ready:
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseService.initialize();
} catch (firebaseError) {
  AppLogger.warning(
      'Firebase initialization failed, running in offline mode: $firebaseError');
  // Continue without Firebase - the app should work in offline mode
}
```

**You'll need to:**

1. **Install FlutterFire CLI** (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure FlutterFire** to generate `firebase_options.dart`:
   ```bash
   flutterfire configure --project=flowsense-cycle-app
   ```
   
   Select:
   - ✓ Android
   - ✓ iOS
   - Package name: `com.healpray.healpray`
   - Bundle ID: `com.healpray.healpray`

3. **Update imports in `lib/main.dart`**: Add these lines near the top:
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   import 'firebase_options.dart';
   import 'shared/services/firebase_service.dart';
   ```

4. **Uncomment Firebase initialization** (lines 58-61):
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   await FirebaseService.initialize();
   ```

5. **Update log message** (line 52):
   ```dart
   AppLogger.info('🔥 Initializing Firebase...');
   ```

---

### Step 4: Build and Test

After enabling Firebase, clean and rebuild:

```bash
# Clean
flutter clean
flutter pub get

# iOS pods
cd ios && pod install && cd ..

# Run app
flutter run
```

**Expected console output:**
```
🚀 Initializing HealPray app...
✅ Hive initialized
✅ App configuration loaded
✅ AdMob initialized
🔥 Initializing Firebase...
✅ Firebase initialized
✅ Advanced analytics service initialized
✅ A/B test service initialized
✅ User feedback service initialized
🎉 App initialization complete
```

---

### Step 5: Enable Firebase Services

In the Firebase Console, ensure these services are enabled:

#### Authentication
- ✓ Email/Password
- ✓ Google Sign-In
- ✓ Apple Sign-In (iOS)
- ✓ Anonymous

#### Firestore Database
- Create database (if not exists)
- Set security rules (see `FIREBASE_INTEGRATION.md`)

#### Cloud Messaging
- Enable for push notifications

#### Analytics
- Should auto-enable with app

---

## 📝 Notes

- **Security**: Firebase config files contain sensitive keys. For production apps, consider using environment-specific configurations and secrets management.
- **Offline Mode**: The app is designed to work without Firebase using Hive for local storage. Firebase adds cloud sync and authentication.
- **Testing**: Test authentication flows, Firestore operations, and analytics tracking after enabling Firebase.

---

## 🚨 Important Warnings

1. **Do NOT commit Firebase config files to public repositories** - They contain API keys
2. **Verify security rules** in Firestore before production release
3. **Test on both platforms** (Android & iOS) after Firebase integration
4. **Monitor Firebase quotas** - Free tier has limits on reads/writes

---

## 📞 Support

If you encounter issues:
- Review `FIREBASE_INTEGRATION.md` for detailed troubleshooting
- Check Firebase Console for error logs
- Contact: ronos.icloud@gmail.com

---

## ✅ Checklist

- [ ] Downloaded `google-services.json` from Firebase Console
- [ ] Placed `google-services.json` in `android/app/`
- [ ] Downloaded `GoogleService-Info.plist` from Firebase Console
- [ ] Placed `GoogleService-Info.plist` in `ios/Runner/`
- [ ] Ran `./scripts/verify_firebase.sh` successfully
- [ ] Installed FlutterFire CLI
- [ ] Ran `flutterfire configure --project=flowsense-cycle-app`
- [ ] Updated `lib/main.dart` imports
- [ ] Uncommented Firebase initialization code
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Ran `cd ios && pod install && cd ..`
- [ ] Built and tested on Android
- [ ] Built and tested on iOS
- [ ] Verified authentication works
- [ ] Verified Firestore operations work
- [ ] Enabled Firebase services in Console
- [ ] Set Firestore security rules

---

**Developed and Maintained by ZyraFlow Inc.™**  
© 2025 ZyraFlow Inc. All rights reserved.
