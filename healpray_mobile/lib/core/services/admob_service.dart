import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';
import '../utils/logger.dart' as app_logger;

/// AdMob service for managing ads throughout the app
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  /// Initialize AdMob SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      
      // Set request configuration for test mode
      if (AdMobConfig.isTestMode) {
        final configuration = RequestConfiguration(
          testDeviceIds: AdMobConfig.testDeviceIds,
        );
        await MobileAds.instance.updateRequestConfiguration(configuration);
      }

      _isInitialized = true;
      app_logger.AppLogger.info('✅ AdMob initialized successfully');
    } catch (e) {
      app_logger.AppLogger.error('❌ Failed to initialize AdMob: $e');
    }
  }

  /// Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) await initialize();

    await InterstitialAd.load(
      adUnitId: AdMobConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          app_logger.AppLogger.info('📢 Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          app_logger.AppLogger.error('❌ Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      app_logger.AppLogger.warning('⚠️ Interstitial ad not ready');
      await loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        app_logger.AppLogger.error('❌ Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
      },
    );

    await _interstitialAd!.show();
  }

  /// Load rewarded ad
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) await initialize();

    await RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          app_logger.AppLogger.info('🎁 Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          app_logger.AppLogger.error('❌ Rewarded ad failed to load: $error');
        },
      ),
    );
  }

  /// Show rewarded ad with callback
  Future<void> showRewardedAd({
    required Function(int amount, String type) onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) async {
    if (_rewardedAd == null) {
      app_logger.AppLogger.warning('⚠️ Rewarded ad not ready');
      await loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        loadRewardedAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        app_logger.AppLogger.error('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt(), reward.type);
      },
    );
  }

  /// Load app open ad
  Future<void> loadAppOpenAd() async {
    if (!_isInitialized) await initialize();

    await AppOpenAd.load(
      adUnitId: AdMobConfig.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          app_logger.AppLogger.info('🚀 App open ad loaded');
        },
        onAdFailedToLoad: (error) {
          app_logger.AppLogger.error('❌ App open ad failed to load: $error');
        },
      ),
    );
  }

  /// Show app open ad
  Future<void> showAppOpenAd() async {
    if (_appOpenAd == null) {
      app_logger.AppLogger.warning('⚠️ App open ad not ready');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        app_logger.AppLogger.error('❌ App open ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
      },
    );

    await _appOpenAd!.show();
  }

  /// Dispose all ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
