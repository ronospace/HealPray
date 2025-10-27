# HealPray App - Comprehensive Fix Blueprint

## Executive Summary
This document outlines all identified issues and their fixes for the HealPray mobile app.

## Critical Issues Identified

### 1. ❌ Routing Errors
**Problem**: Navigation to `/notifications` fails with "no routes for location: /notifications"
**Root Cause**: Route is nested under `/settings` as `/settings/notifications`
**Fix**: Update navigation path in settings_screen.dart (line 119)

### 2. ❌ Missing Feature Screens
**Problem**: Multiple features show "Oops! Something went wrong" error
**Affected Features**:
- Generate Prayer → Works (route exists: `/prayer`)
- Guided Meditation → MISSING (no route)
- Scripture Reading → MISSING (no route)
- Prayer Journal → MISSING (no route)  
- Community Prayers → Placeholder only (route exists: `/community`)

### 3. ❌ Settings Screen Title Invisible
**Problem**: "Settings" title is white text on white/light gradient background
**Location**: settings_screen.dart line 25
**Fix**: Change text color to use proper theme color

### 4. ❌ Missing Contact Information
**Problem**: Support screen doesn't show contact details
**Required**:
- Email: ronos.icloud@gmail.com
- WhatsApp: +17627702411
- Telegram: @ronospace

---

## Detailed Fix Plan

### Phase 1: Critical Navigation Fixes (High Priority)

#### Fix 1.1: Notification Settings Route
**File**: `lib/features/settings/screens/settings_screen.dart`
**Line**: 119
**Current**: `context.push('/settings/notifications');`
**Status**: ✅ Actually correct - but route path in router is wrong

**File**: `lib/app.dart`
**Line**: 197
**Current**: `path: '/notifications',`
**Fix**: `path: 'notifications',` (remove leading slash for nested route)

#### Fix 1.2: Settings Screen Title Color
**File**: `lib/features/settings/screens/settings_screen.dart`
**Line**: 25-34
**Current**:
```dart
title: const GradientText(
  'Settings',
  gradient: LinearGradient(
    colors: [Colors.white, Color(0xFFE5F0FF)],
  ),
```
**Fix**: Use dark text color or ensure gradient background is visible

### Phase 2: Implement Missing Screens (High Priority)

#### Missing Screen 1: Guided Meditation List Screen
**Create**: `lib/features/meditation/screens/meditation_list_screen.dart`
**Route**: Add to app.dart
```dart
GoRoute(
  path: 'meditation',
  name: 'meditation',
  builder: (context, state) => const MeditationListScreen(),
),
```

#### Missing Screen 2: Scripture Reading Screen
**Create**: `lib/features/scripture/screens/scripture_reading_screen.dart`
**Route**: Add to app.dart
```dart
GoRoute(
  path: 'scripture',
  name: 'scripture',
  builder: (context, state) => const ScriptureReadingScreen(),
),
```

#### Missing Screen 3: Prayer Journal Screen
**Create**: `lib/features/prayer/screens/prayer_journal_screen.dart`
**Route**: Add to app.dart
```dart
GoRoute(
  path: 'prayer-journal',
  name: 'prayer-journal',
  builder: (context, state) => const PrayerJournalScreen(),
),
```

#### Missing Screen 4: Improve Community Screen
**File**: `lib/features/community/screens/community_screen_placeholder.dart`
**Action**: Upgrade from placeholder to functional screen with prayer circles

### Phase 3: Add Support Contact Information (Medium Priority)

#### Fix 3.1: Update Contact Us Handler
**File**: `lib/features/settings/screens/settings_screen.dart`
**Lines**: 212-219
**Current**: `// Navigate to contact`
**Fix**: Implement contact bottom sheet with:
```dart
_showContactOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ContactOptionsSheet(
      email: 'ronos.icloud@gmail.com',
      whatsapp: '+17627702411',
      telegram: '@ronospace',
    ),
  );
}
```

**Create**: `lib/features/settings/widgets/contact_options_sheet.dart`

### Phase 4: Fix Inspiration Screen Navigation (Low Priority)

#### Fix 4.1: Update InspirationScreen Route  
**File**: `lib/app.dart`
**Line**: 185
**Current**: `path: 'inspiration',` (missing leading slash)
**Fix**: `path: '/inspiration',`

---

## Implementation Priority Matrix

