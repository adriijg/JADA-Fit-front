class OnboardingResponseModel {
  const OnboardingResponseModel({
    required this.onboardingCompleted,
  });

  final bool onboardingCompleted;

  factory OnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    return OnboardingResponseModel(
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}
