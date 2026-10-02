class GrocerySubscription {
  const GrocerySubscription({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.frequency,
    required this.startDate,
    required this.deliveryTime,
    required this.active,
  });

  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final String frequency;
  final DateTime startDate;
  final String deliveryTime;
  final bool active;

  factory GrocerySubscription.fromJson(Map<String, dynamic> json) =>
      GrocerySubscription(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        frequency: json['frequency'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        deliveryTime: json['deliveryTime'] as String,
        active: json['active'] as bool,
      );
}
