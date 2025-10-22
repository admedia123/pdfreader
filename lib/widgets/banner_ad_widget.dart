import 'package:flutter/material.dart';
import '../services/ads_manager_simple.dart';
import '../utils/app_colors.dart';

class BannerAdWidget extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;
  final bool showShadow;

  const BannerAdWidget({
    super.key,
    this.height,
    this.margin,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 60,
      margin: margin ??
          const EdgeInsets.fromLTRB(
              16, 0, 16, 160), // 160px above bottom nav to avoid + button
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
      ),
      child: AdsManager.instance.getBannerWidgetSafe(),
    );
  }
}
