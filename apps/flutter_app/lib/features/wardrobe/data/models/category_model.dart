import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CategoryModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  @JsonKey(name: 'parent_id')
  final String? parentId;
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime createdAt;
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      icon: icon,
      parentId: parentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      icon: entity.icon,
      parentId: entity.parentId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Helper methods for datetime conversion
  static DateTime _dateTimeFromString(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static String _dateTimeToString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}
