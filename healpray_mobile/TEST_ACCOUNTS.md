# 🧪 HealPray Test Accounts

**Purpose**: These accounts are for testing HealPray features without requiring testers to create their own accounts.

---

## 🔐 Test User Credentials

### Account 1: Demo User (Primary Tester)
- **Email**: `demo@healpray.com`
- **Password**: `HealPray2025!`
- **Purpose**: Full-featured testing account
- **Data**: Pre-populated with sample prayers, mood entries, and meditation sessions

### Account 2: Test User (Secondary Tester)
- **Email**: `tester@healpray.com`
- **Password**: `TestHeal123!`
- **Purpose**: Clean account for fresh testing
- **Data**: Minimal sample data

### Account 3: Developer Testing
- **Email**: `dev@healpray.com`
- **Password**: `DevTest2025!`
- **Purpose**: Development and debugging
- **Data**: Edge cases and test scenarios

---

## 🚀 How to Use

### For Testers

1. **Download the app** from TestFlight (iOS) or Internal Testing (Android)

2. **Launch HealPray**

3. **On Welcome Screen:**
   - Tap "Continue with Email"
   - Enter one of the test emails above
   - Enter the corresponding password
   - Tap "Sign In"

4. **Start Testing:**
   - Explore all features
   - Test mood tracking, prayers, meditation
   - Try Sophia AI chat
   - Check analytics and community features

### Alternative: Demo Login Button

The app includes a "Demo Login" button on the welcome screen that automatically signs in with the demo account. No need to type credentials!

---

## 📝 Creating Test Accounts in Firebase

**For developers/admins setting up Firebase:**

### Via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/project/flowsense-cycle-app)
2. Navigate to **Authentication** > **Users** tab
3. Click **Add User**
4. Enter:
   - Email: `demo@healpray.com`
   - Password: `HealPray2025!`
5. Repeat for other test accounts

### Via Firebase Admin SDK (Automated)

```javascript
const admin = require('firebase-admin');
admin.initializeApp();

const testAccounts = [
  { email: 'demo@healpray.com', password: 'HealPray2025!' },
  { email: 'tester@healpray.com', password: 'TestHeal123!' },
  { email: 'dev@healpray.com', password: 'DevTest2025!' },
];

async function createTestAccounts() {
  for (const account of testAccounts) {
    try {
      const user = await admin.auth().createUser({
        email: account.email,
        password: account.password,
        emailVerified: true,
        displayName: account.email.split('@')[0],
      });
      console.log(`✅ Created: ${user.email}`);
    } catch (error) {
      console.log(`⚠️ ${account.email}: ${error.message}`);
    }
  }
}

createTestAccounts();
```

---

## 🔒 Security Notes

1. **Not for Production**: These credentials are for testing only
2. **Shared Accounts**: Multiple testers may use the same account
3. **No Sensitive Data**: Do not store personal information in test accounts
4. **Regular Reset**: Test accounts should be reset periodically
5. **Firestore Rules**: Ensure test accounts have proper access permissions

---

## 🧹 Resetting Test Accounts

To reset test account data:

1. Go to Firebase Console > Firestore Database
2. Find collections for each test user:
   - `users/{userId}` - User profile
   - `prayers/{userId}` - Prayer entries
   - `moods/{userId}` - Mood data
   - `meditation_sessions/{userId}` - Session history
3. Delete or reset the data as needed

---

## 📊 Test Account Features

### Demo Account (`demo@healpray.com`)
- ✅ Pre-populated with 10 prayer entries
- ✅ 30 days of mood tracking data
- ✅ 5 completed meditation sessions
- ✅ Active AI chat history with Sophia
- ✅ Community prayer requests submitted
- ✅ Subscribed to notifications

### Test Account (`tester@healpray.com`)
- ✅ Clean slate for fresh testing
- ✅ Minimal sample data (1-2 entries)
- ✅ Good for onboarding flow testing

### Dev Account (`dev@healpray.com`)
- ✅ Edge case scenarios
- ✅ Various mood types and patterns
- ✅ Long prayer texts
- ✅ Multiple community interactions

---

## 🎯 Testing Checklist

Use test accounts to verify:

- [ ] Email/password authentication works
- [ ] Google Sign-In integration (if enabled)
- [ ] Apple Sign-In integration (iOS)
- [ ] Anonymous/Guest mode
- [ ] User profile creation and updates
- [ ] Prayer journal CRUD operations
- [ ] Mood tracking and analytics
- [ ] Meditation timer and sessions
- [ ] Sophia AI chat functionality
- [ ] Community prayers and requests
- [ ] Scripture reading
- [ ] Notifications and reminders
- [ ] Settings and preferences
- [ ] Data export functionality
- [ ] Dark/Light mode themes
- [ ] Offline functionality

---

## 🚨 Important Reminders

1. **Do NOT share these credentials publicly** - They are for internal testing only
2. **Change passwords before production launch**
3. **Delete test accounts or disable them** before public release
4. **Monitor test account activity** for unusual behavior
5. **Reset test data regularly** to maintain clean testing environment

---

## 📧 Support

If test accounts are not working:
- Verify they exist in Firebase Authentication
- Check Firestore security rules
- Ensure Firebase project is `flowsense-cycle-app`
- Contact: ronos.icloud@gmail.com

---

**Developed and Maintained by ZyraFlow Inc.™**  
© 2025 ZyraFlow Inc. All rights reserved.

---

**Last Updated**: January 14, 2025  
**Version**: 1.0.0
