import '../../domain/entities/favorite.dart';

/// Data model for Favorite entity
/// 
/// This model handles serialization/deserialization between the database
/// and the domain entity for favorites
class FavoriteModel {
  final String id;
  final String userId;
  final String itemId;
  final String type;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.createdAt,
    required this.metadata,
  });

  /// Creates a FavoriteModel from JSON data (from Supabase)
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      itemId: json['item_id'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Converts the model to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Converts the model to a domain entity
  Favorite toEntity() {
    return Favorite(
      id: id,
      userId: userId,
      itemId: itemId,
      type: FavoriteType.fromString(type),
      createdAt: createdAt,
      metadata: metadata,
    );
  }

  /// Creates a model from a domain entity
  factory FavoriteModel.fromEntity(Favorite favorite) {
    return FavoriteModel(
      id: favorite.id,
      userId: favorite.userId,
      itemId: favorite.itemId,
      type: favorite.type.value,
      createdAt: favorite.createdAt,
      metadata: favorite.metadata,
    );
  }

  /// Creates a copy of this model with the given fields replaced
  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    String? type,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is FavoriteModel &&
        other.id == id &&
        other.userId == userId &&
        other.itemId == itemId &&
        other.type == type &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        itemId.hashCode ^
        type.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'FavoriteModel(id: $id, userId: $userId, itemId: $itemId, type: $type, createdAt: $createdAt)';
  }
}
