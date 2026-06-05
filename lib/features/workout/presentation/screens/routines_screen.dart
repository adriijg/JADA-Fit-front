import 'package:flutter/material.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/routine_goal.dart';
import '../../data/models/routine_model.dart';
import '../../data/services/routine_service.dart';
import 'create_routine_screen.dart';
import 'routine_detail_screen.dart';
import 'exercise_library_screen.dart';
import '../widgets/routine_skeleton.dart';

class RoutinesScreen extends StatefulWidget {
  RoutinesScreen({super.key});

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
  RoutineGoal? _selectedGoal;
  bool _showCompleted = false;

  List<RoutineModel> get _filteredRoutines {
    return _routines.where((routine) {
      final matchesSearch = routine.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          routine.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGoal = _selectedGoal == null || 
          routine.targetGoal.toUpperCase() == _selectedGoal!.displayName;
      return matchesSearch && matchesGoal;
    }).toList();
  }

  List<RoutineModel> get _inProgressRoutines =>
      _filteredRoutines.where((r) => !r.isCompleted).toList();

  List<RoutineModel> get _completedRoutines =>
      _filteredRoutines.where((r) => r.isCompleted).toList();

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
      MaterialPageRoute(builder: (_) => CreateRoutineScreen()),
    );

    if (created != null) {
      _loadRoutines();
    }
  }

  Future<void> _openDetail(RoutineModel routine) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailScreen(routine: routine),
      ),
    );

    if (changed == true) {
      _loadRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadRoutines,
      color: context.colors.primary,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 32),
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
                        color: context.colors.textMain,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tus planes de entrenamiento',
                      style: TextStyle(
                        color: context.colors.secondary,
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
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseLibraryScreen()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.divider.withOpacity(0.1)),
                        ),
                        child: Icon(Icons.menu_book_rounded, color: context.colors.primary, size: 24),
                      ),
                    ),
                    GestureDetector(
                      onTap: _openCreateRoutine,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(16),

                        ),
                        child: Icon(Icons.add_rounded, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24),
            _buildStats(),
            SizedBox(height: 18),
            _buildSearchBar(),
            if (_routines.isNotEmpty) _buildFilters(),
            SizedBox(height: 8),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    final totalRoutines = _routines.length;
    final completedCount = _routines.where((r) => r.isCompleted).length;

    return AppCard.elevated(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStatItem('RUTINAS', totalRoutines.toString(), Icons.fitness_center_rounded),
          SizedBox(width: 16),
          _buildStatItem('COMPLETADAS', completedCount.toString(), Icons.check_circle_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          AppCardIcon(icon: icon, size: 32, borderRadius: 10, iconSize: 16),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.4),
                  fontSize: 8,
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
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: context.colors.textMain, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Buscar rutinas...',
          hintStyle: TextStyle(color: context.colors.textMain.withOpacity(0.3)),
          prefixIcon: Icon(Icons.search_rounded, color: context.colors.secondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: context.colors.textMain),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final allGoals = [null, ...RoutineGoal.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: allGoals.map((goal) {
          final label = goal == null ? 'TODOS' : goal.displayName;
          final isSelected = _selectedGoal == goal;
          return Padding(
            padding: EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedGoal = goal);
              },
              backgroundColor: context.colors.inputBackground,
              selectedColor: context.colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : context.colors.textMain.withOpacity(0.5),
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected ? context.colors.primary : context.colors.inputBorder,
                ),
              ),
              showCheckmark: false,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _routines.isEmpty) {
      return Column(
        children: List.generate(3, (index) => RoutineSkeleton()),
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, color: AppColors.error, size: 48),
              ),
              SizedBox(height: 24),
              Text(
                _errorMessage!,
                style: TextStyle(color: context.colors.textMain, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRoutines,
                style: ElevatedButton.styleFrom(
                  foregroundColor: context.colors.textMain,
                  side: BorderSide(color: context.colors.divider.withOpacity(0.5)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      );
    }

    final inProgress = _inProgressRoutines;
    final completed = _completedRoutines;

    if (inProgress.isEmpty && completed.isEmpty) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: context.colors.divider.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchQuery.isNotEmpty || _selectedGoal != null
                  ? Icons.search_off_rounded
                  : Icons.sports_gymnastics,
              color: context.colors.primary.withOpacity(0.5),
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty || _selectedGoal != null
                  ? 'Sin resultados'
                  : 'Aún no hay rutinas',
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty || _selectedGoal != null
                  ? 'No encontramos rutinas que coincidan con tus filtros.'
                  : 'Diseña tu primera rutina de entrenamiento para empezar a registrar tus progresos.',
              style: TextStyle(
                color: context.colors.textMain.withOpacity(0.5),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (inProgress.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.play_circle_rounded, color: context.colors.primary, size: 18),
                ),
                SizedBox(width: 10),
                Text(
                  'En progreso',
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Spacer(),
                Text(
                  '${inProgress.length}',
                  style: TextStyle(
                    color: context.colors.textMain.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ...inProgress.map((routine) => Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _PremiumRoutineCard(
              routine: routine,
              onTap: () => _openDetail(routine),
            ),
          )),
        ],
        if (completed.isNotEmpty) ...[
          SizedBox(height: 8),
          GestureDetector(
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _showCompleted ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Completadas',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${completed.length}',
                    style: TextStyle(
                      color: AppColors.success.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showCompleted)
            ...completed.map((routine) => Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: _PremiumRoutineCard(
                routine: routine,
                onTap: () => _openDetail(routine),
              ),
            )),
        ],
      ],
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
      padding: EdgeInsets.only(bottom: 20),
      child: AppCard(
        borderRadius: 32,
        borderColor: context.colors.divider.withOpacity(0.1),
        borderWidth: 1.5,
        padding: EdgeInsets.all(24),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [context.colors.tertiary, context.colors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine.name,
                        style: TextStyle(
                          color: context.colors.textMain,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          routine.targetGoal.toUpperCase(),
                          style: TextStyle(
                            color: context.colors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colors.divider,
                  size: 24,
                ),
              ],
            ),
            if (routine.description.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                routine.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            SizedBox(height: 16),
            Divider(height: 1, color: context.colors.divider),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  color: context.colors.textMain.withOpacity(0.3),
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  '${routine.exercises.length} ejercicios',
                  style: TextStyle(
                    color: context.colors.textMain.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (routine.exercises.isNotEmpty) ...[
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      routine.exercises.map((e) => e.name).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.colors.textMain.withOpacity(0.3),
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
