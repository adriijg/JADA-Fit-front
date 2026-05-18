import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/catalog_exercise_model.dart';
import '../../data/services/catalog_exercise_service.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final CatalogExerciseService _service = CatalogExerciseService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<CatalogExerciseModel> _exercises = [];
  
  @override
  void initState() {
    super.initState();
    _loadExercises();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises([String query = '']) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final exercises = query.isEmpty 
          ? await _service.getAllExercises()
          : await _service.searchExercises(query);

      if (!mounted) return;

      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchSubmit(String query) {
    _loadExercises(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text(
          'Biblioteca de Ejercicios',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.inputBorder,
                  width: 0.7,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.w500),
                onSubmitted: _onSearchSubmit,
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicio (ej. Sentadillas)...',
                  hintStyle: TextStyle(color: AppColors.textMain.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMain),
                    onPressed: () {
                      _searchController.clear();
                      _loadExercises();
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Error: $_errorMessage',
            style: const TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Center(
        child: Text(
          'No se encontraron ejercicios.',
          style: TextStyle(color: AppColors.textMain.withOpacity(0.5)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final exercise = _exercises[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppCard(
            borderRadius: 24,
            borderColor: AppColors.divider.withOpacity(0.1),
            padding: const EdgeInsets.all(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExerciseDetailScreen(exercise: exercise),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMain.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.divider,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
