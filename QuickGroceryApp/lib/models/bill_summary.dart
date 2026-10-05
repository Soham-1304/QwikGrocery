/// Granular bill breakdown including items total, MRP savings, delivery fee,
/// packaging charge, and taxes.
class BillSummary {
  const BillSummary({
    required this.itemTotal,
    required this.mrpTotal,
    required this.mrpSavings,
    required this.deliveryFee,
    required this.packagingCharge,
    required this.taxes,
    required this.total,
    this.freeDeliveryThreshold = 199.0,
    this.amountNeededForFreeDelivery = 0.0,
  });

  final double itemTotal;
  final double mrpTotal;
  final double mrpSavings;
  final double deliveryFee;
  final double packagingCharge;
  final double taxes;
  final double total;
  final double freeDeliveryThreshold;
  final double amountNeededForFreeDelivery;

  bool get hasFreeDelivery => deliveryFee == 0.0;

  factory BillSummary.fromJson(Map<String, dynamic> json) => BillSummary(
    itemTotal: (json['itemTotal'] as num).toDouble(),
    mrpTotal: (json['mrpTotal'] as num).toDouble(),
    mrpSavings: (json['mrpSavings'] as num).toDouble(),
    deliveryFee: (json['deliveryFee'] as num).toDouble(),
    packagingCharge: (json['packagingCharge'] as num).toDouble(),
    taxes: (json['taxes'] as num).toDouble(),
    total: (json['total'] as num).toDouble(),
    freeDeliveryThreshold: (json['freeDeliveryThreshold'] as num?)?.toDouble() ?? 199.0,
    amountNeededForFreeDelivery:
        (json['amountNeededForFreeDelivery'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'itemTotal': itemTotal,
    'mrpTotal': mrpTotal,
    'mrpSavings': mrpSavings,
    'deliveryFee': deliveryFee,
    'packagingCharge': packagingCharge,
    'taxes': taxes,
    'total': total,
    'freeDeliveryThreshold': freeDeliveryThreshold,
    'amountNeededForFreeDelivery': amountNeededForFreeDelivery,
  };
}
