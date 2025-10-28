# HealPray Release Preparation Guide

## ✅ Pre-Release Checklist

### 1. Android Configuration ✅
- [x] 16KB page size support enabled (Android 15+ requirement)
- [x] Target SDK: 35 (Android 15+)
- [x] Min SDK: 26
- [x] Compile SDK: 36
- [x] NDK architectures: ARMv7, ARM64
- [x] AndroidManifest.xml has 16k-pages property
- [x] Namespace: com.healpray.healpray
- [ ] **REQUIRED: Release signing configuration**

### 2. iOS Configuration
- [ ] Bundle ID configured
- [ ] Provisioning profiles
- [ ] App signing certificates
- [ ] Info.plist permissions

### 3. App Store Assets
- [ ] App icon (1024x1024)
- [ ] Screenshots (all device sizes)
- [ ] Feature graphic
- [ ] Privacy policy URL
- [ ] Support email/website

### 4. Version & Build Info
- [x] Version: 1.0.0+1
- [x] Build number: 1
- [ ] Release notes prepared

---

## 🔐 Android Release Signing Setup

### Option 1: Create New Keystore (Recommended for first release)

```bash
cd android/app
keytool -genkey -v -keystore healpray-upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias healpray-key-alias
```

**IMPORTANT:** Save these credentials securely!
- Keystore password
- Key alias: healpray-key-alias
- Key password

### Option 2: Use Existing Keystore

If you already have a keystore, place it in `android/app/` directory.

### Configure Gradle for Release Signing

Create `android/key.properties`:

```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=healpray-key-alias
storeFile=healpray-upload-keystore.jks
```

**Add to .gitignore:**
```
android/key.properties
android/app/*.jks
android/app/*.keystore
```

### Update build.gradle.kts

Add before `android {` block:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Update `signingConfigs` and `buildTypes`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

---

## 📱 iOS Release Setup

### 1. Configure Bundle ID
Open `ios/Runner.xcodeproj` in Xcode and set:
- Bundle Identifier: `com.healpray.healpray`
- Team: Your Apple Developer team
- Version: 1.0.0
- Build: 1

### 2. Configure Signing
In Xcode:
1. Select Runner target
2. Signing & Capabilities tab
3. Enable "Automatically manage signing"
4. Select your team

### 3. Update Info.plist Permissions
Ensure all required permissions have descriptions:
- Camera usage
- Microphone usage
- Location (if used)
- Health data (if used)

---

## 🚀 Build Commands

### Android Release

#### Build App Bundle (for Google Play - RECOMMENDED)
```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### Build APK (for direct distribution)
```bash
flutter build apk --release --split-per-abi

# Outputs:
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

### iOS Release

#### Build IPA for App Store
```bash
flutter build ipa --release

# Output: build/ios/ipa/healpray.ipa
```

#### Upload to App Store Connect
1. Open Transporter app
2. Drag and drop the `.ipa` file
3. Click "Deliver"

Or use command line:
```bash
xcrun altool --upload-app --type ios --file build/ios/ipa/healpray.ipa \
  --apiKey <your-api-key> --apiIssuer <your-issuer-id>
```

---

## 🧪 Pre-Release Testing

### Test on Real Devices

#### Android
```bash
# Install release build on device
flutter install --release
```

Test:
- [ ] App launches without errors
- [ ] Daily mood check-in appears
- [ ] Navigation works (swipe between tabs)
- [ ] Settings screens all functional
- [ ] Sophia AI responds correctly
- [ ] Dark mode toggle works
- [ ] All features load properly

#### iOS
```bash
# Build and run on device
flutter run --release
```

Test same checklist as Android.

### Performance Testing
- [ ] App launches in < 3 seconds
- [ ] Navigation is smooth (60fps)
- [ ] No memory leaks
- [ ] Battery usage is reasonable
- [ ] No crashes in critical flows

---

## 📝 Store Listing Content

### App Name
HealPray - Daily Healing & Prayer

### Short Description
Your AI-powered spiritual companion for emotional wellness, prayer, and meditation

### Full Description
```
HealPray is your daily spiritual companion, combining AI wisdom with emotional support to guide your faith journey.

✨ KEY FEATURES:

🙏 AI-Powered Prayer Generation
Personalized prayers based on your mood and spiritual needs using advanced AI (Gemini)

😊 Smart Mood Tracking
Daily check-ins with beautiful visualizations and emotional pattern insights

🧘 Guided Meditation
9 meditation types: Mindfulness, Healing, Gratitude, Sleep, and more

💬 Sophia AI Companion
Advanced emotional intelligence with crisis detection and spiritual guidance

📊 Wellness Analytics
Track your spiritual and emotional journey with comprehensive insights

🌙 Crisis Support
24/7 support with immediate resources and compassionate AI guidance

🎨 Beautiful Design
Stunning gradients, glass morphism UI, and smooth animations

🔒 Privacy First
Your data is encrypted and secure. GDPR & CCPA compliant

🌍 Interfaith Approach
Respectful of all spiritual traditions and denominations

FEATURES IN DETAIL:

• Daily mood check-in on app launch
• Swipeable navigation between sections
• Light & dark mode with system detection
• Conversation history with context awareness
• Streak tracking for habits
• Export your data anytime
• Notification customization
• Multi-language support (coming soon)

Whether you're seeking comfort, guidance, or celebration, HealPray accompanies you with wisdom, empathy, and unwavering support.

Download now and start your healing journey! 🌟
```

