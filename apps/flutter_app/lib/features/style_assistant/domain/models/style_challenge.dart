import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'style_challenge.freezed.dart';
part 'style_challenge.g.dart';

/// Enum representing the status of a style challenge
enum ChallengeStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('active')
  active,
  @JsonValue('voting')
  voting,
  @JsonValue('past')
  past,
}

/// Enum representing the difficulty level of a style challenge
enum ChallengeDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// Data model representing a Style Challenge
@freezed
class StyleChallenge with _$StyleChallenge {
  const factory StyleChallenge({
    required String id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime votingStartTime,
    required DateTime endTime,
    required ChallengeStatus status,
    required String prizeDescription,
    @Default(ChallengeDifficulty.beginner) ChallengeDifficulty difficulty,
    String? imageUrl,
    @Default([]) List<String> tags,
    @Default(0) int submissionCount,
    @Default(0) int participantCount,
    @Default(false) bool isParticipating,
    @Default(false) bool isVotingOpen,
    @Default(0) int prizeValue,
    String? winnerId,
    @Default([]) List<String> judges,
    String? sponsorName,
    String? sponsorLogo,
  }) = _StyleChallenge;

  factory StyleChallenge.fromJson(Map<String, dynamic> json) =>
      _$StyleChallengeFromJson(json);
}

/// Extension for StyleChallenge business logic
extension StyleChallengeX on StyleChallenge {
  /// Helper method to get a formatted time range string
  String get timeRangeText {
    final now = DateTime.now();
    
    switch (status) {
      case ChallengeStatus.active:
        final daysRemaining = endTime.difference(now).inDays;
        final hoursRemaining = endTime.difference(now).inHours % 24;
        if (daysRemaining > 0) {
          return '$daysRemaining days left';
        } else if (hoursRemaining > 0) {
          return '$hoursRemaining hours left';
        } else {
          return 'Ending soon';
        }
      
      case ChallengeStatus.upcoming:
        final daysToStart = startTime.difference(now).inDays;
        return 'Starts in $daysToStart days';
      
      case ChallengeStatus.voting:
        final daysToEnd = endTime.difference(now).inDays;
        return 'Voting ends in $daysToEnd days';
      
      case ChallengeStatus.past:
        return 'Completed';
    }
  }

  /// Get status color based on challenge status
  Color get statusColor {
    switch (status) {
      case ChallengeStatus.active:
        return const Color(0xFF4CAF50); // Green
      case ChallengeStatus.upcoming:
        return const Color(0xFF2196F3); // Blue
      case ChallengeStatus.voting:
        return const Color(0xFFFF9800); // Orange
      case ChallengeStatus.past:
        return const Color(0xFF757575); // Grey
    }
  }

  /// Get difficulty color
  Color get difficultyColor {
    switch (difficulty) {
      case ChallengeDifficulty.beginner:
        return const Color(0xFF4CAF50); // Green
      case ChallengeDifficulty.intermediate:
        return const Color(0xFFFF9800); // Orange
      case ChallengeDifficulty.advanced:
        return const Color(0xFFF44336); // Red
    }
  }

  /// Check if user can participate in this challenge
  bool get canParticipate {
    final now = DateTime.now();
    return status == ChallengeStatus.active && 
           now.isAfter(startTime) && 
           now.isBefore(votingStartTime);
  }

  /// Check if voting is currently open
  bool get canVote {
    final now = DateTime.now();
    return status == ChallengeStatus.voting && 
           now.isAfter(votingStartTime) && 
           now.isBefore(endTime);
  }

  /// Get progress percentage (0-100)
  double get progressPercentage {
    final now = DateTime.now();
    
    switch (status) {
      case ChallengeStatus.upcoming:
        return 0.0;
      
      case ChallengeStatus.active:
        final totalDuration = votingStartTime.difference(startTime).inMilliseconds;
        final elapsed = now.difference(startTime).inMilliseconds;
        return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
      
      case ChallengeStatus.voting:
        final totalDuration = endTime.difference(votingStartTime).inMilliseconds;
        final elapsed = now.difference(votingStartTime).inMilliseconds;
        return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
      
      case ChallengeStatus.past:
        return 100.0;
    }
  }
}
