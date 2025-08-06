import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_question.freezed.dart';
part 'style_question.g.dart';

@freezed
class StyleQuestion with _$StyleQuestion {
  const factory StyleQuestion({
    required String id,
    required String title,
    required String description,
    required List<StyleQuestionOption> options,
    @Default(false) bool isMultiSelect,
  }) = _StyleQuestion;

  factory StyleQuestion.fromJson(Map<String, dynamic> json) =>
      _$StyleQuestionFromJson(json);
}

@freezed
class StyleQuestionOption with _$StyleQuestionOption {
  const factory StyleQuestionOption({
    required String id,
    required String title,
    required String imageUrl,
    String? description,
  }) = _StyleQuestionOption;

  factory StyleQuestionOption.fromJson(Map<String, dynamic> json) =>
      _$StyleQuestionOptionFromJson(json);
}