### Keywords (iOS)
prayer, meditation, spiritual, wellness, mental health, mood tracking, AI companion, healing, faith, mindfulness

### Categories
- Primary: Health & Fitness
- Secondary: Lifestyle

### Content Rating
- 4+ / Everyone
- No mature content

### Privacy Policy URL
https://healpray.app/privacy

### Support Email
ronos.icloud@gmail.com

---

## 📸 Required Assets

### App Icon
- **Android:** Already configured in `android/app/src/main/res/mipmap-*`
- **iOS:** Already configured in `ios/Runner/Assets.xcassets/AppIcon.appiconset`
- **Store Listing:** 1024x1024px PNG (no transparency, no rounded corners)

### Screenshots Needed

#### Android (Google Play)
- Phone: 1080 x 1920px (minimum 2 screenshots)
- 7-inch tablet: 1200 x 1920px
- 10-inch tablet: 1920 x 1200px

#### iOS (App Store)
- iPhone 6.7" (iPhone 14 Pro Max): 1290 x 2796px
- iPhone 6.5" (iPhone 11 Pro Max): 1242 x 2688px
- iPhone 5.5" (iPhone 8 Plus): 1242 x 2208px
- iPad Pro (6th gen): 2048 x 2732px

### Feature Graphic (Android only)
- Size: 1024 x 500px
- Format: PNG or JPEG

---

## ✅ Final Checks Before Submission

### Code Quality
- [ ] No TODO comments in production code
- [ ] All console.log / print statements removed or conditional
- [ ] No hardcoded API keys (use environment variables)
- [ ] Error handling in place for all critical features
- [ ] Loading states for all async operations

### Legal & Compliance
- [ ] Privacy policy updated and accessible
- [ ] Terms of service available
- [ ] GDPR compliance verified
- [ ] CCPA compliance verified
- [ ] User data deletion implemented

### Store Requirements
- [ ] Age rating appropriate
- [ ] Content warnings if needed
- [ ] All required permissions justified in descriptions
- [ ] No broken links in store listing
- [ ] Contact information current

### Technical
- [ ] Min SDK requirements met
- [ ] Target SDK is latest stable
- [ ] 16KB page size support enabled ✅
- [ ] App size optimized (< 150MB recommended)
- [ ] Crash-free rate target: 99.9%

---

## 🚢 Release Process

### Phase 1: Internal Testing
1. Build release version
2. Test on multiple devices
3. Fix critical bugs
4. Test again

### Phase 2: Beta Testing
**Android:**
1. Upload AAB to Google Play Console
2. Create closed testing track
3. Add beta testers
4. Gather feedback

**iOS:**
1. Upload IPA via Transporter
2. Create TestFlight beta
3. Add external testers
4. Gather feedback

### Phase 3: Production Release
**Android:**
1. Promote to production track
2. Set rollout percentage (start with 10-20%)
3. Monitor crash reports
4. Gradually increase rollout

**iOS:**
1. Submit for App Store review
2. Wait for approval (1-3 days typically)
3. Release immediately or scheduled
4. Monitor reviews and crashes

---

## 📊 Post-Release Monitoring

### Week 1 (Critical Monitoring)
- [ ] Check crash-free rate daily
- [ ] Monitor user reviews
- [ ] Watch for critical bugs
- [ ] Track download numbers
- [ ] Monitor server load (if applicable)

### Week 2-4 (Active Monitoring)
- [ ] Analyze user feedback
- [ ] Plan hotfixes if needed
- [ ] Track retention metrics
- [ ] Monitor performance metrics

### Ongoing
- [ ] Monthly analytics review
- [ ] Quarterly feature updates
- [ ] Security patches as needed
- [ ] OS updates compatibility

---

## 🆘 Emergency Rollback Plan

If critical issues found post-release:

### Android
1. Halt rollout immediately in Play Console
2. Fix issue urgently
3. Submit new version
4. Resume rollout after verification

### iOS
1. Cannot rollback once live
2. Submit urgent hotfix
3. Request expedited review (explain critical bug)
4. Usually approved within 24 hours

---

## 📞 Support Contacts

- **Developer:** ronos.icloud@gmail.com
- **WhatsApp:** +1 (762) 770-2411
- **Telegram:** @ronospace
- **Website:** https://healpray.app

---

**Good luck with the release! 🚀**

Remember: First release is always the hardest. After this, updates will be much smoother!
