# Firebase Integration Guide

## Overview

HealPray uses Firebase from the `flowsense-cycle-app` project for backend services including Authentication, Firestore, Analytics, and Cloud Messaging.

**Firebase Project URL**: https://console.firebase.google.com/project/flowsense-cycle-app/settings/general

---

## Configuration Steps

### 1. Download Configuration Files

Visit the Firebase Console for the flowsense-cycle-app project and download the configuration files:

#### For Android:
1. Go to: https://console.firebase.google.com/project/flowsense-cycle-app/settings/general
2. Scroll to "Your apps" section
3. Find the Android app or add a new one with:
   - **Package name**: `com.healpray.healpray`
   - **App nickname**: HealPray (optional)
4. Download the `google-services.json` file
5. Place it in: `android/app/google-services.json`

#### For iOS:
1. Go to: https://console.firebase.google.com/project/flowsense-cycle-app/settings/general
2. Scroll to "Your apps" section
3. Find the iOS app or add a new one with:
   - **Bundle ID**: `com.healpray.healpray`
   - **App nickname**: HealPray (optional)
4. Download the `GoogleService-Info.plist` file
5. Place it in: `ios/Runner/GoogleService-Info.plist`

---

### 2. Enable Firebase Services

In the Firebase Console, ensure the following services are enabled:

#### Authentication
- **Email/Password**: Enabled
- **Google Sign-In**: Enabled (configure OAuth consent)
- **Apple Sign-In**: Enabled (for iOS)
- **Anonymous**: Enabled

#### Firestore Database
- **Mode**: Production mode (or test mode for development)
- **Region**: Choose closest to your users
- Create collections:
  - `users` - User profiles and settings
  - `prayers` - User prayers and journal entries
  - `moods` - Mood tracking data
  - `community_prayers` - Shared prayer requests
  - `meditation_sessions` - Meditation history

#### Analytics
- Enable Google Analytics for the project

#### Cloud Messaging (FCM)
- Enable for push notifications
- Upload APNs certificates for iOS (if needed)

---

### 3. Update Environment Variables

Create or update `.env` file in the project root:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=flowsense-cycle-app

# AI Services
GEMINI_API_KEY=your_gemini_api_key_here

# Other Configuration
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
```

---

### 4. Verify Integration

After adding the configuration files, run:

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# iOS specific
cd ios && pod install && cd ..

# Build and test
flutter run
```

---

## Firebase Project Details

- **Project ID**: `flowsense-cycle-app`
- **Project Name**: FlowSense Cycle App (can be reused for HealPray)
- **Console URL**: https://console.firebase.google.com/project/flowsense-cycle-app

---

## Security Rules

### Firestore Rules Example:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data - only owner can read/write
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Prayers - only owner can read/write
    match /prayers/{prayerId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Moods - only owner can read/write
    match /moods/{moodId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Community prayers - read by all authenticated, write by owner
    match /community_prayers/{prayerId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Troubleshooting

### Issue: "Firebase not initialized"
- Ensure configuration files are in the correct locations
- Run `flutter clean` and rebuild

### Issue: "Google Sign-In failed"
- Verify OAuth 2.0 Client IDs are configured in Google Cloud Console
- Ensure SHA-1/SHA-256 fingerprints are added for Android

### Issue: "Apple Sign-In failed"
- Ensure Apple Sign-In is enabled in App Capabilities
- Verify Service ID is configured in Apple Developer portal

### Issue: "Firestore permissions denied"
- Check security rules in Firebase Console
- Ensure user is authenticated before accessing data

---

## Additional Resources

- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

**Note**: After downloading the configuration files, remove this guide from version control or update it to confirm integration is complete.

---

**Developed and Maintained by ZyraFlow Inc.™**  
© 2025 ZyraFlow Inc. All rights reserved.
