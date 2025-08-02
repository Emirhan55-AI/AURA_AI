import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/clothing_item.dart';

part 'clothing_item_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ClothingItemModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? category;
  final String? color;
  final String? pattern;
  final String? brand;
  @JsonKey(name: 'purchase_date', fromJson: _dateFromString, toJson: _dateToString)
  final DateTime? purchaseDate;
  @JsonKey(name: 'purchase_location')
  final String? purchaseLocation;
  final String? size;
  final String? condition;
  final double? price;
  final String? currency;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final String? notes;
  final List<String>? tags;
  @JsonKey(name: 'ai_tags')
  final Map<String, dynamic>? aiTags;
  @JsonKey(name: 'last_worn_date', fromJson: _dateFromString, toJson: _dateToString)
  final DateTime? lastWornDate;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at', fromJson: _nullableDateTimeFromString, toJson: _nullableDateTimeToString)
  final DateTime? deletedAt;

  const ClothingItemModel({
    required this.id,
    required this.userId,
    required this.name,
    this.category,
    this.color,
    this.pattern,
    this.brand,
    this.purchaseDate,
    this.purchaseLocation,
    this.size,
    this.condition,
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
    this.deletedAt,
  });

  factory ClothingItemModel.fromJson(Map<String, dynamic> json) =>
      _$ClothingItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClothingItemModelToJson(this);

  ClothingItem toEntity() {
    return ClothingItem(
      id: id,
      userId: userId,
      name: name,
      category: category,
      color: color,
      pattern: pattern,
      brand: brand,
      purchaseDate: purchaseDate,
      purchaseLocation: purchaseLocation,
      size: size,
      condition: condition,
      price: price,
      currency: currency,
      imageUrl: imageUrl,
      notes: notes,
      tags: tags,
      aiTags: aiTags,
      lastWornDate: lastWornDate,
      isFavorite: isFavorite,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  factory ClothingItemModel.fromEntity(ClothingItem entity) {
    return ClothingItemModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      category: entity.category,
      color: entity.color,
      pattern: entity.pattern,
      brand: entity.brand,
      purchaseDate: entity.purchaseDate,
      purchaseLocation: entity.purchaseLocation,
      size: entity.size,
      condition: entity.condition,
      price: entity.price,
      currency: entity.currency,
      imageUrl: entity.imageUrl,
      notes: entity.notes,
      tags: entity.tags,
      aiTags: entity.aiTags,
      lastWornDate: entity.lastWornDate,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  // Helper methods for date/datetime conversion
  static DateTime? _dateFromString(String? dateString) {
    if (dateString == null) return null;
    return DateTime.tryParse(dateString);
  }

  static String? _dateToString(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static DateTime _dateTimeFromString(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  static DateTime? _nullableDateTimeFromString(String? dateTimeString) {
    if (dateTimeString == null) return null;
    return DateTime.tryParse(dateTimeString);
  }

  static String? _nullableDateTimeToString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }
}
