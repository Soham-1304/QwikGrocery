class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceCents,
    required this.imageUrl,
    required this.description,
    required this.stock,
    this.brand = '',
    this.unit = '',
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String category;
  final int priceCents;
  final String imageUrl;
  final String description;
  final int stock;
  final String brand;
  final String unit;
  final List<String> aliases;

  bool get available => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    priceCents: (json['priceCents'] as num).toInt(),
    imageUrl: (json['imageUrl'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    stock: (json['stock'] as num).toInt(),
    brand: (json['brand'] as String?) ?? '',
    unit: (json['unit'] as String?) ?? '',
    aliases: (json['aliases'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false),
  );
}
