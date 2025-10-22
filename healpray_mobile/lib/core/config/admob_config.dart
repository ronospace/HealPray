import 'dart:io';

/// AdMob configuration for HealPray app
class AdMobConfig {
  // iOS App ID
  static const String iosAppId = 'ca-app-pub-8707491489514576~3053779336';
  
  // Android App ID  
  static const String androidAppId = 'ca-app-pub-8707491489514576~5064344089';

  // iOS Ad Unit IDs
  static const String iosAppOpenAdId = 'ca-app-pub-8707491489514576/7498939737';
  static const String iosBannerAdId = 'ca-app-pub-8707491489514576/9591267529';
  static const String iosInterstitialAdId = 'ca-app-pub-8707491489514576/8812021403';
  static const String iosNativeAdvancedAdId = 'ca-app-pub-8707491489514576/2837639998';
  static const String iosRewardedAdId = 'ca-app-pub-8707491489514576/7894240148';
  static const String iosRewardedInterstitialAdId = 'ca-app-pub-8707491489514576/8114534323';

  // Android Ad Unit IDs
  static const String androidAppOpenAdId = 'ca-app-pub-8707491489514576/1932269355';
  static const String androidBannerAdId = 'ca-app-pub-8707491489514576/4140566820';
  static const String androidInterstitialAdId = 'ca-app-pub-8707491489514576/4558432692';
  static const String androidNativeAdvancedAdId = 'ca-app-pub-8707491489514576/3244335102';
  static const String androidRewardedAdId = 'ca-app-pub-8707491489514576/2833485150';
  static const String androidRewardedInterstitialAdId = 'ca-app-pub-8707491489514576/2281586612';

  // Get platform-specific App ID
  static String get appId {
    if (Platform.isIOS) {
      return iosAppId;
    } else if (Platform.isAndroid) {
      return androidAppId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  // Get platform-specific ad unit IDs
  static String get appOpenAdId => Platform.isIOS ? iosAppOpenAdId : androidAppOpenAdId;
  static String get bannerAdId => Platform.isIOS ? iosBannerAdId : androidBannerAdId;
  static String get interstitialAdId => Platform.isIOS ? iosInterstitialAdId : androidInterstitialAdId;
  static String get nativeAdvancedAdId => Platform.isIOS ? iosNativeAdvancedAdId : androidNativeAdvancedAdId;
  static String get rewardedAdId => Platform.isIOS ? iosRewardedAdId : androidRewardedAdId;
  static String get rewardedInterstitialAdId => Platform.isIOS ? iosRewardedInterstitialAdId : androidRewardedInterstitialAdId;

  // Test mode flag
  static const bool isTestMode = true; // Set to false for production

  // Test device IDs (for development)
  static const List<String> testDeviceIds = [
    // Add your test device IDs here
  ];
}
