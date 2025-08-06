import 'package:flutter/material.dart';

/// Enum representing the status of a style challenge
enum ChallengeStatus {
  upcoming,
  active,
  voting,
  past,
}

/// Enum representing the difficulty level of a style challenge
enum ChallengeDifficulty {
  beginner,
  intermediate,
  advanced,
}

/// Data model representing a Style Challenge
class StyleChallenge {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime votingStartTime;
  final DateTime endTime;
  final ChallengeStatus status;
  final String prizeDescription;
  final ChallengeDifficulty difficulty;
  final String? imageUrl;
  final List<String> tags;
  final int submissionCount;
  final int participantCount;
  final bool isParticipating;
  final bool isVotingOpen;
  final int prizeValue;
  final String? winnerId;
  final List<String> judges;
  final String? sponsorName;
  final String? sponsorLogo;

  const StyleChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.votingStartTime,
    required this.endTime,
    required this.status,
    required this.prizeDescription,
    this.difficulty = ChallengeDifficulty.beginner,
    this.imageUrl,
    this.tags = const [],
    this.submissionCount = 0,
    this.participantCount = 0,
    this.isParticipating = false,
    this.isVotingOpen = false,
    this.prizeValue = 0,
    this.winnerId,
    this.judges = const [],
    this.sponsorName,
    this.sponsorLogo,
  });

  /// Create a copy with modified fields
  StyleChallenge copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? votingStartTime,
    DateTime? endTime,
    ChallengeStatus? status,
    String? prizeDescription,
    ChallengeDifficulty? difficulty,
    String? imageUrl,
    List<String>? tags,
    int? submissionCount,
    int? participantCount,
    bool? isParticipating,
    bool? isVotingOpen,
    int? prizeValue,
    String? winnerId,
    List<String>? judges,
    String? sponsorName,
    String? sponsorLogo,
  }) {
    return StyleChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      votingStartTime: votingStartTime ?? this.votingStartTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      prizeDescription: prizeDescription ?? this.prizeDescription,
      difficulty: difficulty ?? this.difficulty,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      submissionCount: submissionCount ?? this.submissionCount,
      participantCount: participantCount ?? this.participantCount,
      isParticipating: isParticipating ?? this.isParticipating,
      isVotingOpen: isVotingOpen ?? this.isVotingOpen,
      prizeValue: prizeValue ?? this.prizeValue,
      winnerId: winnerId ?? this.winnerId,
      judges: judges ?? this.judges,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorLogo: sponsorLogo ?? this.sponsorLogo,
    );
  }
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
