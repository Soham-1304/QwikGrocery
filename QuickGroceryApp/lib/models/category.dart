/// Category model for category shortcut rail and catalog filtering.
class Category {
  const Category({
    required this.id,
    required this.name,
    this.iconUrl = '',
    this.iconName = '',
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String iconUrl;
  final String iconName;
  final int itemCount;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String? ?? json['name'] as String? ?? '',
    name: json['name'] as String? ?? '',
    iconUrl: json['iconUrl'] as String? ?? '',
    iconName: json['iconName'] as String? ?? '',
    itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconUrl': iconUrl,
    'iconName': iconName,
    'itemCount': itemCount,
  };
}
