import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';
import '../../data/models/routine_model.dart';
import '../../data/services/routine_service.dart';

class CreateRoutineScreen extends StatefulWidget {
  const CreateRoutineScreen({super.key});

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetGoalController = TextEditingController();
  final RoutineService _service = RoutineService();

  final List<_ExerciseEntry> _exercises = [];
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetGoalController.dispose();
    super.dispose();
  }

  void _addExercise() {
    setState(() {
      _exercises.add(_ExerciseEntry());
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

    setState(() => _saving = true);

    try {
      final exercises = _exercises.map((e) => ExerciseModel(
            name: e.nameController.text.trim(),
            description: e.descriptionController.text.trim(),
            sets: int.tryParse(e.setsController.text) ?? 1,
            reps: int.tryParse(e.repsController.text) ?? 1,
            durationSeconds: int.tryParse(e.durationController.text) ?? 0,
          )).toList();

      final routine = RoutineModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        targetGoal: _targetGoalController.text.trim(),
        exercises: exercises,
      );

      final created = await _service.createRoutine(routine);
      if (!mounted) return;
      Navigator.pop(context, created);
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo crear la rutina');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, color: AppColors.textMain, size: 28),
        ),
        title: const Text(
          'Creador de Rutinas',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: _saving
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Routine info section
              const _SectionHeader(
                title: 'Información general',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 20),
              _PremiumTextField(
                controller: _nameController,
                label: 'Nombre de la rutina',
                hint: 'Ej. Push Day / Pierna Fuerte',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              _PremiumTextField(
                controller: _descriptionController,
                label: 'Descripción o notas',
                hint: 'Añade detalles, enfoques o consejos...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _PremiumTextField(
                controller: _targetGoalController,
                label: 'Objetivo principal',
                hint: 'Ej. Hipertrofia, Fuerza, Resistencia',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),

              const SizedBox(height: 40),

              // Exercises section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionHeader(
                    title: 'Ejercicios',
                    icon: Icons.fitness_center_rounded,
                  ),
                  InkWell(
                    onTap: _addExercise,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'AÑADIR',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_exercises.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.divider.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          Icons.sports_gymnastics_rounded,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin ejercicios',
                        style: TextStyle(
                          color: AppColors.textMain.withValues(alpha: 0.8),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pulsa "Añadir" para construir tu rutina paso a paso.',
                        style: TextStyle(
                          color: AppColors.textMain.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_exercises.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _PremiumExerciseForm(
                      index: i + 1,
                      entry: _exercises[i],
                      onRemove: () => _removeExercise(i),
                    ),
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

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
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: AppColors.textMain, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(
          color: AppColors.textMain.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
        hintStyle: TextStyle(
          color: AppColors.textMain.withValues(alpha: 0.2),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider.withValues(alpha: 0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.5), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner superior del ejercicio
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: AppColors.background,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Ejercicio $index',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
                  tooltip: 'Eliminar ejercicio',
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          // Formulario del ejercicio
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _PremiumTextField(
                  controller: entry.nameController,
                  label: 'Nombre del ejercicio',
                  hint: 'Ej. Press de Banca Plano',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                _PremiumTextField(
                  controller: entry.descriptionController,
                  label: 'Notas de técnica (opcional)',
                  hint: 'Controlar fase excéntrica...',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PremiumTextField(
                        controller: entry.repsController,
                        label: 'Reps',
                        hint: '10',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 12),
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