| Priority | Feature | Complexity | Impact | Status |
|----------|---------|------------|--------|--------|
| 🔴 P0 | Fix nested route paths | Low | High | Not Started |
| 🔴 P0 | Settings title visibility | Low | High | Not Started |
| 🔴 P0 | Meditation List Screen | Medium | High | Not Started |
| 🟡 P1 | Scripture Reading Screen | Medium | Medium | Not Started |
| 🟡 P1 | Prayer Journal Screen | Medium | Medium | Not Started |
| 🟡 P1 | Contact Support Info | Low | Medium | Not Started |
| 🟢 P2 | Community Screen Upgrade | High | Low | Not Started |
| 🟢 P2 | Inspiration Route Fix | Low | Low | Not Started |

---

## Complete Route Structure (Target State)

```
/
├── /auth
│   ├── /login
│   └── /register
├── /onboarding
│   ├── /spiritual-preferences
│   └── /notification-preferences
├── / (AppShell - Main App)
│   ├── /mood
│   │   ├── /calendar
│   │   └── /entry
│   ├── /prayer (✅ Exists)
│   ├── /prayer-journal (❌ Missing)
│   ├── /meditation (❌ Missing)
│   ├── /scripture (❌ Missing)
│   ├── /chat (✅ Exists)
│   ├── /analytics (✅ Exists)
│   ├── /analytics-dashboard (✅ Exists)
│   ├── /feedback (✅ Exists)
│   ├── /community (⚠️ Placeholder)
│   ├── /crisis-support (✅ Exists)
│   ├── /inspiration (⚠️ Needs fix)
│   └── /settings (✅ Exists)
│       └── notifications (❌ Wrong path)
```

---

## Code Quality Improvements

### Improvement 1: Consistent Route Naming
- **Issue**: Mix of leading slashes in nested routes
- **Fix**: Remove leading slashes from all nested routes
- **Example**: `path: '/notifications'` → `path: 'notifications'`

### Improvement 2: Error Handling
- **Issue**: Generic error screen doesn't provide actionable feedback
- **Fix**: Add specific error types and recovery suggestions

### Improvement 3: Loading States
- **Issue**: No loading indicators during navigation
- **Fix**: Add loading states for async route transitions

---

## Testing Checklist

After implementing fixes, test:

- [ ] Settings → Notification Settings navigation
- [ ] Home → Generate Prayer navigation
- [ ] Home → Guided Meditation navigation (new)
- [ ] Home → Scripture Reading navigation (new)
- [ ] Home → Prayer Journal navigation (new)
- [ ] Home → Community navigation
- [ ] Settings → Contact Us (shows contact sheet)
- [ ] All text is readable on all backgrounds
- [ ] Back navigation works from all screens
- [ ] Error screens show appropriate messages

---

## Contact Integration Specifications

### Email Integration
```dart
Future<void> _launchEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'ronos.icloud@gmail.com',
    query: 'subject=HealPray Support Request',
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  }
}
```

### WhatsApp Integration
```dart
Future<void> _launchWhatsApp() async {
  final Uri whatsappUri = Uri.parse('https://wa.me/17627702411');
  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }
}
```

### Telegram Integration
```dart
Future<void> _launchTelegram() async {
  final Uri telegramUri = Uri.parse('https://t.me/ronospace');
  if (await canLaunchUrl(telegramUri)) {
    await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
  }
}
```

**Required Package**: Add to `pubspec.yaml`:
```yaml
dependencies:
  url_launcher: ^6.2.0
```

---

## Estimated Implementation Time

| Task | Time Estimate |
|------|---------------|
| Route fixes | 30 minutes |
| Settings title fix | 15 minutes |
| Meditation List Screen | 2 hours |
| Scripture Reading Screen | 2 hours |
| Prayer Journal Screen | 2 hours |
| Contact Integration | 1 hour |
| Community Screen upgrade | 4 hours |
| Testing & QA | 2 hours |
| **Total** | **~14 hours** |

---

## Success Criteria

✅ All navigation paths work without errors
✅ All text is visible and readable
✅ Users can contact support via email, WhatsApp, and Telegram
✅ Core features (Prayer, Meditation, Scripture, Journal) are accessible
✅ App passes full navigation test suite
✅ No "Oops! Something went wrong" errors for implemented features

---

## Next Steps

1. ✅ Review this blueprint
2. ⏳ Implement P0 (Critical) fixes first
3. ⏳ Test P0 fixes
4. ⏳ Implement P1 (High) fixes
5. ⏳ Full app testing
6. ⏳ Deploy to staging
7. ⏳ Final QA and production release

---

**Document Version**: 1.0
**Last Updated**: 2025-10-27
**Status**: Ready for Implementation
