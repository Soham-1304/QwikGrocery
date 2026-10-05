/// Enriched product entity supporting Blinkit-style catalog features.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.priceCents,
    required this.imageUrl,
    required this.description,
    required this.stock,
    this.mrpCents,
    this.brand = '',
    this.unit = '',
    this.packUnit = '',
    this.images = const [],
    this.aliases = const [],
    this.freshnessBadges = const [],
    this.nutritionalInfo = const {},
    this.storageInstructions = '',
    this.rating = 4.8,
    this.ratingCount = 120,
  });

  final String id;
  final String name;
  final String category;
  final int priceCents;
  final int? mrpCents;
  final String imageUrl;
  final List<String> images;
  final String description;
  final int stock;
  final String brand;
  final String unit;
  final String packUnit;
  final List<String> aliases;
  final List<String> freshnessBadges;
  final Map<String, String> nutritionalInfo;
  final String storageInstructions;
  final double rating;
  final int ratingCount;

  bool get available => stock > 0;
  int get effectiveMrpCents =>
      (mrpCents != null && mrpCents! > 0) ? mrpCents! : priceCents;
  double get price => priceCents / 100.0;
  double get mrp => effectiveMrpCents / 100.0;
  int get savingsCents =>
      (effectiveMrpCents - priceCents).clamp(0, effectiveMrpCents);
  double get savings => savingsCents / 100.0;
  bool get hasDiscount => effectiveMrpCents > priceCents;

  int get discountPercentage {
    if (!hasDiscount || effectiveMrpCents <= 0) return 0;
    return (((effectiveMrpCents - priceCents) / effectiveMrpCents) * 100).round();
  }

  String get displayUnit =>
      packUnit.isNotEmpty ? packUnit : (unit.isNotEmpty ? unit : '1 pc');

  List<String> get allImages {
    if (images.isNotEmpty) return images;
    if (imageUrl.isNotEmpty) return [imageUrl];
    return const [];
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawMrp = json['mrpCents'] ?? json['mrp_cents'] ?? json['mrp'];
    final int? parsedMrp = rawMrp != null
        ? (rawMrp is num ? rawMrp.toInt() : int.tryParse(rawMrp.toString()))
        : null;
    final rawImages = json['images'] as List<dynamic>?;
    final rawFreshness = json['freshnessBadges'] as List<dynamic>? ??
        json['freshness_badges'] as List<dynamic>?;
    final rawNutrition = json['nutritionalInfo'] as Map<dynamic, dynamic>? ??
        json['nutritional_info'] as Map<dynamic, dynamic>?;

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      mrpCents: parsedMrp,
      imageUrl: (json['imageUrl'] as String?) ?? '',
      images: rawImages?.whereType<String>().toList(growable: false) ?? const [],
      description: (json['description'] as String?) ?? '',
      stock: (json['stock'] as num).toInt(),
      brand: (json['brand'] as String?) ?? '',
      unit: (json['unit'] as String?) ?? '',
      packUnit: (json['packUnit'] as String?) ??
          (json['pack_unit'] as String?) ??
          '',
      aliases: (json['aliases'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      freshnessBadges:
          rawFreshness?.whereType<String>().toList(growable: false) ?? const [],
      nutritionalInfo: rawNutrition?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          const {},
      storageInstructions: (json['storageInstructions'] as String?) ??
          (json['storage_instructions'] as String?) ??
          '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 120,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'priceCents': priceCents,
    'mrpCents': effectiveMrpCents,
    'imageUrl': imageUrl,
    'images': allImages,
    'description': description,
    'stock': stock,
    'brand': brand,
    'unit': unit,
    'packUnit': displayUnit,
    'aliases': aliases,
    'freshnessBadges': freshnessBadges,
    'nutritionalInfo': nutritionalInfo,
    'storageInstructions': storageInstructions,
    'rating': rating,
    'ratingCount': ratingCount,
  };
}
