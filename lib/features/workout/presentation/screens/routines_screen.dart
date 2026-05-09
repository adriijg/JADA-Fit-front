import 'package:flutter/material.dart';
import 'package:jada_fit/features/workout/data/models/routine.dart';
import 'package:jada_fit/features/workout/data/services/routine_service.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final RoutineService _routineService = RoutineService();
  late Future<List<Routine>> _routinesFuture;

  @override
  void initState() {
    super.initState();
    _routinesFuture = _routineService.getRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Routine>>(
      future: _routinesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.textMain),
          );
        }

        // Si hay datos, mostramos la lista. Si está vacío o hay error, mantenemos el contenedor original como base.
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final routine = snapshot.data![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.4),
                    width: 0.7,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    routine.name,
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    routine.targetGoal,
                    style: TextStyle(
                      color: AppColors.textMain.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.textMain,
                  ),
                  onTap: () {
                    /* Navegar a detalle */
                  },
                ),
              );
            },
          );
        }

        // Diseño original de "vacío" o "inicio"
        return Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.4),
                width: 0.7,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.routinesTitle,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  snapshot.hasError
                      ? "Error al cargar rutinas"
                      : AppStrings.routinesSubtitle,
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 14,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
