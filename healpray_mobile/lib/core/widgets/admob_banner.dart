import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';
import '../utils/logger.dart' as app_logger;
import 'enhanced_glass_card.dart';

/// AdMob banner widget with Flow AI design integration
class AdMobBanner extends StatefulWidget {
  const AdMobBanner({
    super.key,
    this.adSize = AdSize.banner,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  final AdSize adSize;
  final EdgeInsetsGeometry margin;

  @override
  State<AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<AdMobBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdMobConfig.bannerAdId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
          app_logger.AppLogger.info('📢 Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          app_logger.AppLogger.error('❌ Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return EnhancedGlassCard(
      margin: widget.margin,
      padding: EdgeInsets.zero,
      borderRadius: 12,
      enableShimmer: false,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: widget.adSize.width.toDouble(),
          height: widget.adSize.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
