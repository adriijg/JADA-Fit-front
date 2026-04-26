import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Importa la librería

class AuthService {
  final String baseUrl = "http://10.0.2.2:8080/api/users";
  final _storage = const FlutterSecureStorage(); // Instancia el almacén seguro

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      
      // GUARDAMOS EL TOKEN AQUÍ
      await _storage.write(key: 'jwt_token', value: token);
      print("Token guardado con éxito");
    } else {
      throw Exception('Login fallido');
    }
  }

  // Método para recuperar el token cuando quieras hacer una petición protegida
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
}