import 'package:flutter/material.dart';

/// Enum representing the status of a challenge submission
enum SubmissionStatus {
  pending,
  approved,
  rejected,
  winner,
}

/// Data model representing a Challenge Submission
class ChallengeSubmission {
  final String id;
  final String challengeId;
  final String combinationId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final int voteCount;
  final SubmissionStatus status;
  final DateTime submissionTime;
  final String? outfitImageUrl;
  final String? description;
  final List<String> tags;
  final bool hasUserVoted;
  final int rank;
  final double score;
  final List<String> judges;

  const ChallengeSubmission({
    required this.id,
    required this.challengeId,
    required this.combinationId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.voteCount,
    this.status = SubmissionStatus.pending,
    required this.submissionTime,
    this.outfitImageUrl,
    this.description,
    this.tags = const [],
    this.hasUserVoted = false,
    this.rank = 0,
    this.score = 0.0,
    this.judges = const [],
  });

  ChallengeSubmission copyWith({
    String? id,
    String? challengeId,
    String? combinationId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? voteCount,
    SubmissionStatus? status,
    DateTime? submissionTime,
    String? outfitImageUrl,
    String? description,
    List<String>? tags,
    bool? hasUserVoted,
    int? rank,
    double? score,
    List<String>? judges,
  }) {
    return ChallengeSubmission(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      combinationId: combinationId ?? this.combinationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      voteCount: voteCount ?? this.voteCount,
      status: status ?? this.status,
      submissionTime: submissionTime ?? this.submissionTime,
      outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      hasUserVoted: hasUserVoted ?? this.hasUserVoted,
      rank: rank ?? this.rank,
      score: score ?? this.score,
      judges: judges ?? this.judges,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChallengeSubmission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Extension methods for ChallengeSubmission
extension ChallengeSubmissionExtensions on ChallengeSubmission {
  /// Get status color for UI display
  Color get statusColor {
    switch (status) {
      case SubmissionStatus.pending:
        return Colors.orange;
      case SubmissionStatus.approved:
        return Colors.green;
      case SubmissionStatus.rejected:
        return Colors.red;
      case SubmissionStatus.winner:
        return Colors.amber;
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case SubmissionStatus.pending:
        return 'Pending Review';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.winner:
        return 'Winner';
    }
  }

  /// Check if this submission is in top 3
  bool get isTopThree => rank > 0 && rank <= 3;

  /// Check if this submission can be voted on
  bool get canVote => status == SubmissionStatus.approved && !hasUserVoted;

  /// Get formatted score for display
  String get formattedScore {
    if (score == score.truncateToDouble()) {
      return score.toInt().toString();
    }
    return score.toStringAsFixed(1);
  }

  /// Get time since submission
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(submissionTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Get rank display with medal emojis for top 3
  String get rankDisplay {
    switch (rank) {
      case 1:
        return '🥇 1st';
      case 2:
        return '🥈 2nd';
      case 3:
        return '🥉 3rd';
      default:
        return rank > 0 ? '#$rank' : '';
    }
  }
}
