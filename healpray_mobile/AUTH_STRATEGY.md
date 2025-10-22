# HealPray Authentication Strategy 🙏

## Overview
HealPray uses a **progressive authentication** approach that balances user experience with data security and sync capabilities.

## Authentication Flow

### Phase 1: Anonymous Start (Immediate Access)
```
User Opens App
    ↓
Firebase Anonymous Auth (Auto)
    ↓
Full Access to Core Features
    ↓
Local Data Storage (Hive)
```

**Benefits:**
- ✅ Zero friction onboarding
- ✅ Users experience value immediately
- ✅ Data persists locally
- ✅ Still tracked for analytics

### Phase 2: Upgrade Prompts (Value-Based)
Prompt account creation when:
1. **5+ saved prayers** - "Don't lose your prayers! Create an account to sync across devices"
2. **7+ days active** - "Secure your spiritual journey with an account"
3. **Community features** - "Create an account to join prayer circles"
4. **Device change** - "Sign in to restore your data"
5. **Premium features** - "Upgrade to unlock advanced meditation"

### Phase 3: Full Account (Seamless Conversion)
```
Anonymous User
    ↓
Link to Account (Email/Google/Apple)
    ↓
Migrate Local Data to Cloud
    ↓
Cloud Sync Enabled
```

## Supported Sign-In Methods

### 1. **Email/Password** ✅
- Traditional email registration
- Password reset flow
- Email verification (optional)

### 2. **Google Sign-In** ✅
- One-tap sign-in
- Trusted provider
- Cross-platform sync

### 3. **Apple Sign-In** ✅
- Required for iOS App Store
- Privacy-focused
- "Hide My Email" support

### 4. **Anonymous Auth** ⭐ *New - Recommended*
- Immediate access
- Converts to full account
- Preserves user data

## Firebase Integration

### Current Status
- ✅ Firebase Auth SDK configured
- ✅ Authentication providers implemented
- ⏸️ Firebase initialization disabled in dev mode

### Setup Required

#### 1. **Firebase Console Setup**
```bash
# Create Firebase project
1. Go to https://console.firebase.google.com
2. Create new project "HealPray"
3. Add iOS app (bundle ID: com.healpray.app)
4. Add Android app (package: com.healpray.app)
5. Download configuration files
```

#### 2. **Enable Authentication Methods**
- ✅ Enable Email/Password
- ✅ Enable Google Sign-In
- ✅ Enable Apple Sign-In
- ✅ Enable Anonymous Auth

#### 3. **Firestore Security Rules**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Prayers are private to users
    match /prayers/{prayerId} {
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
    }
    
    // Mood entries are private
    match /moods/{moodId} {
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
    }
    
    // Community prayers are public read, auth write
    match /community_prayers/{prayerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    resource.data.userId == request.auth.uid;
    }
  }
}
```

## Data Backup Strategy

### Local Backup (Hive)
```
User Data (Local)
    ↓
Hive Encrypted Storage
    ↓
Periodic Backup to Firebase
```

### Cloud Backup (Firebase)
```
Firestore Collections:
├── users/{userId}
│   ├── profile
│   ├── preferences
│   └── analytics
├── prayers/{prayerId}
│   ├── text
│   ├── category
│   ├── createdAt
│   └── userId
├── moods/{moodId}
│   ├── rating
│   ├── notes
│   ├── timestamp
│   └── userId
└── community_prayers/{prayerId}
    ├── text
    ├── likes
    └── comments
```

### GitHub Backup (Code Only)
```bash
# Current backup strategy
git add -A
git commit -m "Feature: Description"
git push origin main

# Recommended: Add tags for releases
git tag -a v1.0.0 -m "Release 1.0.0"
git push origin v1.0.0
```

## Implementation Plan

### Step 1: Enable Anonymous Auth
```dart
// Add to auth_service.dart
Future<void> signInAnonymously() async {
  try {
    final userCredential = await _auth.signInAnonymously();
    AppLogger.info('✅ Anonymous sign-in successful');
  } catch (e) {
    AppLogger.error('❌ Anonymous sign-in failed: $e');
    rethrow;
  }
}

