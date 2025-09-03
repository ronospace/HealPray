# 🔥 Firebase Setup Guide for HealPray
## Complete Configuration for Production-Ready Deployment

---

## 🎯 **Overview**

This guide provides step-by-step instructions for setting up Firebase services for the HealPray application, including Authentication, Firestore, Cloud Functions, Analytics, and all required integrations.

---

## 📋 **Prerequisites**

- Firebase Account (Gmail account)
- Firebase CLI installed globally
- Flutter SDK 3.16+
- Node.js 18+ (for Cloud Functions)
- Xcode (for iOS configuration)
- Android Studio (for Android configuration)

---

## 🚀 **Step 1: Create Firebase Projects**

### **1.1 Create Development Project**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Project name: `HealPray Development`
4. Project ID: `healpray-dev` 
5. Enable Google Analytics: Yes
6. Select Analytics account: Create new account

### **1.2 Create Production Project**

1. Click "Create a project" again
2. Project name: `HealPray`  
3. Project ID: `healpray-app`
4. Enable Google Analytics: Yes
5. Use same Analytics account

### **1.3 Project Configuration**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
cd /path/to/healpray
firebase init
```

---

## 🔐 **Step 2: Authentication Setup**

### **2.1 Enable Authentication Methods**

**In Firebase Console > Authentication > Sign-in method:**

1. **Email/Password**
   - Enable Email/Password
   - Enable Email link (passwordless sign-in)

2. **Google Sign-In**  
   - Enable Google provider
   - Set project support email
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)

3. **Apple Sign-In**
   - Enable Apple provider  
   - Configure Apple Developer settings
   - Add Service ID and Team ID

4. **Anonymous Sign-In**
   - Enable Anonymous provider

### **2.2 Security Rules**

```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profile access
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Prayer data access  
    match /prayers/{prayerId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Mood entries access
    match /users/{userId}/moodEntries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Community data (read-only for authenticated users)
    match /community/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.uid == resource.data.createdBy;
    }
    
    // System data (read-only)
    match /system/{document=**} {
      allow read: if request.auth != null;
    }
  }
}
```

---

## 🗄️ **Step 3: Firestore Database Setup**

### **3.1 Create Database**

1. Go to Firestore Database
2. Click "Create database"
3. Select "Start in production mode" 
4. Choose location: `us-central1` (or nearest region)

### **3.2 Database Structure**

```javascript
// Create initial collections and documents
// Run this in Firebase Console > Firestore > Start collection

// System configuration
system/
├── appConfig/
│   └── {
│       "version": "1.0.0",
│       "maintenanceMode": false,
│       "featuresEnabled": {
│         "aiConversation": true,
│         "community": true,
│         "analytics": true
│       }
│     }
├── prayerTemplates/
│   └── [Auto-populated by Cloud Functions]
└── crisisResources/
    └── {
        "hotlines": [
          {
            "name": "National Suicide Prevention Lifeline",
            "number": "988",
            "country": "US"
          }
        ]
      }
```

### **3.3 Composite Indexes**

```javascript
// Create these indexes in Firebase Console > Firestore > Indexes
const indexes = [
  // User mood entries by date
  {
    collectionGroup: 'moodEntries',
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'timestamp', order: 'DESCENDING' }
    ]
  },
  
  // Prayers by mood and category
  {
    collectionGroup: 'prayers', 
    fields: [
      { fieldPath: 'userId', order: 'ASCENDING' },
      { fieldPath: 'category', order: 'ASCENDING' },
      { fieldPath: 'moodContext', order: 'ASCENDING' }
    ]
  },
  
  // Community prayers by popularity
  {
    collectionGroup: 'sharedPrayers',
    fields: [
      { fieldPath: 'isPublic', order: 'ASCENDING' },
      { fieldPath: 'likesCount', order: 'DESCENDING' },
      { fieldPath: 'createdAt', order: 'DESCENDING' }
    ]
  }
];
```

---

## ☁️ **Step 4: Cloud Functions Setup**

### **4.1 Initialize Functions**

```bash
# In project root
firebase init functions

