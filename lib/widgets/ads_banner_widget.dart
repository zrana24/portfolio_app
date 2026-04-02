import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_services.dart';

class AdsBannerWidget extends StatefulWidget {
  final Function(bool)? onAdLoadStateChanged;
  final bool alwaysShow;

  const AdsBannerWidget({
    Key? key,
    this.onAdLoadStateChanged,
    this.alwaysShow = true,
  }) : super(key: key);

  @override
  State<AdsBannerWidget> createState() => _AdsBannerWidgetState();
}

class _AdsBannerWidgetState extends State<AdsBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();

    // _startAutoRefresh();
  }

  /*void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        _refreshAd();
      }
    });
  }

  void _refreshAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    setState(() {
      _isLoaded = false;
    });
    _loadAd();
  }*/

  void _loadAd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final size = MediaQuery.of(context).size;

      AdSize adSize = AdSize.banner;
      if (size.width >= 728) {
        adSize = AdSize.leaderboard;
      } else if (size.width >= 468) {
        adSize = AdSize.fullBanner;
      } else if (size.width >= 320) {
        adSize = AdSize.banner;
      }

      _bannerAd = BannerAd(
        adUnitId: AdsService.bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner reklam yüklendi!');
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
              widget.onAdLoadStateChanged?.call(true);
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner reklam yüklenemedi: $error');
            ad.dispose();
            if (mounted) {
              setState(() {
                _isLoaded = false;
              });
              widget.onAdLoadStateChanged?.call(false);
            }
          },
          onAdOpened: (ad) {
            debugPrint('Banner reklam açıldı');
          },
          onAdClosed: (ad) {
            debugPrint('Banner reklam kapandı');
          },
          onAdImpression: (ad) {
            debugPrint('Banner reklam gösterimi kaydedildi');
          },
        ),
      );

      _bannerAd!.load();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_bannerAd != null && _isLoaded) {
      return Container(
        width: size.width,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.01,
        ),
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}