import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'remote_config_service.dart';
import 'firebase_service.dart';

class AdsManager {
  static AdsManager? _instance;
  static AdsManager get instance => _instance ??= AdsManager._();

  AdsManager._();

  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;
  final FirebaseService _firebase = FirebaseService.instance;

  // AdMob instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  // Timing control
  DateTime? _lastBannerShown;
  DateTime? _lastInterstitialShown;
  DateTime? _lastRewardedShown;
  DateTime? _lastAppOpenShown;

  // Network analysis
  Map<String, bool> _networkStatus = {};
  Map<String, int> _networkFailures = {};

  Future<void> initialize() async {
    try {
      // Initialize AdMob
      await MobileAds.instance.initialize();

      // Load initial ads
      await _loadInitialAds();

      print('Ads Manager initialized successfully');
    } catch (e) {
      print('Ads Manager initialization failed: $e');
      await _firebase.recordError(e, StackTrace.current,
          reason: 'Ads initialization failed');
    }
  }

  Future<void> _loadInitialAds() async {
    if (!_remoteConfig.adsEnabled) return;

    // Load banner ad
    await loadBannerAd();

    // Load interstitial ad
    await loadInterstitialAd();

    // Load rewarded ad
    await loadRewardedAd();

    // Load app open ad
    await loadAppOpenAd();
  }

  // ==================== BANNER ADS ====================

  Future<void> loadBannerAd() async {
    try {
      if (!_remoteConfig.adsEnabled) return;
      if (!_canShowBanner()) return;

      if (_remoteConfig.admobEnabled) {
        await _loadAdMobBanner();
      }
    } catch (e) {
      print('Banner ad loading failed: $e');
      await _handleAdFailure('banner', e);
    }
  }

