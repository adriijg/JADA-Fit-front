import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/ai/presentation/providers/ai_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';
class JadaFitApp extends StatelessWidget {
  const JadaFitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AiProvider>(
      create: (_) => AiProvider(),
      child: MaterialApp(
        title: 'JADA FIT',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}