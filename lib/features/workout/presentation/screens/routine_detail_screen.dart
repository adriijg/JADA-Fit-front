import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/routine_model.dart';
import '../../data/services/routine_service.dart';
import '../../data/services/completed_storage_service.dart';
import 'create_routine_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({super.key, required this.routine});

  final RoutineModel routine;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final RoutineService _service = RoutineService();
  final CompletedStorageService _localComplete = CompletedStorageService();

  bool _deleting = false;
  bool _completing = false;
  late Set<int> _completedExercises;
  late bool _routineCompleted;

  @override
  void initState() {
    super.initState();
    _routineCompleted = widget.routine.isCompleted;
    _completedExercises = {};
    _loadLocalState();
  }

  Future<void> _loadLocalState() async {
    if (!_routineCompleted) {
      final indices = await _localComplete.getCompletedExerciseIndices(widget.routine.id ?? -1);
      if (mounted) {
        setState(() => _completedExercises = indices);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: AppColors.error.withOpacity(0.3), width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              '¿Eliminar rutina?',
              style: TextStyle(
                color: AppColors.textMain,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Se eliminará "${widget.routine.name}" y todos sus ejercicios. Esta acción no se puede deshacer.',
          style: TextStyle(
            color: AppColors.textMain.withOpacity(0.72),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error.withOpacity(0.2),
              foregroundColor: AppColors.error,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      await _service.deleteRoutine(widget.routine.id!);
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo eliminar la rutina');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _toggleExerciseCompleted(int index) async {
    if (_routineCompleted) return;

    final exercise = widget.routine.exercises[index];
    if (exercise.id == null) return;

    final isCurrentlyCompleted = _completedExercises.contains(index);

    if (isCurrentlyCompleted) {
      setState(() => _completedExercises.remove(index));
      try {
        await _service.unmarkExerciseCompleted(widget.routine.id!, exercise.id!);
      } catch (_) {
        if (mounted) setState(() => _completedExercises.add(index));
      }
    } else {
      setState(() => _completedExercises.add(index));
      try {
        await _service.markExerciseCompleted(widget.routine.id!, exercise.id!);
        if (widget.routine.id != null) {
          await _localComplete.markExerciseCompleted(widget.routine.id!, index);
        }
      } catch (_) {
        if (mounted) setState(() => _completedExercises.remove(index));
      }
    }
  }

  Future<void> _markRoutineCompleted() async {
    setState(() => _completing = true);

    try {
      await _service.markRoutineCompleted(widget.routine.id!);
      if (widget.routine.id != null) {
        await _localComplete.markRoutineCompleted(widget.routine.id!);
      }
      if (!mounted) return;
      setState(() {
        _routineCompleted = true;
        _completedExercises = Set.from(
          List.generate(widget.routine.exercises.length, (i) => i),
        );
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo completar la rutina');
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<RoutineModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRoutineScreen(existingRoutine: widget.routine),
      ),
    );

    if (updated != null && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withOpacity(0.9),
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds == 0) return '—';
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}min' : '${m}min ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final routine = widget.routine;
    final hasExercises = routine.exercises.isNotEmpty;
    final allExercisesCompleted = hasExercises && _completedExercises.length == routine.exercises.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 280,
            pinned: true,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textMain, size: 18),
              ),
            ),
            actions: [
              if (_routineCompleted)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Completada',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_deleting)
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.error,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                )
              else
                if (!_routineCompleted)
                  IconButton(
                    onPressed: () => _openEdit(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    ),
                    tooltip: 'Editar rutina',
                  ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: routine.id != null ? _confirmDelete : null,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  ),
                  tooltip: 'Eliminar rutina',
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.tertiary.withOpacity(0.3),
                      AppColors.background,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
                          ),
                          child: Text(
                            routine.targetGoal.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          routine.name,
                          style: const TextStyle(
                            color: AppColors.textMain,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (routine.description.isNotEmpty) ...[
                          Text(
                            routine.description,
                            style: TextStyle(
                              color: AppColors.textMain.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ejercicios (${routine.exercises.length})',
                        style: const TextStyle(
                          color: AppColors.textMain,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!hasExercises)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.sports_gymnastics_rounded,
                            color: AppColors.textMain.withOpacity(0.2),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Esta rutina no tiene ejercicios',
                            style: TextStyle(
                              color: AppColors.textMain.withOpacity(0.5),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...routine.exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      final isCompleted = _routineCompleted || _completedExercises.contains(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _PremiumExerciseCard(
                          index: index + 1,
                          exercise: exercise,
                          formatDuration: _formatDuration,
                          isCompleted: isCompleted,
                          onToggleComplete: (_routineCompleted || _completing)
                              ? null
                              : () => _toggleExerciseCompleted(index),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                  if (_routineCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.celebration_rounded, color: AppColors.success, size: 24),
                          SizedBox(width: 12),
                          Text(
                            '¡Rutina completada!',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!_completing && allExercisesCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _markRoutineCompleted,
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: const Text(
                          'Completar rutina',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumExerciseCard extends StatelessWidget {
  const _PremiumExerciseCard({
    required this.index,
    required this.exercise,
    required this.formatDuration,
    this.isCompleted = false,
    this.onToggleComplete,
  });

  final int index;
  final dynamic exercise;
  final String Function(int) formatDuration;
  final bool isCompleted;
  final VoidCallback? onToggleComplete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleComplete,
      child: AppCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        borderColor: isCompleted
            ? AppColors.success.withOpacity(0.4)
            : AppColors.divider.withOpacity(0.3),
        borderWidth: isCompleted ? 1.5 : 1,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_circle, color: AppColors.success, size: 22)
                      : Text(
                          '$index',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: TextStyle(
                                color: isCompleted
                                    ? AppColors.success.withOpacity(0.8)
                                    : AppColors.textMain,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (onToggleComplete != null)
                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isCompleted
                                  ? AppColors.success
                                  : AppColors.textMain.withOpacity(0.3),
                              size: 24,
                            ),
                        ],
                      ),
                      if (exercise.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          exercise.description,
                          style: TextStyle(
                            color: AppColors.textMain.withOpacity(0.6),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatPill(
                            icon: Icons.repeat_rounded,
                            value: '${exercise.sets} series',
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 8),
                          _StatPill(
                            icon: Icons.unfold_more_rounded,
                            value: '${exercise.reps} reps',
                            color: AppColors.secondary,
                          ),
                          if (exercise.durationSeconds > 0) ...[
                            const SizedBox(width: 8),
                            _StatPill(
                              icon: Icons.timer_outlined,
                              value: formatDuration(exercise.durationSeconds),
                              color: AppColors.tertiary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.value, required this.color});

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
