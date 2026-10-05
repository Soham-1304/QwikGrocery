class GroceryOrder {
  const GroceryOrder({
    required this.id,
    required this.status,
    required this.totalCents,
    required this.createdAt,
    required this.address,
    required this.items,
    this.delivery,
    this.deliveryLocation,
    this.customerName = '',
    this.phone = '',
    this.subtotalCents,
    this.payment,
  });

  final String id;
  final String status;
  final int totalCents;
  final DateTime createdAt;
  final String address;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? delivery;
  final Map<String, dynamic>? deliveryLocation;
  final String customerName;
  final String phone;
  final int? subtotalCents;
  final Map<String, dynamic>? payment;

  bool get isComplete => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get isInProgress => !isComplete && !isCancelled;

  String get itemsSummary {
    if (items.isEmpty) return 'Grocery items';
    return items.map((i) {
      final qty = i['quantity'] ?? 1;
      final name = i['name'] ?? i['productName'] ?? 'Item';
      return '$qty × $name';
    }).join(', ');
  }

  int get totalItemQuantity =>
      items.fold(0, (sum, i) => sum + ((i['quantity'] as num?)?.toInt() ?? 1));

  factory GroceryOrder.fromJson(Map<String, dynamic> json) => GroceryOrder(
    id: json['id'] as String,
    status: json['status'] as String,
    totalCents: (json['totalCents'] as num).toInt(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    address: json['address'] as String? ?? '',
    items: (json['items'] as List? ?? []).cast<Map<String, dynamic>>(),
    delivery: json['delivery'] as Map<String, dynamic>?,
    deliveryLocation: json['deliveryLocation'] as Map<String, dynamic>?,
    customerName: json['customerName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    subtotalCents: (json['subtotalCents'] as num?)?.toInt(),
    payment: json['payment'] as Map<String, dynamic>?,
  );
}
