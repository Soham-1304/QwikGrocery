import 'package:flutter/material.dart';

/// Promotional hero banner item for the DealsCarousel.
/// Colors and icons can be hardcoded per-banner for a rich visual experience.
class BannerItem {
  const BannerItem({
    required this.id,
    required this.title,
    this.subtitle = '',
    String tag = '',
    String? badgeText,
    this.imageUrl = '',
    this.primaryColor = const Color(0xFF0C831F),
    this.secondaryColor = const Color(0xFF065A14),
    this.icon = Icons.local_grocery_store_outlined,
    String? categoryFilter,
    String? actionRoute,
  })  : tag = badgeText ?? tag,
        categoryFilter = actionRoute ?? categoryFilter;

  final String id;
  final String title;
  final String subtitle;
  final String tag;
  final String imageUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String? categoryFilter;

  String get badgeText => tag;
  String get actionRoute => categoryFilter ?? '';
  String get backgroundColorHex => '#${primaryColor.value.toRadixString(16).padLeft(8, '0')}';

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'tag': tag,
    'imageUrl': imageUrl,
    'categoryFilter': categoryFilter,
  };

  factory BannerItem.fromJson(Map<String, dynamic> json) => BannerItem(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String? ?? '',
    tag: json['badgeText'] as String? ?? json['tag'] as String? ?? '',
    imageUrl: json['imageUrl'] as String? ?? '',
    categoryFilter: json['categoryFilter'] as String? ?? json['actionRoute'] as String?,
  );
}
