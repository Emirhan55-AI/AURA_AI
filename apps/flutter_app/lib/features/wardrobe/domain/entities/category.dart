class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, icon: $icon, parentId: $parentId)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