// Auto sign-in on first launch
if (currentUser == null) {
  await signInAnonymously();
}
```

### Step 2: Add Account Upgrade Flow
```dart
// Show upgrade prompt
void showAccountUpgradeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Secure Your Journey'),
      content: Text('Create an account to sync your prayers and never lose your data'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Navigate to sign-up
          },
          child: Text('Create Account'),
        ),
      ],
    ),
  );
}
```

### Step 3: Link Anonymous to Full Account
```dart
// Convert anonymous to full account
Future<void> linkAnonymousToEmail({
  required String email,
  required String password,
}) async {
  try {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    
    await _auth.currentUser!.linkWithCredential(credential);
    AppLogger.info('✅ Anonymous account linked to email');
  } catch (e) {
    AppLogger.error('❌ Account linking failed: $e');
    rethrow;
  }
}
```

## Security Considerations

### Data Encryption
- ✅ **In Transit**: Firebase uses TLS/HTTPS
- ✅ **At Rest**: Firestore encrypts data at rest
- ✅ **Local Storage**: Hive supports encryption

### Privacy
- ✅ **User Consent**: Request before data collection
- ✅ **GDPR Compliant**: Data export/deletion available
- ✅ **Minimal Data**: Only collect what's necessary

### Authentication Security
- ✅ **Password Requirements**: 8+ characters
- ✅ **Email Verification**: Optional but recommended
- ✅ **Rate Limiting**: Firebase provides DDoS protection
- ✅ **Session Management**: Automatic token refresh

## Backup Schedule

### Automatic Backups
```dart
// Sync to Firebase every:
- On prayer creation/edit
- On mood entry
- On settings change
- Every 5 minutes (background)
- On app close
```

### Manual Backups
```dart
// User-triggered export
- Settings > Export Data
- Downloads JSON backup
- Includes all prayers, moods, preferences
```

### GitHub Repository Backups
```bash
# Automated via GitHub Actions
name: Daily Backup
on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Create backup branch
        run: |
          git checkout -b backup-$(date +%Y%m%d)
          git push origin backup-$(date +%Y%m%d)
```

## Production Checklist

### Before Launch
- [ ] Enable Firebase project
- [ ] Add iOS and Android apps to Firebase
- [ ] Download and add google-services.json (Android)
- [ ] Download and add GoogleService-Info.plist (iOS)
- [ ] Configure OAuth for Google/Apple sign-in
- [ ] Set up Firestore security rules
- [ ] Enable Firebase Authentication methods
- [ ] Test anonymous → full account conversion
- [ ] Test data sync across devices
- [ ] Configure Firebase backup (Firestore export)
- [ ] Set up monitoring and alerts

### Repository Management
- [ ] Create GitHub organization/private repo
- [ ] Enable branch protection (main branch)
- [ ] Add .gitignore for sensitive files
- [ ] Never commit Firebase config files publicly
- [ ] Use environment variables for API keys
- [ ] Set up automated testing CI/CD
- [ ] Configure automatic backups

## Cost Estimates (Firebase Free Tier)

### Free Tier Includes:
- **Authentication**: Unlimited users
- **Firestore**: 
  - 50K reads/day
  - 20K writes/day
  - 20K deletes/day
  - 1 GB storage
- **Cloud Storage**: 5 GB
- **Hosting**: 10 GB/month

### Expected Usage (10K users):
- **Reads**: ~30K/day ✅ Within limit
- **Writes**: ~15K/day ✅ Within limit
- **Storage**: ~500 MB ✅ Within limit

### When to Upgrade (Blaze Plan):
- Pay-as-you-go
- Free tier still applies
- Only charged for overages
- Expected cost: $10-50/month for 50K+ users

## Recommended Approach

### For Development (Current)
✅ Keep development mode enabled
✅ Use mock authentication
✅ Test locally without Firebase costs

### For Beta Testing
1. Enable Firebase project
2. Invite beta testers
3. Use anonymous auth by default
4. Collect feedback on auth flow

### For Production Launch
1. Implement anonymous auth (immediate access)
2. Smart upgrade prompts (5+ uses)
3. Full account with sync
4. Automated Firebase backups
5. GitHub repository protection

---

**Status**: 📋 **Planned** - Auth system ready, Firebase integration needed
**Priority**: 🔥 **High** - Critical for user data security and sync
**Timeline**: 🗓️ **Pre-launch** - Must complete before public release
