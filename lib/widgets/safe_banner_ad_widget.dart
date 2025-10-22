import 'package:flutter/material.dart';
import '../services/ads_manager_simple.dart';
import '../utils/app_colors.dart';

class SafeBannerAdWidget extends StatefulWidget {
  final double? height;
  final EdgeInsets? margin;
  final bool showShadow;

  const SafeBannerAdWidget({
    super.key,
    this.height,
    this.margin,
    this.showShadow = true,
  });

  @override
  State<SafeBannerAdWidget> createState() => _SafeBannerAdWidgetState();
}

class _SafeBannerAdWidgetState extends State<SafeBannerAdWidget> {
  bool _isAdLoaded = false;
  Widget? _adWidget;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      // Temporarily disable ads to test UI
      print('Safe Banner Ad disabled for testing');
      return;

      // Wait a bit for ads manager to be ready
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        final adWidget = AdsManager.instance.getBannerWidgetSafe();
        if (mounted && adWidget is! SizedBox) {
          setState(() {
            _adWidget = adWidget;
            _isAdLoaded = true;
          });
        }
      }
    } catch (e) {
      print('Safe Banner Ad loading error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _adWidget == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: widget.height ?? 60,
      margin: widget.margin ??
          const EdgeInsets.fromLTRB(16, 0, 16, 160), // 160px above bottom nav
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: _adWidget!,
    );
  }
}
