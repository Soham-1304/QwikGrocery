class ScheduledItem {
  const ScheduledItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceCents,
  });
  final String productId, productName;
  final int quantity, unitPriceCents;
  factory ScheduledItem.fromJson(Map<String, dynamic> json) => ScheduledItem(
    productId: json['productId'] as String? ?? '',
    productName: json['productName'] as String? ?? '',
    quantity: (json['quantity'] as num? ?? 1).toInt(),
    unitPriceCents: (json['unitPriceCents'] as num? ?? 0).toInt(),
  );
}

class GrocerySubscription {
  const GrocerySubscription({
    required this.id,
    required this.items,
    required this.frequency,
    required this.startDate,
    required this.deliveryTime,
    required this.active,
    this.address = '',
    this.addressId = '',
    this.nextRunAt,
    this.lastRunStatus,
    this.lastRunError,
  });

  final String id, frequency, deliveryTime, address, addressId;
  final List<ScheduledItem> items;
  final DateTime startDate;
  final DateTime? nextRunAt;
  final String? lastRunStatus, lastRunError;
  final bool active;

  int get estimatedTotalCents => items.fold(
    0,
    (total, item) => total + item.quantity * item.unitPriceCents,
  );

  factory GrocerySubscription.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final items = rawItems != null
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(ScheduledItem.fromJson)
              .toList()
        : [
            ScheduledItem.fromJson({
              'productId': json['productId'],
              'productName': json['productName'],
              'quantity': json['quantity'],
              'unitPriceCents': json['unitPriceCents'],
            }),
          ];
    return GrocerySubscription(
      id: json['id'] as String,
      items: items,
      frequency: json['frequency'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      deliveryTime: json['deliveryTime'] as String,
      active: json['active'] as bool? ?? false,
      address: json['address'] as String? ?? '',
      addressId: json['addressId'] as String? ?? '',
      nextRunAt: DateTime.tryParse(json['nextRunAt'] as String? ?? ''),
      lastRunStatus: json['lastRunStatus'] as String?,
      lastRunError: json['lastRunError'] as String?,
    );
  }
}
