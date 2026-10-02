class GroceryOrder {
  const GroceryOrder({
    required this.id,
    required this.status,
    required this.totalCents,
    required this.createdAt,
    required this.address,
    required this.items,
  });

  final String id;
  final String status;
  final int totalCents;
  final DateTime createdAt;
  final String address;
  final List<Map<String, dynamic>> items;

  factory GroceryOrder.fromJson(Map<String, dynamic> json) => GroceryOrder(
    id: json['id'] as String,
    status: json['status'] as String,
    totalCents: (json['totalCents'] as num).toInt(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    address: json['address'] as String,
    items: (json['items'] as List).cast<Map<String, dynamic>>(),
  );
}