  Future<void> _loadAdMobBanner() async {
    _bannerAd = BannerAd(
      adUnitId: _remoteConfig.admobBannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('AdMob Banner loaded successfully');
          _networkStatus['admob'] = true;
        },
        onAdFailedToLoad: (ad, error) {
          print('AdMob Banner failed to load: $error');
          _networkStatus['admob'] = false;
          _handleAdFailure('admob', error);
        },
      ),
    );
    await _bannerAd!.load();
  }

  Widget getBannerWidget() {
    if (!_remoteConfig.adsEnabled) return const SizedBox.shrink();
    if (!_canShowBanner()) return const SizedBox.shrink();

    if (_bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return const SizedBox.shrink();
  }

  // Create a singleton banner widget to avoid duplicate AdWidget
  Widget? _bannerWidget;
  bool _bannerWidgetCreated = false;

  Widget getBannerWidgetSafe() {
    try {
      // Check if RemoteConfig is initialized
      if (!_remoteConfig.adsEnabled) return const SizedBox.shrink();
      if (!_canShowBanner()) return const SizedBox.shrink();

      // Only create widget once to avoid duplicate
      if (_bannerAd != null && !_bannerWidgetCreated) {
        _bannerWidget = SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        );
        _bannerWidgetCreated = true;
      }

      return _bannerWidget ?? const SizedBox.shrink();
    } catch (e) {
      print('Banner ad error: $e');
      return const SizedBox.shrink();
    }
  }

  // Reset banner widget when ad is disposed
  void _resetBannerWidget() {
    _bannerWidget = null;
    _bannerWidgetCreated = false;
  }

  // ==================== INTERSTITIAL ADS ====================

  Future<void> loadInterstitialAd() async {
    try {
      if (!_remoteConfig.adsEnabled) return;
      if (!_canShowInterstitial()) return;

      if (_remoteConfig.admobEnabled) {
        await _loadAdMobInterstitial();
      }
    } catch (e) {
      print('Interstitial ad loading failed: $e');
      await _handleAdFailure('interstitial', e);
    }
  }

  Future<void> _loadAdMobInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _remoteConfig.admobInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              _lastInterstitialShown = DateTime.now();
              _firebase.logEvent('interstitial_shown', parameters: {
                'network': 'admob',
                'ad_unit_id': _remoteConfig.admobInterstitialId,
              });
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              // Load next interstitial
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _handleAdFailure('admob', error);
            },
          );
          print('AdMob Interstitial loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('AdMob Interstitial failed to load: $error');
          _handleAdFailure('admob', error);
        },
      ),
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowInterstitial()) return;

    try {
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
      }
    } catch (e) {
      print('Interstitial ad showing failed: $e');
      await _handleAdFailure('interstitial', e);
    }
  }

  // ==================== REWARDED ADS ====================

  Future<void> loadRewardedAd() async {
    try {
      if (!_remoteConfig.adsEnabled) return;
      if (!_canShowRewarded()) return;

      if (_remoteConfig.admobEnabled) {
        await _loadAdMobRewarded();
      }
    } catch (e) {
      print('Rewarded ad loading failed: $e');
      await _handleAdFailure('rewarded', e);
    }
  }

  Future<void> _loadAdMobRewarded() async {
    await RewardedAd.load(
      adUnitId: _remoteConfig.admobRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          print('AdMob Rewarded loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('AdMob Rewarded failed to load: $error');
          _handleAdFailure('admob', error);
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (!_remoteConfig.adsEnabled) return false;
    if (!_canShowRewarded()) return false;

    try {
      if (_rewardedAd != null) {
        return await _showAdMobRewarded();
      }
    } catch (e) {
      print('Rewarded ad showing failed: $e');
      await _handleAdFailure('rewarded', e);
    }

    return false;
  }

  Future<bool> _showAdMobRewarded() async {
    bool rewardEarned = false;

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        _lastRewardedShown = DateTime.now();
        _firebase.logEvent('rewarded_completed', parameters: {
          'network': 'admob',
          'reward_amount': reward.amount,
          'reward_type': reward.type,
        });
      },
    );

    _rewardedAd!.dispose();
    _rewardedAd = null;
    loadRewardedAd(); // Load next rewarded ad

    return rewardEarned;
  }

  // ==================== APP OPEN ADS ====================

  Future<void> loadAppOpenAd() async {
    try {
      if (!_remoteConfig.adsEnabled) return;
      if (!_canShowAppOpen()) return;

      if (_remoteConfig.admobEnabled) {
        await _loadAdMobAppOpen();
      }
    } catch (e) {
      print('App Open ad loading failed: $e');
      await _handleAdFailure('app_open', e);
    }
  }

  Future<void> _loadAdMobAppOpen() async {
    await AppOpenAd.load(
      adUnitId: _remoteConfig.admobAppOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          print('AdMob App Open loaded successfully');
        },
        onAdFailedToLoad: (error) {
          print('AdMob App Open failed to load: $error');
          _handleAdFailure('admob', error);
        },
      ),
    );
  }

  Future<void> showAppOpenAd() async {
    try {
      if (!_remoteConfig.adsEnabled) return;
      if (!_canShowAppOpen()) return;

      if (_appOpenAd != null) {
        await _appOpenAd!.show();
        _lastAppOpenShown = DateTime.now();
        _firebase.logEvent('app_open_shown', parameters: {
          'network': 'admob',
          'ad_unit_id': _remoteConfig.admobAppOpenId,
        });
      }
    } catch (e) {
      print('App Open ad showing failed: $e');
      await _handleAdFailure('app_open', e);
    }
  }

  // ==================== TIMING CONTROL ====================

  bool _canShowBanner() {
    try {
      if (_lastBannerShown == null) return true;
      final now = DateTime.now();
      final difference = now.difference(_lastBannerShown!).inSeconds;
      return difference >= _remoteConfig.bannerFrequency;
    } catch (e) {
      print('Banner timing error: $e');
      return true; // Allow showing if error
    }
  }

  bool _canShowInterstitial() {
    try {
      if (_lastInterstitialShown == null) return true;
      final now = DateTime.now();
      final difference = now.difference(_lastInterstitialShown!).inSeconds;
      return difference >= _remoteConfig.interstitialFrequency;
    } catch (e) {
      print('Interstitial timing error: $e');
      return true; // Allow showing if error
    }
  }

  bool _canShowRewarded() {
    try {
      if (_lastRewardedShown == null) return true;
      final now = DateTime.now();
      final difference = now.difference(_lastRewardedShown!).inSeconds;
      return difference >= _remoteConfig.rewardedCooldown;
    } catch (e) {
      print('Rewarded timing error: $e');
      return true; // Allow showing if error
    }
  }

  bool _canShowAppOpen() {
    try {
      if (_lastAppOpenShown == null) return true;
      final now = DateTime.now();
      final difference = now.difference(_lastAppOpenShown!).inSeconds;
      return difference >= _remoteConfig.appOpenDelay;
    } catch (e) {
      print('App Open timing error: $e');
      return true; // Allow showing if error
    }
  }

  // ==================== NETWORK ANALYSIS ====================

  Future<void> _handleAdFailure(String adType, dynamic error) async {
    _networkFailures['admob'] = (_networkFailures['admob'] ?? 0) + 1;
    _networkStatus['admob'] = false;

    await _firebase.logEvent('ad_failed', parameters: {
      'ad_type': adType,
      'network': 'admob',
      'error': error.toString(),
      'failure_count': _networkFailures['admob'] ?? 0,
    });
  }

  // ==================== ANALYTICS ====================

  Map<String, dynamic> getNetworkAnalysis() {
    return {
      'network_status': _networkStatus,
      'network_failures': _networkFailures,
      'primary_network': 'admob',
      'fallback_network': 'admob',
      'ads_enabled': _remoteConfig.adsEnabled,
      'last_banner_shown': _lastBannerShown?.toIso8601String(),
      'last_interstitial_shown': _lastInterstitialShown?.toIso8601String(),
      'last_rewarded_shown': _lastRewardedShown?.toIso8601String(),
      'last_app_open_shown': _lastAppOpenShown?.toIso8601String(),
    };
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
