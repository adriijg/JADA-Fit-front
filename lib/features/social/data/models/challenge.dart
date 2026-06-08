import 'user_summary.dart';

enum ChallengeStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  FINISHED,
  EXPIRED,
}

class ChallengeProgressEntry {
  final String id;
  final UserSummary user;
  final DateTime entryDate;
  final double weight;
  final DateTime createdAt;

  ChallengeProgressEntry({
    required this.id,
    required this.user,
    required this.entryDate,
    required this.weight,
    required this.createdAt,
  });

  factory ChallengeProgressEntry.fromJson(Map<String, dynamic> json) {
    return ChallengeProgressEntry(
      id: json['id'],
      user: UserSummary.fromJson(json['user']),
      entryDate: DateTime.parse(json['entryDate']),
      weight: (json['weight'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Challenge {
  final String id;
  final UserSummary challenger;
  final UserSummary challenged;
  final String exerciseName;
  final ChallengeStatus status;
  final double challengerWeight;
  final double challengedWeight;
  final double targetIncreaseKg;
  final double targetWeightKg;
  final double challengerProgressPercent;
  final double challengedProgressPercent;
  final UserSummary? winner;
  final DateTime? completedAt;
  final List<ChallengeProgressEntry> progressEntries;
  final DateTime createdAt;
  final DateTime expiresAt;

  Challenge({
    required this.id,
    required this.challenger,
    required this.challenged,
    required this.exerciseName,
    required this.status,
    required this.challengerWeight,
    required this.challengedWeight,
    required this.targetIncreaseKg,
    required this.targetWeightKg,
    required this.challengerProgressPercent,
    required this.challengedProgressPercent,
    this.winner,
    this.completedAt,
    required this.progressEntries,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired =>
      status == ChallengeStatus.EXPIRED || DateTime.now().isAfter(expiresAt);

  Duration? get timeRemaining {
    if (isExpired) return null;
    return expiresAt.difference(DateTime.now());
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      challenger: UserSummary.fromJson(json['challenger']),
      challenged: UserSummary.fromJson(json['challenged']),
      exerciseName: json['exerciseName'],
      status: _parseStatus(json['status']),
      challengerWeight: (json['challengerWeight'] ?? 0.0).toDouble(),
      challengedWeight: (json['challengedWeight'] ?? 0.0).toDouble(),
      targetIncreaseKg: (json['targetIncreaseKg'] ?? 10.0).toDouble(),
      targetWeightKg: (json['targetWeightKg'] ?? 0.0).toDouble(),
      challengerProgressPercent:
          (json['challengerProgressPercent'] ?? 0.0).toDouble(),
      challengedProgressPercent:
          (json['challengedProgressPercent'] ?? 0.0).toDouble(),
      winner: json['winner'] != null ? UserSummary.fromJson(json['winner']) : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      progressEntries: (json['progressEntries'] as List<dynamic>? ?? [])
          .map((entry) => ChallengeProgressEntry.fromJson(entry))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  static ChallengeStatus _parseStatus(String status) {
    switch (status) {
      case 'PENDING':
        return ChallengeStatus.PENDING;
      case 'ACCEPTED':
        return ChallengeStatus.ACCEPTED;
      case 'REJECTED':
        return ChallengeStatus.REJECTED;
      case 'FINISHED':
        return ChallengeStatus.FINISHED;
      case 'EXPIRED':
        return ChallengeStatus.EXPIRED;
      default:
        return ChallengeStatus.PENDING;
    }
  }
}
