import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IAPService {
  static IAPService? _instance;
  static IAPService get instance => _instance ??= IAPService._();

  IAPService._();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs - Configure these in your app store
  static const String premiumMonthlyId = 'pdf_reader_premium_monthly';
  static const String premiumYearlyId = 'pdf_reader_premium_yearly';
  static const String lifetimeId = 'pdf_reader_lifetime';

  // Premium features
  bool _isPremium = false;
  bool _isLifetime = false;
  DateTime? _premiumExpiry;

  bool get isPremium => _isPremium;
  bool get isLifetime => _isLifetime;
  DateTime? get premiumExpiry => _premiumExpiry;

  Future<void> initialize() async {
    // Check if IAP is available
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      throw Exception('In-app purchases not available');
    }

    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );

    // Restore previous purchases
    await _restorePurchases();
  }

  Future<void> _handlePurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _handleSuccessfulPurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;

    switch (productId) {
      case premiumMonthlyId:
        await _activatePremium(30); // 30 days
        break;
      case premiumYearlyId:
        await _activatePremium(365); // 365 days
        break;
      case lifetimeId:
        await _activateLifetime();
        break;
    }

    // Save purchase to backend
    await _savePurchaseToBackend(purchaseDetails);
  }

  Future<void> _activatePremium(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(Duration(days: days));

    await prefs.setBool('is_premium', true);
    await prefs.setString('premium_expiry', expiryDate.toIso8601String());

    _isPremium = true;
    _premiumExpiry = expiryDate;
  }

  Future<void> _activateLifetime() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_premium', true);
    await prefs.setBool('is_lifetime', true);

    _isPremium = true;
    _isLifetime = true;
  }

  Future<void> _savePurchaseToBackend(PurchaseDetails purchaseDetails) async {
    // Save purchase details to your backend (Supabase)
    // This ensures purchases are synced across devices
    try {
      // Implementation depends on your backend setup
      print('Saving purchase to backend: ${purchaseDetails.productID}');
    } catch (e) {
      print('Failed to save purchase to backend: $e');
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Failed to restore purchases: $e');
    }
  }

  Future<void> loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();

    _isPremium = prefs.getBool('is_premium') ?? false;
    _isLifetime = prefs.getBool('is_lifetime') ?? false;

    if (_isPremium && !_isLifetime) {
      final expiryString = prefs.getString('premium_expiry');
      if (expiryString != null) {
        _premiumExpiry = DateTime.parse(expiryString);

        // Check if premium has expired
        if (_premiumExpiry!.isBefore(DateTime.now())) {
          await _deactivatePremium();
        }
      }
    }
  }

  Future<void> _deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('is_premium', false);
    await prefs.remove('premium_expiry');

    _isPremium = false;
    _premiumExpiry = null;
  }

  Future<List<ProductDetails>> getProducts() async {
    const Set<String> productIds = {
      premiumMonthlyId,
      premiumYearlyId,
      lifetimeId,
    };

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<void> purchaseProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      if (product.id == premiumMonthlyId || product.id == premiumYearlyId) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      print('Purchase failed: $e');
      rethrow;
    }
  }

  void _showPendingUI() {
    // Show loading indicator
    print('Purchase pending...');
  }

  void _handleError(IAPError error) {
    print('Purchase error: ${error.message}');
  }

  // Premium features check
  bool canUsePremiumFeature() {
    return _isPremium;
  }

  bool canUseLifetimeFeature() {
    return _isLifetime;
  }

  // Premium features
  bool canRemoveAds() => _isPremium;
  bool canUseCloudSync() => _isPremium;
  bool canUseAdvancedOCR() => _isPremium;
  bool canUseBatchProcessing() => _isPremium;
  bool canUseCustomThemes() => _isPremium;
  bool canUsePrioritySupport() => _isPremium;

  void dispose() {
    _subscription.cancel();
  }
}