# Choose:
# - Use existing project (healpray-dev)
# - Language: TypeScript
# - ESLint: Yes
# - Install dependencies: Yes
```

### **4.2 Core Functions Implementation**

**functions/src/index.ts:**
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { OpenAI } from 'openai';
import { GoogleGenerativeAI } from '@google/generative-ai';

admin.initializeApp();

const openai = new OpenAI({
  apiKey: functions.config().openai.api_key,
});

const genAI = new GoogleGenerativeAI(functions.config().gemini.api_key);

// Generate AI Prayer
export const generatePrayer = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { moodLevel, category, timeOfDay, userPreferences } = data;
  
  try {
    const prompt = buildPrayerPrompt(moodLevel, category, timeOfDay, userPreferences);
    
    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: "You are a compassionate AI that creates personalized, inclusive prayers for spiritual healing and emotional support."
        },
        {
          role: "user", 
          content: prompt
        }
      ],
      max_tokens: 300,
      temperature: 0.7,
    });
    
    const prayerContent = completion.choices[0].message?.content;
    
    if (!prayerContent) {
      throw new Error('Failed to generate prayer content');
    }
    
    // Save prayer to Firestore
    const prayerDoc = await admin.firestore().collection('prayers').add({
      userId: context.auth.uid,
      content: prayerContent,
      category,
      moodContext: moodLevel,
      timeOfDay,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      source: 'ai_generated',
      metadata: {
        model: 'gpt-4',
        prompt_version: '1.0'
      }
    });
    
    return {
      prayerId: prayerDoc.id,
      content: prayerContent,
      category,
      moodContext: moodLevel
    };
    
  } catch (error) {
    console.error('Prayer generation failed:', error);
    throw new functions.https.HttpsError('internal', 'Failed to generate prayer');
  }
});

// Analyze mood trends and detect crisis
export const analyzeMoodTrends = functions.firestore
  .document('users/{userId}/moodEntries/{entryId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const newEntry = snap.data();
    
    // Get recent mood entries (last 7 days)
    const recentEntries = await admin.firestore()
      .collection(`users/${userId}/moodEntries`)
      .where('timestamp', '>=', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000))
      .orderBy('timestamp', 'desc')
      .limit(10)
      .get();
    
    const moods = recentEntries.docs.map(doc => doc.data().moodLevel);
    const averageMood = moods.reduce((sum, mood) => sum + mood, 0) / moods.length;
    
    // Crisis detection logic
    const consecutiveLowMoods = checkConsecutiveLowMoods(moods);
    const isCrisisDetected = averageMood <= 3 && consecutiveLowMoods >= 3;
    
    if (isCrisisDetected) {
      // Trigger crisis support
      await triggerCrisisSupport(userId, averageMood);
    }
    
    // Update user analytics
    await admin.firestore().doc(`users/${userId}`).update({
      'analytics.averageMood': averageMood,
      'analytics.lastUpdated': admin.firestore.FieldValue.serverTimestamp(),
      'analytics.crisisAlertTriggered': isCrisisDetected
    });
  });

// Send scheduled notifications
export const sendScheduledNotifications = functions.pubsub
  .schedule('every day 07:00')
  .timeZone('America/New_York')
  .onRun(async (context) => {
    // Get all users who opted in for morning notifications
    const users = await admin.firestore()
      .collection('users')
      .where('preferences.notifications.morning', '==', true)
      .get();
    
    const notifications = users.docs.map(doc => {
      const userData = doc.data();
      return {
        token: userData.fcmToken,
        notification: {
          title: 'Good Morning 🌅',
          body: 'Start your day with a moment of hope and gratitude'
        },
        data: {
          type: 'morning_prayer',
          userId: doc.id
        }
      };
    });
    
    // Send batch notifications
    if (notifications.length > 0) {
      await admin.messaging().sendAll(notifications);
    }
  });

// Helper functions
function buildPrayerPrompt(moodLevel: number, category: string, timeOfDay: string, preferences: any): string {
  return `Create a personalized prayer for someone with:
  - Mood level: ${moodLevel}/10
  - Category: ${category}  
  - Time: ${timeOfDay}
  - Preferences: ${JSON.stringify(preferences)}
  
  The prayer should be:
  - Compassionate and uplifting
  - Inclusive and non-denominational
  - 2-3 paragraphs long
  - Appropriate for the mood level
  - Culturally sensitive`;
}

function checkConsecutiveLowMoods(moods: number[]): number {
  let consecutive = 0;
  let maxConsecutive = 0;
  
  for (const mood of moods) {
    if (mood <= 3) {
      consecutive++;
      maxConsecutive = Math.max(maxConsecutive, consecutive);
    } else {
      consecutive = 0;
    }
  }
  
  return maxConsecutive;
}

async function triggerCrisisSupport(userId: string, averageMood: number): Promise<void> {
  // Send immediate notification with crisis resources
  const userDoc = await admin.firestore().doc(`users/${userId}`).get();
  const userData = userDoc.data();
  
  if (userData?.fcmToken) {
    await admin.messaging().send({
      token: userData.fcmToken,
      notification: {
        title: 'We\'re here for you 💙',
        body: 'You\'re not alone. Tap for support resources.'
      },
      data: {
        type: 'crisis_support',
        averageMood: averageMood.toString()
      }
    });
  }
  
  // Log crisis event for follow-up
  await admin.firestore().collection('crisisEvents').add({
    userId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
    averageMood,
    notificationSent: true
  });
}
```

