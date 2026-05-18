import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/routine_model.dart';
import '../../data/services/routine_service.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'exercise_library_screen.dart';
import '../widgets/routine_skeleton.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final RoutineService _service = RoutineService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<RoutineModel> _routines = [];
  String _searchQuery = '';
  String _selectedGoal = 'TODOS';

  final List<String> _goals = ['TODOS', 'FUERZA', 'VOLUMEN', 'RESISTENCIA', 'DEFINICIÓN'];

  List<RoutineModel> get _filteredRoutines {
    return _routines.where((routine) {
      final matchesSearch = routine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          routine.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGoal = _selectedGoal == 'TODOS' || 
          routine.targetGoal.toUpperCase() == _selectedGoal;
      return matchesSearch && matchesGoal;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    _loadRoutines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final routines = await _service.getRoutines();

      if (!mounted) return;

      setState(() {
        _routines = routines;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'No se pudieron cargar las rutinas');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openCreateRoutine() async {
    final created = await Navigator.push<RoutineModel?>(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
    );

    if (created != null) {
      _loadRoutines();
    }
  }

  Future<void> _openDetail(RoutineModel routine) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(routine: routine),
      ),
    );

    if (deleted == true) {
      _loadRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRoutines,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.routinesTitle,
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tus planes de entrenamiento',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCreateRoutine,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),

                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStats(),
            const SizedBox(height: 18),
            _buildSearchBar(),
            if (_routines.isNotEmpty) _buildFilters(),
            const SizedBox(height: 8),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalRoutines = _routines.length;
    final avgExercises = totalRoutines > 0 
        ? (_routines.map((e) => e.exercises.length).reduce((a, b) => a + b) / totalRoutines).toStringAsFixed(1)
        : '0';

    return AppCard.elevated(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatItem('RUTINAS', totalRoutines.toString(), Icons.fitness_center_rounded),
          const SizedBox(width: 32),
          _buildStatItem('PROM. EJER.', avgExercises, Icons.layers_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          AppCardIcon(icon: icon, size: 40, borderRadius: 12, iconSize: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        decoration: InputDecoration(
          hintText: 'Buscar rutinas...',
          hintStyle: TextStyle(color: AppColors.textMain.withOpacity(0.3)),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMain),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: _goals.map((goal) {
          final isSelected = _selectedGoal == goal;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(goal),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedGoal = goal);
              },
              backgroundColor: AppColors.inputBackground,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : AppColors.textMain.withOpacity(0.5),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.inputBorder,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _routines.isEmpty) {
      return Column(
        children: List.generate(3, (index) => const RoutineSkeleton()),
      );
    }

    if (_errorMessage != null && _routines.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.textMain, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRoutines,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.textMain,
                  side: BorderSide(color: AppColors.divider.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredRoutines;

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedGoal != 'TODOS'
                  ? Icons.search_off_rounded
                  : Icons.sports_gymnastics,
              color: AppColors.primary.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedGoal != 'TODOS'
                  ? 'Sin resultados'
                  : 'Aún no hay rutinas',
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty || _selectedGoal != 'TODOS'
                  ? 'No encontramos rutinas que coincidan con tus filtros.'
                  : 'Diseña tu primera rutina de entrenamiento para empezar a registrar tus progresos.',
              style: TextStyle(
                color: AppColors.textMain.withOpacity(0.5),
                fontSize: 15,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.map((routine) {
        return _PremiumRoutineCard(
          routine: routine,
          onTap: () => _openDetail(routine),
        );
      }).toList(),
    );
  }
}

class _PremiumRoutineCard extends StatelessWidget {
  const _PremiumRoutineCard({required this.routine, required this.onTap});

  final RoutineModel routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AppCard(
        borderRadius: 32,
        borderColor: AppColors.divider.withOpacity(0.1),
        borderWidth: 1.5,
        padding: const EdgeInsets.all(24),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.tertiary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          routine.targetGoal.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.divider,
                  size: 24,
                ),
              ],
            ),
            if (routine.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                routine.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textMain.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  color: AppColors.textMain.withOpacity(0.3),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${routine.exercises.length} ejercicios',
                  style: TextStyle(
                    color: AppColors.textMain.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (routine.exercises.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      routine.exercises.map((e) => e.name).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMain.withOpacity(0.3),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }


}
