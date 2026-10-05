class AppConstants {
  const AppConstants._();

  static const String appName = 'QwikGrocery';
  static const String deliveryEtaText = '⚡ Delivery in 10-15 mins';

  // Free delivery threshold in rupees & cents
  static const double freeDeliveryThreshold = 199.0;
  static const int freeDeliveryThresholdCents = 19900;

  // Standard delivery fee when below threshold
  static const double standardDeliveryFee = 25.0;
  static const int standardDeliveryFeeCents = 2500;

  // Fixed packaging and handling charge
  static const double packagingCharge = 10.0;
  static const int packagingChargeCents = 1000;

  // Applicable taxes rate (5%)
  static const double taxRate = 0.05;

  // Default product freshness & quality guarantee tags
  static const List<String> defaultFreshnessBadges = [
    '100% Quality Guarantee',
    'Direct from Farm',
    'Cold Chain Maintained',
  ];
}
