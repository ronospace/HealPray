import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_prediction.freezed.dart';
part 'mood_prediction.g.dart';

@freezed
class MoodPrediction with _$MoodPrediction {
  const factory MoodPrediction({
    required DateTime date,
    required double predictedMood,
    required double predictedScore,
    required double confidence,
    required List<String> factors,
    String? explanation,
    Map<String, dynamic>? metadata,
  }) = _MoodPrediction;

  factory MoodPrediction.fromJson(Map<String, dynamic> json) => _$MoodPredictionFromJson(json);
}
