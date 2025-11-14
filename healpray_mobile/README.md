# 🙏 HealPray - Your Daily Prayer & Healing Companion

<div align="center">
  <img src="assets/icon/icon.png" alt="HealPray Logo" width="120" height="120"/>
  <p><strong>Your spiritual wellness journey, powered by AI</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.27.2-02569B?logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-Proprietary-red.svg)](#)
  [![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey)](#)
</div>

---

## ✨ Overview

**HealPray** is an AI-powered spiritual wellness companion designed to support your daily prayer, meditation, mood tracking, and spiritual growth. Combining modern technology with timeless spiritual practices, HealPray offers personalized prayers, guided meditations, scripture readings, and an empathetic AI companion named Sophia.

### 🌟 Key Features

- **🤖 Sophia AI Companion** - Emotionally intelligent AI that provides spiritual guidance and support
- **😊 Daily Mood Check-In** - Track your emotional journey with daily prompts and insights
- **📊 Mood Analytics** - Visualize your emotional patterns with advanced charts and AI predictions
- **🙏 AI-Powered Prayer Generation** - Generate personalized prayers based on your mood and needs
- **📿 Prayer Journal** - Record and reflect on your prayers with searchable tags
- **🧘 Guided Meditation** - Access curated meditation sessions with timer and breathing exercises
- **📖 Scripture Reading** - Daily verses, reading plans, and reflection prompts
- **👥 Community Prayers** - Share prayer requests and join prayer circles
- **🌙 Dark/Light Mode** - Beautiful adaptive theming with dimensional gradients
- **🔔 Smart Notifications** - Gentle reminders for prayer, meditation, and mood check-ins
- **📱 Offline Support** - Core features work without internet connection

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.27.2 or higher
- **Dart**: 3.6.1 or higher
- **Xcode**: 15.0+ (for iOS development)
- **Android Studio**: Latest stable version
- **CocoaPods**: Latest version (for iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ronospace/HealPray.git
   cd HealPray/healpray_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`

4. **Set up environment variables**
   - Create a `.env` file in the root directory
   - Add your API keys:
     ```
     GEMINI_API_KEY=your_gemini_api_key_here
     ```

5. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   ```

---

## 🏗️ Architecture

HealPray follows clean architecture principles with feature-based organization:

```
lib/
├── core/               # Core utilities, themes, and widgets
│   ├── config/        # App configuration
│   ├── database/      # Hive database service
│   ├── theme/         # App theming
│   └── widgets/       # Reusable widgets
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── chat/          # Sophia AI chat
│   ├── community/     # Community prayers
│   ├── dashboard/     # Home dashboard
│   ├── meditation/    # Meditation features
│   ├── mood/          # Mood tracking & analytics
│   ├── prayer/        # Prayer generation & journal
│   ├── scripture/     # Scripture reading
│   └── settings/      # App settings
└── shared/            # Shared services and providers
    ├── models/        # Data models
    ├── providers/     # Riverpod providers
    └── services/      # Business logic services
```

---

## 🔧 Build & Release

### Android Release Build

```bash
# Build App Bundle (AAB) for Google Play
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release Build

```bash
# Build iOS Archive
flutter build ipa --release --export-method app-store

# Use Xcode Organizer to export and upload to App Store Connect
```

### Requirements

- **Android**: Supports 16 KB memory page sizes (Android 15+)
- **iOS**: Minimum deployment target iOS 13.0
- **Bundle ID**: `com.healpray.healpray`

---

## 📱 Technologies

- **Framework**: Flutter 3.27.2
- **State Management**: Riverpod 2.6.1
- **Local Database**: Hive 2.2.3
- **Backend**: Firebase (Auth, Firestore, Analytics)
- **AI Services**: Google Gemini AI
- **Charts**: FL Chart 0.70.2
- **Animations**: Lottie, Shimmer
- **Routing**: Go Router 14.6.2

---

## 🤝 Contributing

This is a proprietary project developed and maintained by **ZyraFlow Inc.**

For bug reports and feature requests, please contact:
- **Email**: ronos.icloud@gmail.com
- **WhatsApp**: +1 (762) 770-2411
- **Telegram**: @ronospace

---

## 📄 License

Proprietary and confidential. Unauthorized copying, distribution, or use of this software is strictly prohibited.

**© 2025 ZyraFlow Inc. All rights reserved.**

---

## 🏢 About ZyraFlow Inc.

**Developed and Maintained by ZyraFlow Inc.™**

ZyraFlow Inc. is a technology company focused on creating innovative solutions for health, wellness, and spiritual growth. We combine cutting-edge AI technology with human-centered design to build products that enhance daily life.

---

## 🙏 Acknowledgments

Built with ❤️ and 🙏 for the spiritual wellness community.

---

<div align="center">
  <p><strong>Download HealPray Today</strong></p>
  <p>
    <a href="https://apps.apple.com/app/healpray"><img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="App Store" height="40"/></a>
    <a href="https://play.google.com/store/apps/details?id=com.healpray.healpray"><img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Google Play" height="58"/></a>
  </p>
</div>
