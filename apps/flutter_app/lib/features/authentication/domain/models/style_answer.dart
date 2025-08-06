import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_answer.freezed.dart';
part 'style_answer.g.dart';

@freezed
class StyleAnswer with _$StyleAnswer {
  const factory StyleAnswer({
    required String questionId,
    required List<String> selectedOptionIds,
    DateTime? answeredAt,
  }) = _StyleAnswer;

  factory StyleAnswer.fromJson(Map<String, dynamic> json) =>
      _$StyleAnswerFromJson(json);
}
