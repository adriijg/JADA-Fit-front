import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/exercise_catalog.dart';
import 'exercise_detail_screen.dart' as detail;

class ExerciseLibraryScreen extends StatefulWidget {
  ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedMuscleGroup;
  bool _showBodyweightOnly = false;

  List<String> get _muscleGroups => ExerciseCatalog.muscleGroups;

  List<CatalogExercise> get _filtered {
    var list = ExerciseCatalog.all;
    if (_searchQuery.isNotEmpty) {
      list = list.where((e) =>
          e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.muscleGroup.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_selectedMuscleGroup != null) {
      list = list.where((e) => e.muscleGroup == _selectedMuscleGroup).toList();
    }
    if (_showBodyweightOnly) {
      list = list.where((e) => e.isBodyweight).toList();
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textMain),
        title: Text(
          'Biblioteca de Ejercicios',
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.inputBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.inputBorder, width: 0.7),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: context.colors.textMain, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Buscar ejercicio...',
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
            ),
          ),
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          _filterChip('Todas', null, _selectedMuscleGroup == null && !_showBodyweightOnly,
              () => setState(() { _selectedMuscleGroup = null; _showBodyweightOnly = false; })),
          _filterChip('Sin peso', null, _showBodyweightOnly,
              () => setState(() { _showBodyweightOnly = true; _selectedMuscleGroup = null; }),
              icon: Icons.accessibility_new_rounded),
          ..._muscleGroups.map((group) => _filterChip(
                group,
                group,
                _selectedMuscleGroup == group && !_showBodyweightOnly,
                () => setState(() { _selectedMuscleGroup = group; _showBodyweightOnly = false; }),
              )),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? group, bool isSelected, VoidCallback onTap, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.only(right: 8, bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.primary : context.colors.inputBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? context.colors.primary : context.colors.inputBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: isSelected ? Colors.black : context.colors.textMain.withOpacity(0.5), size: 16),
                SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : context.colors.textMain.withOpacity(0.5),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final exercises = _filtered;

    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, color: context.colors.textMain.withOpacity(0.2), size: 64),
            SizedBox(height: 16),
            Text(
              'No se encontraron ejercicios',
              style: TextStyle(color: context.colors.textMain.withOpacity(0.5), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppCard(
            borderRadius: 24,
            borderColor: context.colors.divider.withOpacity(0.1),
            padding: EdgeInsets.all(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => detail.ExerciseDetailScreen(
                    exercise: detail.toCatalogModel(exercise),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    exercise.isBodyweight ? Icons.accessibility_new_rounded : Icons.fitness_center_rounded,
                    color: context.colors.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: TextStyle(
                                color: context.colors.textMain,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.colors.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              exercise.muscleGroup,
                              style: TextStyle(
                                color: context.colors.tertiary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        exercise.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colors.textMain.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.colors.divider),
              ],
            ),
          ),
        );
      },
    );
  }
}
