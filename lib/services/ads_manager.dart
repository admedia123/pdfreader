import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:applovin_max/applovin_max.dart';  // Temporarily disabled
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

  // AppLovin instances (temporarily disabled)
  // bool _applovinInitialized = false;

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

      // Initialize AppLovin (temporarily disabled)
      // await _initializeAppLovin();

      // Load initial ads
      await _loadInitialAds();

      print('Ads Manager initialized successfully');
    } catch (e) {
      print('Ads Manager initialization failed: $e');
      await _firebase.recordError(e, StackTrace.current,
          reason: 'Ads initialization failed');
    }
  }

  Future<void> _initializeAppLovin() async {
    if (!_remoteConfig.applovinEnabled) return;

    try {
      await AppLovinMAX.initialize(_remoteConfig.applovinSdkKey);
      _applovinInitialized = true;
      print('AppLovin initialized successfully');
    } catch (e) {
      print('AppLovin initialization failed: $e');
      _networkStatus['applovin'] = false;
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
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowBanner()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _remoteConfig.admobEnabled) {
        await _loadAdMobBanner();
      } else if (primaryNetwork == 'applovin' &&
          _remoteConfig.applovinEnabled) {
        await _loadAppLovinBanner();
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

  Future<void> _loadAppLovinBanner() async {
    if (!_applovinInitialized) return;

    await AppLovinMAX.createBanner(
      _remoteConfig.applovinBannerId,
      AdViewPosition.bottomCenter,
    );

    AppLovinMAX.setBannerListener((adInfo) {
      if (adInfo.waterfall?.name == 'loaded') {
        print('AppLovin Banner loaded successfully');
        _networkStatus['applovin'] = true;
      } else if (adInfo.waterfall?.name == 'failed') {
        print('AppLovin Banner failed to load');
        _networkStatus['applovin'] = false;
        _handleAdFailure('applovin', Exception('Banner load failed'));
      }
    });
  }

  Widget getBannerWidget() {
    if (!_remoteConfig.adsEnabled) return const SizedBox.shrink();
    if (!_canShowBanner()) return const SizedBox.shrink();

    final primaryNetwork = _remoteConfig.primaryNetwork;

    if (primaryNetwork == 'admob' && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else if (primaryNetwork == 'applovin' && _applovinInitialized) {
      return AppLovinMAX.getBannerWidget(_remoteConfig.applovinBannerId);
    }

    return const SizedBox.shrink();
  }

  // ==================== INTERSTITIAL ADS ====================

  Future<void> loadInterstitialAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowInterstitial()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _remoteConfig.admobEnabled) {
        await _loadAdMobInterstitial();
      } else if (primaryNetwork == 'applovin' &&
          _remoteConfig.applovinEnabled) {
        await _loadAppLovinInterstitial();
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

  Future<void> _loadAppLovinInterstitial() async {
    if (!_applovinInitialized) return;

    await AppLovinMAX.loadInterstitial(_remoteConfig.applovinInterstitialId);

    AppLovinMAX.setInterstitialListener((adInfo) {
      if (adInfo.waterfall?.name == 'loaded') {
        print('AppLovin Interstitial loaded successfully');
        _networkStatus['applovin'] = true;
      } else if (adInfo.waterfall?.name == 'failed') {
        print('AppLovin Interstitial failed to load');
        _networkStatus['applovin'] = false;
        _handleAdFailure('applovin', Exception('Interstitial load failed'));
      }
    });
  }

  Future<void> showInterstitialAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowInterstitial()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _interstitialAd != null) {
        await _interstitialAd!.show();
      } else if (primaryNetwork == 'applovin' && _applovinInitialized) {
        await AppLovinMAX.showInterstitial(
            _remoteConfig.applovinInterstitialId);
        _lastInterstitialShown = DateTime.now();
        _firebase.logEvent('interstitial_shown', parameters: {
          'network': 'applovin',
          'ad_unit_id': _remoteConfig.applovinInterstitialId,
        });
      }
    } catch (e) {
      print('Interstitial ad showing failed: $e');
      await _handleAdFailure('interstitial', e);
    }
  }

  // ==================== REWARDED ADS ====================

  Future<void> loadRewardedAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowRewarded()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _remoteConfig.admobEnabled) {
        await _loadAdMobRewarded();
      } else if (primaryNetwork == 'applovin' &&
          _remoteConfig.applovinEnabled) {
        await _loadAppLovinRewarded();
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

  Future<void> _loadAppLovinRewarded() async {
    if (!_applovinInitialized) return;

    await AppLovinMAX.loadRewardedAd(_remoteConfig.applovinRewardedId);

    AppLovinMAX.setRewardedAdListener((adInfo) {
      if (adInfo.waterfall?.name == 'loaded') {
        print('AppLovin Rewarded loaded successfully');
        _networkStatus['applovin'] = true;
      } else if (adInfo.waterfall?.name == 'failed') {
        print('AppLovin Rewarded failed to load');
        _networkStatus['applovin'] = false;
        _handleAdFailure('applovin', Exception('Rewarded load failed'));
      }
    });
  }

  Future<bool> showRewardedAd() async {
    if (!_remoteConfig.adsEnabled) return false;
    if (!_canShowRewarded()) return false;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _rewardedAd != null) {
        return await _showAdMobRewarded();
      } else if (primaryNetwork == 'applovin' && _applovinInitialized) {
        return await _showAppLovinRewarded();
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

  Future<bool> _showAppLovinRewarded() async {
    bool rewardEarned = false;

    AppLovinMAX.setRewardedAdListener((adInfo) {
      if (adInfo.waterfall?.name == 'rewarded') {
        rewardEarned = true;
        _lastRewardedShown = DateTime.now();
        _firebase.logEvent('rewarded_completed', parameters: {
          'network': 'applovin',
          'reward_amount': adInfo.reward?.amount ?? 0,
          'reward_type': adInfo.reward?.label ?? 'unknown',
        });
      }
    });

    await AppLovinMAX.showRewardedAd(_remoteConfig.applovinRewardedId);
    return rewardEarned;
  }

  // ==================== APP OPEN ADS ====================

  Future<void> loadAppOpenAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowAppOpen()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _remoteConfig.admobEnabled) {
        await _loadAdMobAppOpen();
      } else if (primaryNetwork == 'applovin' &&
          _remoteConfig.applovinEnabled) {
        await _loadAppLovinAppOpen();
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

  Future<void> _loadAppLovinAppOpen() async {
    if (!_applovinInitialized) return;

    await AppLovinMAX.loadAppOpenAd(_remoteConfig.applovinAppOpenId);

    AppLovinMAX.setAppOpenAdListener((adInfo) {
      if (adInfo.waterfall?.name == 'loaded') {
        print('AppLovin App Open loaded successfully');
        _networkStatus['applovin'] = true;
      } else if (adInfo.waterfall?.name == 'failed') {
        print('AppLovin App Open failed to load');
        _networkStatus['applovin'] = false;
        _handleAdFailure('applovin', Exception('App Open load failed'));
      }
    });
  }

  Future<void> showAppOpenAd() async {
    if (!_remoteConfig.adsEnabled) return;
    if (!_canShowAppOpen()) return;

    try {
      final primaryNetwork = _remoteConfig.primaryNetwork;

      if (primaryNetwork == 'admob' && _appOpenAd != null) {
        await _appOpenAd!.show();
        _lastAppOpenShown = DateTime.now();
        _firebase.logEvent('app_open_shown', parameters: {
          'network': 'admob',
          'ad_unit_id': _remoteConfig.admobAppOpenId,
        });
      } else if (primaryNetwork == 'applovin' && _applovinInitialized) {
        await AppLovinMAX.showAppOpenAd(_remoteConfig.applovinAppOpenId);
        _lastAppOpenShown = DateTime.now();
        _firebase.logEvent('app_open_shown', parameters: {
          'network': 'applovin',
          'ad_unit_id': _remoteConfig.applovinAppOpenId,
        });
      }
    } catch (e) {
      print('App Open ad showing failed: $e');
      await _handleAdFailure('app_open', e);
    }
  }

  // ==================== TIMING CONTROL ====================

  bool _canShowBanner() {
    if (_lastBannerShown == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastBannerShown!).inSeconds;
    return difference >= _remoteConfig.bannerFrequency;
  }

  bool _canShowInterstitial() {
    if (_lastInterstitialShown == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastInterstitialShown!).inSeconds;
    return difference >= _remoteConfig.interstitialFrequency;
  }

  bool _canShowRewarded() {
    if (_lastRewardedShown == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastRewardedShown!).inSeconds;
    return difference >= _remoteConfig.rewardedCooldown;
  }

  bool _canShowAppOpen() {
    if (_lastAppOpenShown == null) return true;
    final now = DateTime.now();
    final difference = now.difference(_lastAppOpenShown!).inSeconds;
    return difference >= _remoteConfig.appOpenDelay;
  }

  // ==================== NETWORK ANALYSIS ====================

  Future<void> _handleAdFailure(String adType, dynamic error) async {
    final network = _getNetworkFromAdType(adType);
    _networkFailures[network] = (_networkFailures[network] ?? 0) + 1;
    _networkStatus[network] = false;

    await _firebase.logEvent('ad_failed', parameters: {
      'ad_type': adType,
      'network': network,
      'error': error.toString(),
      'failure_count': _networkFailures[network] ?? 0,
    });

    // Try fallback network if primary fails
    if (_networkFailures[network]! > _remoteConfig.networkRetryCount) {
      await _tryFallbackNetwork(adType);
    }
  }

  String _getNetworkFromAdType(String adType) {
    final primaryNetwork = _remoteConfig.primaryNetwork;
    return primaryNetwork;
  }

  Future<void> _tryFallbackNetwork(String adType) async {
    final fallbackNetwork = _remoteConfig.fallbackNetwork;
    print('Trying fallback network: $fallbackNetwork for $adType');

    // Reset failure count for primary network
    final primaryNetwork = _remoteConfig.primaryNetwork;
    _networkFailures[primaryNetwork] = 0;

    // Load ad with fallback network
    switch (adType) {
      case 'banner':
        await loadBannerAd();
        break;
      case 'interstitial':
        await loadInterstitialAd();
        break;
      case 'rewarded':
        await loadRewardedAd();
        break;
      case 'app_open':
        await loadAppOpenAd();
        break;
    }
  }

  // ==================== ANALYTICS ====================

  Map<String, dynamic> getNetworkAnalysis() {
    return {
      'network_status': _networkStatus,
      'network_failures': _networkFailures,
      'primary_network': _remoteConfig.primaryNetwork,
      'fallback_network': _remoteConfig.fallbackNetwork,
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

    if (_applovinInitialized) {
      AppLovinMAX.destroyBanner(_remoteConfig.applovinBannerId);
    }
  }
}
