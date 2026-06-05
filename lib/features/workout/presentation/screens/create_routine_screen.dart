import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/exercise_catalog.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/routine_goal.dart';
import '../../data/models/routine_model.dart';
import '../../data/models/routine_split.dart';
import '../../data/services/routine_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  final RoutineModel? existingRoutine;

  CreateRoutineScreen({super.key, this.existingRoutine});

  bool get isEditing => existingRoutine != null;

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final RoutineService _service = RoutineService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _suggestionsKey = GlobalKey();

  RoutineGoal? _selectedGoal;
  RoutineSplit? _selectedSplit;
  final List<_ExerciseEntry> _exercises = [];
  bool _saving = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final r = widget.existingRoutine!;
      _nameController.text = r.name;
      _descriptionController.text = r.description;
      _selectedGoal = RoutineGoal.fromString(r.targetGoal);
      _selectedSplit = RoutineSplit.fromString(r.routineSplit);
      for (final ex in r.exercises) {
        final entry = _ExerciseEntry();
        entry.nameController.text = ex.name;
        entry.descriptionController.text = ex.description;
        entry.setsController.text = ex.sets.toString();
        entry.repsController.text = ex.reps.toString();
        entry.durationController.text = ex.durationSeconds.toString();
        _exercises.add(entry);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseEntry());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _addSuggestedExercise(ExerciseSuggestion suggestion) {
    final entry = _ExerciseEntry();
    entry.nameController.text = suggestion.name;
    entry.setsController.text = suggestion.suggestedSets.toString();
    entry.repsController.text = suggestion.suggestedReps.toString();
    entry.durationController.text = (suggestion.durationSeconds ?? 0).toString();
    setState(() {
      _exercises.add(entry);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises[index].dispose();
      _exercises.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedGoal == null) {
      _showError('Selecciona un objetivo para la rutina');
      return;
    }
    if (_selectedSplit == null) {
      _showError('Selecciona el tipo de rutina');
      return;
    }

    setState(() => _saving = true);

    try {
      final exercises = _exercises
          .map((e) => ExerciseModel(
                name: e.nameController.text.trim(),
                description: e.descriptionController.text.trim(),
                sets: int.tryParse(e.setsController.text) ?? 1,
                reps: int.tryParse(e.repsController.text) ?? 1,
                durationSeconds: int.tryParse(e.durationController.text) ?? 0,
              ))
          .toList();

      final routine = RoutineModel(
        id: widget.existingRoutine?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        targetGoal: _selectedGoal!.displayName,
        routineSplit: _selectedSplit!.displayName,
        exercises: exercises,
      );

      if (widget.isEditing) {
        await _service.updateRoutine(routine);
      } else {
        await _service.createRoutine(routine);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing ? '¡Rutina actualizada!' : '¡Rutina creada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, routine);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError(widget.isEditing ? 'No se pudo actualizar la rutina' : 'No se pudo crear la rutina');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.textMain, size: 22),
        ),
        title: Text(
          widget.isEditing ? 'Editar Rutina' : 'Nueva Rutina',
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'Detalles', icon: Icons.auto_awesome_rounded),
                    SizedBox(height: 20),
                    _PremiumTextField(
                      controller: _nameController,
                      label: 'Nombre',
                      hint: 'Ej. Push Day / Pierna / Full Body',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    SizedBox(height: 16),
                    _GoalSelector(
                      selectedGoal: _selectedGoal,
                      onChanged: (goal) {
                        setState(() {
                          _selectedGoal = goal;
                          _showSuggestions = false;
                        });
                      },
                    ),
                    if (_selectedGoal != null) ...[
                      SizedBox(height: 8),
                      _GoalInfoCard(goal: _selectedGoal!),
                    ],
                    SizedBox(height: 16),
                    _SplitSelector(
                      selectedSplit: _selectedSplit,
                      onChanged: (split) {
                        setState(() {
                          _selectedSplit = split;
                          _showSuggestions = false;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _PremiumTextField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint: 'Notas adicionales...',
                      maxLines: 2,
                    ),
                    SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionHeader(title: 'Ejercicios', icon: Icons.fitness_center_rounded),
                        Row(
                          children: [
                            if (_selectedGoal != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _showSuggestions = !_showSuggestions);
                                  if (_showSuggestions) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Future.delayed(const Duration(milliseconds: 200), () {
                                        if (_suggestionsKey.currentContext != null) {
                                          Scrollable.ensureVisible(
                                            _suggestionsKey.currentContext!,
                                            alignment: 0.0,
                                            duration: const Duration(milliseconds: 400),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      });
                                    });
                                  }
                                },
                                icon: Icon(
                                  _showSuggestions ? Icons.close_rounded : Icons.auto_awesome_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  _showSuggestions ? 'CERRAR' : 'SUGERENCIAS',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: context.colors.tertiary,
                                  backgroundColor: context.colors.tertiary.withOpacity(0.1),
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _addExercise,
                              icon: Icon(Icons.add_circle_outline_rounded, size: 20),
                              label: Text('AÑADIR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                              style: TextButton.styleFrom(
                                foregroundColor: context.colors.primary,
                                backgroundColor: context.colors.primary.withOpacity(0.1),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (_showSuggestions && _selectedGoal != null) _buildSuggestions(),
                    if (_exercises.isEmpty && !_showSuggestions)
                      _buildEmptyState()
                    else
                      ...List.generate(_exercises.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: _PremiumExerciseForm(
                            index: i + 1,
                            entry: _exercises[i],
                            onRemove: () => _removeExercise(i),
                          ),
                        );
                      }),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ExerciseCatalog.suggestionsForGoalAndSplit(
      _selectedGoal!,
      _selectedSplit,
    );
    return Container(
      key: _suggestionsKey,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.tertiary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.tertiary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: context.colors.tertiary, size: 18),
              SizedBox(width: 8),
              Text(
                _selectedSplit != null
                    ? 'Ejercicios sugeridos para ${_selectedGoal!.displayName} - ${_selectedSplit!.displayName}'
                    : 'Ejercicios sugeridos para ${_selectedGoal!.displayName}',
                style: TextStyle(
                  color: context.colors.tertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Toca un ejercicio para añadirlo a tu rutina',
            style: TextStyle(
              color: context.colors.tertiary.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 12),
          ...suggestions.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => _addSuggestedExercise(s),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.divider.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.tertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add_rounded, color: context.colors.tertiary, size: 16),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            s.name,
                            style: TextStyle(
                              color: context.colors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${s.suggestedSets}x${s.suggestedReps}',
                          style: TextStyle(
                            color: context.colors.textMain.withOpacity(0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: context.colors.divider.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Icons.add_task_rounded, color: context.colors.textMain.withOpacity(0.2), size: 48),
          SizedBox(height: 16),
          Text(
            '¡Empieza a añadir ejercicios!',
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.4),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedGoal != null) ...[
            SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _showSuggestions = true),
              child: Text(
                'o prueba ejercicios sugeridos para tu objetivo',
                style: TextStyle(
                  color: context.colors.tertiary.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(color: context.colors.background),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: _saving
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                )
              : Text(
                  widget.isEditing ? 'GUARDAR CAMBIOS' : 'GUARDAR RUTINA',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
        ),
      ),
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final RoutineGoal? selectedGoal;
  final ValueChanged<RoutineGoal> onChanged;

  const _GoalSelector({required this.selectedGoal, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Objetivo',
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.divider.withOpacity(0.1)),
          ),
          child: DropdownButtonFormField<RoutineGoal>(
            value: selectedGoal,
            hint: Text(
              'Selecciona un objetivo',
              style: TextStyle(
                color: context.colors.textMain.withOpacity(0.2),
                fontSize: 16,
              ),
            ),
            dropdownColor: context.colors.surface,
            icon: Icon(Icons.expand_more_rounded, color: context.colors.secondary),
            style: TextStyle(color: context.colors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            items: RoutineGoal.values.map((goal) {
              return DropdownMenuItem(
                value: goal,
                child: Row(
                  children: [
                    Icon(
                      _iconForGoal(goal),
                      color: context.colors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(goal.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForGoal(RoutineGoal goal) {
    switch (goal) {
      case RoutineGoal.fuerza:
        return Icons.fitness_center_rounded;
      case RoutineGoal.volumen:
        return Icons.trending_up_rounded;
      case RoutineGoal.resistencia:
        return Icons.directions_run_rounded;
      case RoutineGoal.definicion:
        return Icons.auto_awesome_rounded;
    }
  }
}

class _GoalInfoCard extends StatelessWidget {
  final RoutineGoal goal;

  const _GoalInfoCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.description,
                  style: TextStyle(
                    color: context.colors.textMain.withOpacity(0.7),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Series: ${goal.suggestedSets}',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Reps: ${goal.repRange}',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitSelector extends StatelessWidget {
  final RoutineSplit? selectedSplit;
  final ValueChanged<RoutineSplit> onChanged;

  const _SplitSelector({required this.selectedSplit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Tipo de rutina',
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.divider.withOpacity(0.1)),
          ),
          child: DropdownButtonFormField<RoutineSplit>(
            value: selectedSplit,
            hint: Text(
              'Ej. Empuje, Piernas, Full Body...',
              style: TextStyle(
                color: context.colors.textMain.withOpacity(0.2),
                fontSize: 16,
              ),
            ),
            dropdownColor: context.colors.surface,
            icon: Icon(Icons.expand_more_rounded, color: context.colors.secondary),
            style: TextStyle(color: context.colors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            items: RoutineSplit.values.map((split) {
              return DropdownMenuItem(
                value: split,
                child: Row(
                  children: [
                    Icon(
                      _iconForSplit(split),
                      color: context.colors.tertiary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(split.displayName),
                    SizedBox(width: 8),
                    Text(
                      split.description,
                      style: TextStyle(
                        color: context.colors.textMain.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForSplit(RoutineSplit split) {
    switch (split) {
      case RoutineSplit.fullBody:
        return Icons.accessibility_new_rounded;
      case RoutineSplit.push:
        return Icons.arrow_upward_rounded;
      case RoutineSplit.pull:
        return Icons.arrow_downward_rounded;
      case RoutineSplit.legs:
        return Icons.directions_walk_rounded;
      case RoutineSplit.upper:
        return Icons.pan_tool_alt_rounded;
      case RoutineSplit.lower:
        return Icons.south_rounded;
    }
  }
}

class _ExerciseEntry {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final setsController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10');
  final durationController = TextEditingController(text: '0');

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    setsController.dispose();
    repsController.dispose();
    durationController.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary, size: 22),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: context.colors.textMain,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: context.colors.textMain.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(color: context.colors.textMain, fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.colors.textMain.withOpacity(0.2),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: context.colors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colors.divider.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.colors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}

class _PremiumExerciseForm extends StatelessWidget {
  const _PremiumExerciseForm({
    required this.index,
    required this.entry,
    required this.onRemove,
  });

  final int index;
  final _ExerciseEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.colors.divider.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: context.colors.primary,
                  child: Text(
                    '$index',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Ejercicio',
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.remove_circle_outline_rounded, color: AppColors.error, size: 24),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _PremiumTextField(
                  controller: entry.nameController,
                  label: 'Nombre',
                  hint: 'Ej. Press de Banca',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _PremiumTextField(
                        controller: entry.setsController,
                        label: 'Series',
                        hint: '3',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PremiumTextField(
                        controller: entry.repsController,
                        label: 'Reps',
                        hint: '10',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _PremiumTextField(
                        controller: entry.durationController,
                        label: 'Segundos',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
