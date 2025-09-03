# 🔥 Firebase Setup - Step by Step (Action 1)

## ✅ **Completed Setup**
- [x] Firebase CLI installed (v14.15.1)
- [x] FlutterFire CLI installed (v1.3.1)
- [x] Firebase Console opened in browser

---

## 🎯 **Manual Steps - Complete These Now:**

### **Step 1: Create Firebase Projects (5 minutes)**

**In the Firebase Console (already opened):**

1. **Create Development Project**
   - Click "Create a project"
   - Project name: `HealPray Development`
   - Project ID: `healpray-dev` (or `healpray-dev-[random]` if taken)
   - ✅ Enable Google Analytics: **Yes**
   - Select/Create Analytics account: Choose existing or create new
   - Click "Create project"

2. **Create Production Project**
   - Click "Create a project" (again)
   - Project name: `HealPray`
   - Project ID: `healpray-app` (or `healpray-app-[random]` if taken)
   - ✅ Enable Google Analytics: **Yes**
   - Use same Analytics account as development
   - Click "Create project"

### **Step 2: Configure Development Project (10 minutes)**

**Select your `healpray-dev` project, then:**

1. **Enable Authentication**
   - Go to Authentication > Sign-in method
   - Enable these providers:
     - ✅ **Email/Password** (Enable both Email/Password and Email link)
     - ✅ **Google** (Set support email)
     - ✅ **Anonymous** 
     - ✅ **Apple** (can configure later)

2. **Create Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Select "Start in test mode" (for development)
   - Choose location: `us-central1` (or nearest to you)
   - Click "Done"

3. **Add Flutter Apps**
   - Go to Project Overview
   - Click iOS icon to add iOS app
     - iOS bundle ID: `com.healpray.app`
     - App nickname: `HealPray iOS Dev`
     - Download `GoogleService-Info.plist` (save for later)
   
   - Click Android icon to add Android app  
     - Android package name: `com.healpray.app`
     - App nickname: `HealPray Android Dev`
     - Download `google-services.json` (save for later)

---

## 🔧 **Terminal Commands - Run These After Manual Setup:**

### **Step 3: Firebase Login & Initialize**

```bash
# Login to Firebase (will open browser)
firebase login

# Verify you're logged in
firebase projects:list
```

### **Step 4: Initialize Firebase in Project**

```bash
# Make sure you're in the HealPray directory
cd /Users/ronos/Workspace/Projects/Active/HealPray

# Initialize Firebase
firebase init

# When prompted, select:
# - Firestore: Configure security rules and indexes
# - Functions: Configure a Cloud Functions directory
# - Hosting: Configure files for Firebase Hosting
# - Storage: Configure a security rules file for Cloud Storage

# Choose existing project: healpray-dev
# Accept defaults for most prompts
```

### **Step 5: Configure FlutterFire**

```bash
# Navigate to Flutter app
cd healpray_mobile

# Configure Firebase for Flutter
flutterfire configure --project=healpray-dev

# This will create lib/firebase_options.dart
```

---

## 📂 **File Organization After Setup**

After completing the setup, your project should have:

```
HealPray/
├── .firebaserc                    # Firebase project aliases
├── firebase.json                  # Firebase configuration
├── firestore.rules                # Database security rules
├── firestore.indexes.json         # Database indexes
├── functions/                     # Cloud Functions directory
│   ├── package.json
│   └── src/
└── healpray_mobile/
    ├── lib/firebase_options.dart  # Generated Firebase config
    ├── ios/Runner/GoogleService-Info.plist
    └── android/app/google-services.json
```

---

## ✅ **Verification Steps**

After setup, run these commands to verify everything works:

```bash
# Test Firebase connection
firebase use --list

# Test Flutter Firebase configuration
cd healpray_mobile
flutter pub get

# Check if Firebase is properly configured
flutter run --debug
# (Should compile without Firebase-related errors)
```

---

## 🎯 **Next: Once This Is Complete**

After Firebase setup is working, you'll be ready for:

**Action 2: API Keys Setup**
- OpenAI API key
- Google Gemini API key  
- Update `.env` file

**Action 3: Test Flutter Setup**
- Run on simulator
- Verify hot reload
- Test basic navigation

---

## 🆘 **Common Issues & Solutions**

**Issue**: Project ID already taken
- **Solution**: Add random suffix like `healpray-dev-xyz`

**Issue**: FlutterFire configure fails
- **Solution**: Make sure you're in `healpray_mobile` directory

**Issue**: Permission denied on Firebase CLI
- **Solution**: Run `firebase login --reauth`

**Issue**: Flutter build errors after Firebase setup
- **Solution**: 
  ```bash
  flutter clean
  flutter pub get
  cd ios && pod install && cd ..
  ```

---

## 📞 **Need Help?**

If you encounter any issues:
1. Check the detailed guide: `docs/firebase_setup_guide.md`
2. Firebase documentation: https://firebase.google.com/docs
3. FlutterFire documentation: https://firebase.flutter.dev

---

**Status**: 🔄 **IN PROGRESS**  
**Next Action**: Complete manual steps above, then run terminal commands  
**Estimated Time**: 15-20 minutes total
