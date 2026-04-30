class LoginResponseModel {
  final String token;

  const LoginResponseModel({
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
    );
  }
}