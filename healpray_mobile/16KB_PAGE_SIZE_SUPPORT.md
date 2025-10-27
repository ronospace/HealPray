# 16 KB Page Size Support for HealPray Android App

## Overview
Google Play requires all apps targeting Android 15+ to support 16 KB memory page sizes by **November 1, 2025**. This document outlines the changes needed to ensure HealPray complies.

## What is 16 KB Page Size?
Android devices traditionally use 4 KB memory pages. Newer devices (especially ARM-based) may use 16 KB pages for better performance. Apps must be compatible with both.

## Current Status
❌ **Not Compliant** - The current production release does not support 16 KB memory page sizes.

## Required Changes

### 1. Update `build.gradle` Configuration

Add 16 KB page size support flags to `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // ... existing config
        
        // Add 16 KB page size support
        ndk {
            // Support both 4 KB and 16 KB page sizes
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }
    
    buildTypes {
        release {
            // ... existing release config
            
            // Enable 16 KB page size optimization
            ndk {
                debugSymbolLevel 'FULL'
            }
        }
    }
}
```

### 2. Update Gradle Properties

Add to `android/gradle.properties`:

```properties
# Support 16 KB memory page sizes
android.bundle.enableUncompressedNativeLibs=false
```

### 3. Update Native Libraries (if any)

If using native libraries, ensure they're compiled with 16 KB support:

```bash
# For NDK builds
-DANDROID_MAX_PAGE_SIZE=16384
```

### 4. Update `build.gradle` (Project Level)

Ensure you're using compatible Gradle and Android Gradle Plugin versions in `android/build.gradle`:

```gradle
buildscript {
    dependencies {
        // Use latest AGP that supports 16 KB
        classpath 'com.android.tools.build:gradle:8.7.0' // or later
    }
}
```

### 5. Flutter-Specific Changes

Update `android/app/build.gradle`:

```gradle
android {
    compileSdk 35 // Target Android 15+
    
    defaultConfig {
        minSdk 21
        targetSdk 35 // Must be 35 for Android 15
        
        // Enable 16 KB page size support
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a'
        }
    }
}
```

## Testing

### 1. Test on 16 KB Emulator

Create an AVD with 16 KB page size:

```bash
# Create emulator with 16 KB support
flutter emulators --create --name 16kb_test

# Or use existing device with flag
adb shell setprop debug.force_16kb_page_size true
```

### 2. Test Build

```bash
# Build release bundle
flutter build appbundle --release

# Check for 16 KB support
bundletool dump manifest --bundle=build/app/outputs/bundle/release/app-release.aab
```

### 3. Automated Testing

Run tests to verify compatibility:

```bash
# Run all tests
flutter test

# Run integration tests
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Verification Checklist

- [ ] Updated `android/app/build.gradle` with 16 KB support
- [ ] Updated `android/gradle.properties` 
- [ ] Set `targetSdk` to 35
- [ ] Enabled proper NDK configuration
- [ ] Tested on 16 KB emulator
- [ ] Built release bundle successfully
- [ ] Verified no crashes on 16 KB devices
- [ ] Checked memory usage is acceptable
- [ ] All native dependencies support 16 KB

## Common Issues & Solutions

### Issue 1: Native Library Crashes
**Solution:** Rebuild native libraries with `-DANDROID_MAX_PAGE_SIZE=16384`

### Issue 2: JNI Alignment Issues  
**Solution:** Ensure data structures are properly aligned:
```c
// Use explicit alignment
__attribute__((aligned(16384)))
```

### Issue 3: Memory Consumption
**Solution:** Profile and optimize memory usage:
```bash
flutter run --profile
# Use DevTools to analyze memory
```

## Dependencies to Check

Review these dependencies for 16 KB compatibility:
- `hive` / `hive_flutter` - ✅ Compatible
- `firebase_core` - ✅ Compatible (update to latest)
- `google_mobile_ads` - ✅ Compatible (update to latest)
- Any custom native plugins - ⚠️ Needs verification

## Release Process

1. **Make Changes:** Apply all configurations above
2. **Test Locally:** Test on 16 KB emulator
3. **Build Bundle:**
   ```bash
   flutter build appbundle --release --target-platform android-arm64
   ```
4. **Upload to Play Console:** Upload as new release
5. **Verify:** Check Play Console shows "16 KB support: Yes"

## Timeline

- **Now:** Implement changes and test locally
- **Testing Phase:** 1-2 weeks of thorough testing
- **Before Nov 1, 2025:** Deploy to production

## Resources

- [Google Play 16 KB Announcement](https://developer.android.com/guide/practices/page-sizes)
- [Flutter Migration Guide](https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration)
- [Testing Guide](https://developer.android.com/about/versions/15/behavior-changes-15#16kb-page-sizes)

## Implementation Status

### Completed
- [ ] Documentation created

### In Progress  
- [ ] Configuration updates
- [ ] Testing setup

### Not Started
- [ ] Native library verification
- [ ] Production release

---

**Last Updated:** 2025-10-27
**Owner:** Development Team
**Priority:** HIGH (Deadline: Nov 1, 2025)
