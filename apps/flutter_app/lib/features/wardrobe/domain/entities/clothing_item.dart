class ClothingItem {
  final String id;
  final String userId;
  final String name;
  final String? category;
  final String? color;
  final String? pattern;
  final String? brand;
  final DateTime? purchaseDate;
  final double? price;
  final String? currency;
  final String? imageUrl;
  final String? notes;
  final List<String>? tags;
  final Map<String, dynamic>? aiTags;
  final DateTime? lastWornDate;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothingItem({
    required this.id,
    required this.userId,
    required this.name,
    this.category,
    this.color,
    this.pattern,
    this.brand,
    this.purchaseDate,
    this.price,
    this.currency = 'USD',
    this.imageUrl,
    this.notes,
    this.tags,
    this.aiTags,
    this.lastWornDate,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'ClothingItem(id: $id, userId: $userId, name: $name, category: $category, color: $color, brand: $brand, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothingItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  ClothingItem copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? color,
    String? pattern,
    String? brand,
    DateTime? purchaseDate,
    double? price,
    String? currency,
    String? imageUrl,
    String? notes,
    List<String>? tags,
    Map<String, dynamic>? aiTags,
    DateTime? lastWornDate,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      pattern: pattern ?? this.pattern,
      brand: brand ?? this.brand,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      aiTags: aiTags ?? this.aiTags,
      lastWornDate: lastWornDate ?? this.lastWornDate,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