### **4.3 Deploy Functions**

```bash
# Set environment variables
firebase functions:config:set openai.api_key="your_openai_api_key"
firebase functions:config:set gemini.api_key="your_gemini_api_key"

# Deploy functions
firebase deploy --only functions
```

---

## 📱 **Step 5: Flutter Integration**

### **5.1 iOS Configuration**

**ios/Runner/Info.plist:**
```xml
<!-- Add URL scheme for authentication -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>healpray.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.healpray.app</string>
        </array>
    </dict>
</array>

<!-- Add privacy permissions -->
<key>NSCameraUsageDescription</key>
<string>HealPray needs camera access to allow you to share images in prayer circles.</string>
<key>NSMicrophoneUsageDescription</key>  
<string>HealPray needs microphone access for voice prayers and spiritual conversations.</string>
<key>NSUserNotificationsUsageDescription</key>
<string>HealPray sends prayer reminders and supportive messages.</string>
```

**Copy GoogleService-Info.plist to ios/Runner/**

### **5.2 Android Configuration**

**android/app/google-services.json** (copy from Firebase Console)

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### **5.3 Firebase Options Generation**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure --project=healpray-dev

# This generates lib/firebase_options.dart
```

---

## 🔔 **Step 6: Cloud Messaging Setup**

### **6.1 Enable Cloud Messaging**

1. Firebase Console > Cloud Messaging
2. Generate server key (save securely)
3. Configure APNs for iOS (upload certificates)

### **6.2 Notification Categories**

```javascript
// Create notification templates in Firestore
const notificationTemplates = {
  morning_prayer: {
    title: "Good Morning 🌅",
    body: "Start your day with a moment of hope and gratitude",
    scheduledTime: "07:00",
    category: "daily_reminder"
  },
  
  midday_strength: {
    title: "Finding Strength 💪", 
    body: "Take a peaceful break for inner strength",
    scheduledTime: "12:00",
    category: "daily_reminder"  
  },
  
  evening_reflection: {
    title: "Peaceful Evening 🌙",
    body: "Reflect on today's blessings and find peace", 
    scheduledTime: "21:00",
    category: "daily_reminder"
  },
  
  crisis_support: {
    title: "We're Here for You 💙",
    body: "You're not alone. Tap for support resources.",
    category: "crisis_alert",
    priority: "high"
  }
};
```

---

## 📊 **Step 7: Analytics Configuration**

### **7.1 Firebase Analytics**

```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  static FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;
  
  // Custom events for HealPray
  static Future<void> logPrayerGenerated(String category, int moodLevel) async {
    await _analytics.logEvent(
      name: 'prayer_generated',
      parameters: {
        'prayer_category': category,
        'user_mood_level': moodLevel,
        'source': 'ai_generated',
      },
    );
  }
  
  static Future<void> logMoodEntry(int moodLevel, String? description) async {
    await _analytics.logEvent(
      name: 'mood_logged',
      parameters: {
        'mood_level': moodLevel,
        'has_description': description != null,
      },
    );
  }
  
  static Future<void> logCrisisEventDetected(int moodLevel) async {
    await _analytics.logEvent(
      name: 'crisis_detected',
      parameters: {
        'mood_level': moodLevel,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}
```

---

## 🔒 **Step 8: Security Configuration**

### **8.1 App Check (Recommended)**

```bash
# Enable App Check in Firebase Console
# Add reCAPTCHA site key for web
# Configure device attestation for mobile
```

### **8.2 Security Rules Testing**

```bash
# Install Firebase emulator
firebase init emulators

# Start emulators
firebase emulators:start --only firestore,auth,functions

# Run security rules tests
npm test
```

---

## 🚀 **Step 9: Deployment Commands**

### **9.1 Development Deployment**

```bash
# Deploy to development environment
firebase use healpray-dev
firebase deploy

# Deploy specific services
firebase deploy --only firestore:rules
firebase deploy --only functions
firebase deploy --only storage
```

### **9.2 Production Deployment**

```bash
# Switch to production
firebase use healpray-app

# Deploy with confirmation
firebase deploy --only firestore:rules,functions:generatePrayer

# Full deployment
firebase deploy
```

---

## 📋 **Step 10: Environment Variables**

### **10.1 Update .env files**

```bash
# .env (development)
FIREBASE_PROJECT_ID=healpray-dev
FIREBASE_WEB_API_KEY=your_web_api_key_here
FIREBASE_STORAGE_BUCKET=healpray-dev.appspot.com

# .env.production  
FIREBASE_PROJECT_ID=healpray-app
FIREBASE_WEB_API_KEY=your_prod_web_api_key_here
FIREBASE_STORAGE_BUCKET=healpray-app.appspot.com
```

---

## 🧪 **Step 11: Testing**

### **11.1 Firebase Emulator Testing**

```bash
# Start emulators
firebase emulators:start

# Run Flutter tests with emulators
flutter test integration_test/firebase_test.dart
```

### **11.2 Security Rules Testing**

```javascript
// test/security.test.js  
const { assertFails, assertSucceeds, initializeTestEnvironment } = require('@firebase/rules-unit-testing');

describe('HealPray Security Rules', () => {
  let testEnv;
  
  beforeAll(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: 'healpray-test',
      firestore: {
        rules: fs.readFileSync('firestore.rules', 'utf8'),
      },
    });
  });
  
  test('Users can only access their own data', async () => {
    const alice = testEnv.authenticatedContext('alice');
    const bob = testEnv.authenticatedContext('bob');
    
    // Alice can read her own data
    await assertSucceeds(alice.firestore().doc('users/alice').get());
    
    // Alice cannot read Bob's data  
    await assertFails(alice.firestore().doc('users/bob').get());
  });
});
```

---

## 📈 **Step 12: Monitoring & Alerting**

### **12.1 Set up Crashlytics**

```dart
// Already configured in main.dart
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

### **12.2 Performance Monitoring**

```dart
// lib/core/services/performance_service.dart
class PerformanceService {
  static Future<void> startTrace(String traceName) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.start();
  }
  
  static Future<void> stopTrace(String traceName) async {
    final trace = FirebasePerformance.instance.newTrace(traceName);
    await trace.stop();
  }
}
```

---

## ✅ **Verification Checklist**

- [ ] Firebase projects created (dev & production)
- [ ] Authentication providers enabled
- [ ] Firestore database configured with security rules
- [ ] Cloud Functions deployed and tested
- [ ] Cloud Messaging configured
- [ ] Firebase Analytics tracking custom events
- [ ] iOS app configured with GoogleService-Info.plist
- [ ] Android app configured with google-services.json
- [ ] Security rules tested
- [ ] Environment variables configured
- [ ] Emulator testing setup complete
- [ ] Monitoring and alerting configured

---

## 🆘 **Troubleshooting**

### **Common Issues:**

1. **Build errors after Firebase setup**
   ```bash
   flutter clean
   flutter pub get
   cd ios && rm Podfile.lock && pod install
   ```

2. **Android build fails**  
   - Check google-services.json is in android/app/
   - Verify minSdkVersion is 21+
   - Enable multidex

3. **iOS build fails**
   - Verify GoogleService-Info.plist is in ios/Runner/
   - Check bundle identifier matches Firebase config
   - Update iOS deployment target to 12.0+

4. **Cloud Functions timeout**
   - Increase timeout in function configuration
   - Check API rate limits
   - Verify environment variables are set

---

## 📞 **Support**

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [Firebase Support](https://support.google.com/firebase)

---

**Setup Guide Version**: 1.0  
**Last Updated**: January 2024  
**Verified By**: Jeff Ronos
