import 'user_summary.dart';

enum ChallengeStatus {
  PENDING,
  ACCEPTED,
  REJECTED,
  FINISHED,
}

class Challenge {
  final String id;
  final UserSummary challenger;
  final UserSummary challenged;
  final String exerciseName;
  final ChallengeStatus status;
  final double challengerWeight;
  final double challengedWeight;
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
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

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
      default:
        return ChallengeStatus.PENDING;
    }
  }
}
