import 'package:flutter/material.dart';
import '../services/ads_manager_simple.dart';
import '../services/remote_config_service.dart';
import '../utils/app_colors.dart';

class AdsTestScreen extends StatefulWidget {
  const AdsTestScreen({super.key});

  @override
  State<AdsTestScreen> createState() => _AdsTestScreenState();
}

class _AdsTestScreenState extends State<AdsTestScreen> {
  final AdsManager _adsManager = AdsManager.instance;
  final RemoteConfigService _remoteConfig = RemoteConfigService.instance;

  Map<String, dynamic>? _networkAnalysis;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNetworkAnalysis();
  }

  Future<void> _loadNetworkAnalysis() async {
    setState(() => _isLoading = true);
    _networkAnalysis = _adsManager.getNetworkAnalysis();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text('Ads Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNetworkAnalysis,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfigSection(),
                  const SizedBox(height: 20),
                  _buildNetworkAnalysisSection(),
                  const SizedBox(height: 20),
                  _buildAdTestSection(),
                  const SizedBox(height: 20),
                  _buildBannerAdSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildConfigSection() {
    return Card(
      color: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remote Config',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildConfigItem('Ads Enabled', _remoteConfig.adsEnabled),
            _buildConfigItem('Primary Network', _remoteConfig.primaryNetwork),
            _buildConfigItem('Fallback Network', _remoteConfig.fallbackNetwork),
            _buildConfigItem('AdMob Enabled', _remoteConfig.admobEnabled),
            _buildConfigItem('AppLovin Enabled', _remoteConfig.applovinEnabled),
            _buildConfigItem(
                'Banner Frequency', '${_remoteConfig.bannerFrequency}s'),
            _buildConfigItem('Interstitial Frequency',
                '${_remoteConfig.interstitialFrequency}s'),
            _buildConfigItem(
                'Rewarded Cooldown', '${_remoteConfig.rewardedCooldown}s'),
            _buildConfigItem(
                'App Open Delay', '${_remoteConfig.appOpenDelay}s'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: value is bool
                  ? (value ? Colors.green : Colors.red)
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkAnalysisSection() {
    if (_networkAnalysis == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Analysis',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_networkAnalysis!['network_status'] != null)
              _buildNetworkStatusSection(),
            const SizedBox(height: 12),
            if (_networkAnalysis!['network_failures'] != null)
              _buildNetworkFailuresSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusSection() {
    final networkStatus =
        _networkAnalysis!['network_status'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Network Status',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...networkStatus.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: entry.value ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.value ? 'ONLINE' : 'OFFLINE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildNetworkFailuresSection() {
    final networkFailures =
        _networkAnalysis!['network_failures'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Network Failures',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...networkFailures.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key.toUpperCase(),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    '${entry.value} failures',
                    style: TextStyle(
                      color: entry.value > 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAdTestSection() {
    return Card(
      color: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ad Tests',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testInterstitialAd,
                    icon: const Icon(Icons.ads_click),
                    label: const Text('Test Interstitial'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testRewardedAd,
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Test Rewarded'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testAppOpenAd,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Test App Open'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshConfig,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Config'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerAdSection() {
    return Card(
      color: AppColors.darkCard,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Banner Ad',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: _adsManager.getBannerWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testInterstitialAd() async {
    try {
      await _adsManager.showInterstitialAd();
      _showSnackBar('Interstitial ad test completed');
    } catch (e) {
      _showSnackBar('Interstitial ad test failed: $e');
    }
  }

  Future<void> _testRewardedAd() async {
    try {
      final rewardEarned = await _adsManager.showRewardedAd();
      _showSnackBar(rewardEarned
          ? 'Rewarded ad completed - Reward earned!'
          : 'Rewarded ad completed - No reward');
    } catch (e) {
      _showSnackBar('Rewarded ad test failed: $e');
    }
  }

  Future<void> _testAppOpenAd() async {
    try {
      await _adsManager.showAppOpenAd();
      _showSnackBar('App Open ad test completed');
    } catch (e) {
      _showSnackBar('App Open ad test failed: $e');
    }
  }

  Future<void> _refreshConfig() async {
    try {
      await _remoteConfig.refresh();
      _loadNetworkAnalysis();
      _showSnackBar('Remote Config refreshed');
    } catch (e) {
      _showSnackBar('Config refresh failed: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
