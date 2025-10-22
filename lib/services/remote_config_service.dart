import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  RemoteConfigService._();

  late FirebaseRemoteConfig _remoteConfig;

  // Default values for ads configuration
  static const Map<String, dynamic> _defaultValues = {
    // Global ads control
    'ads_enabled': true,
    'ads_network_priority': 'admob,applovin', // Priority order

    // AdMob Configuration
    'admob_enabled': true,
    'admob_banner_id': 'ca-app-pub-3940256099942544/6300978111', // Test banner
    'admob_interstitial_id':
        'ca-app-pub-3940256099942544/1033173712', // Test interstitial
    'admob_rewarded_id':
        'ca-app-pub-3940256099942544/5224354917', // Test rewarded
    'admob_app_open_id':
        'ca-app-pub-3940256099942544/3419835294', // Test app open

    // AppLovin Configuration
    'applovin_enabled': true,
    'applovin_sdk_key': 'YOUR_APPLOVIN_SDK_KEY',
    'applovin_banner_id': 'YOUR_APPLOVIN_BANNER_ID',
    'applovin_interstitial_id': 'YOUR_APPLOVIN_INTERSTITIAL_ID',
    'applovin_rewarded_id': 'YOUR_APPLOVIN_REWARDED_ID',
    'applovin_app_open_id': 'YOUR_APPLOVIN_APP_OPEN_ID',

    // Ads frequency and timing
    'banner_frequency': 30, // seconds
    'interstitial_frequency': 60, // seconds
    'rewarded_cooldown': 300, // seconds
    'app_open_delay': 5, // seconds after app launch

    // Network analysis
    'network_analysis_enabled': true,
    'network_timeout': 10, // seconds
    'network_retry_count': 3,
  };

  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig.setDefaults(_defaultValues);

      // Set cache expiration
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();

      print('Remote Config initialized successfully');
    } catch (e) {
      print('Remote Config initialization failed: $e');
      // Use default values if fetch fails
    }
  }

  // Global ads control
  bool get adsEnabled => _remoteConfig.getBool('ads_enabled');
  String get adsNetworkPriority =>
      _remoteConfig.getString('ads_network_priority');

  // AdMob configuration
  bool get admobEnabled => _remoteConfig.getBool('admob_enabled');
  String get admobBannerId => _remoteConfig.getString('admob_banner_id');
  String get admobInterstitialId =>
      _remoteConfig.getString('admob_interstitial_id');
  String get admobRewardedId => _remoteConfig.getString('admob_rewarded_id');
  String get admobAppOpenId => _remoteConfig.getString('admob_app_open_id');

  // AppLovin configuration
  bool get applovinEnabled => _remoteConfig.getBool('applovin_enabled');
  String get applovinSdkKey => _remoteConfig.getString('applovin_sdk_key');
  String get applovinBannerId => _remoteConfig.getString('applovin_banner_id');
  String get applovinInterstitialId =>
      _remoteConfig.getString('applovin_interstitial_id');
  String get applovinRewardedId =>
      _remoteConfig.getString('applovin_rewarded_id');
  String get applovinAppOpenId =>
      _remoteConfig.getString('applovin_app_open_id');

  // Ads timing
  int get bannerFrequency => _remoteConfig.getInt('banner_frequency');
  int get interstitialFrequency =>
      _remoteConfig.getInt('interstitial_frequency');
  int get rewardedCooldown => _remoteConfig.getInt('rewarded_cooldown');
  int get appOpenDelay => _remoteConfig.getInt('app_open_delay');

  // Network analysis
  bool get networkAnalysisEnabled =>
      _remoteConfig.getBool('network_analysis_enabled');
  int get networkTimeout => _remoteConfig.getInt('network_timeout');
  int get networkRetryCount => _remoteConfig.getInt('network_retry_count');

  // Get current network priority
  List<String> get networkPriorityList {
    final priority = adsNetworkPriority.split(',');
    return priority.map((e) => e.trim()).toList();
  }

  // Check if specific network is enabled
  bool isNetworkEnabled(String network) {
    switch (network.toLowerCase()) {
      case 'admob':
        return admobEnabled;
      case 'applovin':
        return applovinEnabled;
      default:
        return false;
    }
  }

  // Get primary network (first in priority list)
  String get primaryNetwork {
    final priority = networkPriorityList;
    for (String network in priority) {
      if (isNetworkEnabled(network)) {
        return network;
      }
    }
    return 'admob'; // fallback
  }

  // Get fallback network (second in priority list)
  String get fallbackNetwork {
    final priority = networkPriorityList;
    if (priority.length > 1) {
      for (int i = 1; i < priority.length; i++) {
        if (isNetworkEnabled(priority[i])) {
          return priority[i];
        }
      }
    }
    return 'admob'; // fallback
  }

  // Force refresh config
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      print('Remote Config refreshed successfully');
    } catch (e) {
      print('Remote Config refresh failed: $e');
    }
  }

  // Get all config values for debugging
  Map<String, dynamic> getAllValues() {
    return {
      'ads_enabled': adsEnabled,
      'ads_network_priority': adsNetworkPriority,
      'admob_enabled': admobEnabled,
      'applovin_enabled': applovinEnabled,
      'primary_network': primaryNetwork,
      'fallback_network': fallbackNetwork,
      'banner_frequency': bannerFrequency,
      'interstitial_frequency': interstitialFrequency,
      'rewarded_cooldown': rewardedCooldown,
      'app_open_delay': appOpenDelay,
      'network_analysis_enabled': networkAnalysisEnabled,
    };
  }
}
