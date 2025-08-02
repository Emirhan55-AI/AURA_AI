import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/outfit.dart';

part 'outfit_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OutfitModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String? description;
  @JsonKey(name: 'clothing_item_ids')
  final List<String> clothingItemIds;
  final String? occasion;
  final String? season;
  final String? weather;
  final String? style;
  final List<String>? tags;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'wear_count')
  final int wearCount;
  @JsonKey(name: 'last_worn', fromJson: _nullableDateTimeFromString, toJson: _nullableDateTimeToString)
  final DateTime? lastWorn;
  final double? rating;
  final List<String>? colors;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime updatedAt;
  @JsonKey(name: 'deleted_at', fromJson: _nullableDateTimeFromString, toJson: _nullableDateTimeToString)
  final DateTime? deletedAt;

  const OutfitModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.clothingItemIds,
    this.occasion,
    this.season,
    this.weather,
    this.style,
    this.tags,
    this.imageUrl,
    this.metadata,
    this.isFavorite = false,
    this.isPublic = false,
    this.wearCount = 0,
    this.lastWorn,
    this.rating,
    this.colors,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory OutfitModel.fromJson(Map<String, dynamic> json) =>
      _$OutfitModelFromJson(json);

  Map<String, dynamic> toJson() => _$OutfitModelToJson(this);

  Outfit toEntity() {
    return Outfit(
      id: id,
      userId: userId,
      name: name,
      description: description,
      clothingItemIds: clothingItemIds,
      occasion: occasion,
      season: season,
      weather: weather,
      style: style,
      tags: tags,
      imageUrl: imageUrl,
      metadata: metadata,
      isFavorite: isFavorite,
      isPublic: isPublic,
      wearCount: wearCount,
      lastWorn: lastWorn,
      rating: rating,
      colors: colors,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  factory OutfitModel.fromEntity(Outfit entity) {
    return OutfitModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      clothingItemIds: entity.clothingItemIds,
      occasion: entity.occasion,
      season: entity.season,
      weather: entity.weather,
      style: entity.style,
      tags: entity.tags,
      imageUrl: entity.imageUrl,
      metadata: entity.metadata,
      isFavorite: entity.isFavorite,
      isPublic: entity.isPublic,
      wearCount: entity.wearCount,
      lastWorn: entity.lastWorn,
      rating: entity.rating,
      colors: entity.colors,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  // Helper methods for date/datetime conversion
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
