import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  runApp(const JadaFitApp());
}

class JadaFitApp extends StatelessWidget {
  const JadaFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JADA-Fit',
      theme: ThemeData(
          fontFamily: 'JadaFont', // Aquí aplicas la fuente globalmente
          brightness: Brightness.dark),
      home: LoginScreen(), // Aquí le decimos que empiece por tu pantalla de login
    );
  }
}