import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/routine.dart';

class RoutineService {
  final String baseUrl = "http://localhost:8080/api/routines";

  Future<List<Routine>> getRoutines() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Routine.fromJson(item)).toList();
    } else {
      throw Exception('Fallo al cargar rutinas');
    }
  }

  Future<void> createRoutine(Routine routine) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(routine.toJson()),
    );
  }
}
