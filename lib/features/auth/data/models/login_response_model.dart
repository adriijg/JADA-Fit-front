class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.username,
    required this.email,
    required this.onboardingCompleted,
  });

  final String token;
  final String username;
  final String email;
  final bool onboardingCompleted;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
    );
  }
}
