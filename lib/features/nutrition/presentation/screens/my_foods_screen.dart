import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_food_model.dart';
import '../../data/services/catalog_food_service.dart';

class MyFoodsScreen extends StatefulWidget {
  const MyFoodsScreen({super.key});

  @override
  State<MyFoodsScreen> createState() => _MyFoodsScreenState();
}

class _MyFoodsScreenState extends State<MyFoodsScreen> {
  final CatalogFoodService _catalogFoodService = CatalogFoodService();
  List<CatalogFoodModel> _foods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    try {
      final foods = await _catalogFoodService.getMyCustomFoods();
      if (!mounted) return;
      setState(() => _foods = foods);
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFood(CatalogFoodModel food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Eliminar alimento',
          style: TextStyle(color: AppColors.textMain),
        ),
        content: Text(
          'Se eliminará "${food.name}" de tus alimentos.\n¿Continuar?',
          style: const TextStyle(color: AppColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      await _catalogFoodService.deleteCustomFood(food.id!);
      if (!mounted) return;
      setState(() => _foods.removeWhere((f) => f.id == food.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${food.name}" eliminado'),
            backgroundColor: AppColors.surface,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _createFood() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CreateFoodSheet(),
    );
    if (result == true) _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        title: const Text(
          'Mis Alimentos',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _foods.isEmpty
              ? Center(
                  child: Text(
                    'Aún no tienes alimentos personalizados',
                    style: TextStyle(
                      color: AppColors.textMain.withOpacity(0.45),
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _foods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final food = _foods[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.4),
                          width: 0.7,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    color: AppColors.textMain,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${food.caloriesPer100g.toInt()} kcal \u00b7 '
                                  'P ${food.proteinPer100g.toInt()}g \u00b7 '
                                  'C ${food.carbsPer100g.toInt()}g \u00b7 '
                                  'G ${food.fatsPer100g.toInt()}g / 100g',
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteFood(food),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.error,
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFood,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateFoodSheet extends StatefulWidget {
  const _CreateFoodSheet();

  @override
  State<_CreateFoodSheet> createState() => _CreateFoodSheetState();
}

class _CreateFoodSheetState extends State<_CreateFoodSheet> {
  final CatalogFoodService _catalogFoodService = CatalogFoodService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController calCtrl = TextEditingController();
  final TextEditingController protCtrl = TextEditingController();
  final TextEditingController carbCtrl = TextEditingController();
  final TextEditingController fatCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    calCtrl.dispose();
    protCtrl.dispose();
    carbCtrl.dispose();
    fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final cal = double.tryParse(calCtrl.text.replaceAll(',', '.'));
    final prot = double.tryParse(protCtrl.text.replaceAll(',', '.'));
    final carb = double.tryParse(carbCtrl.text.replaceAll(',', '.'));
    final fat = double.tryParse(fatCtrl.text.replaceAll(',', '.'));

    if (name.isEmpty || cal == null || prot == null || carb == null || fat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _catalogFoodService.createCustomFood(
        name: name,
        caloriesPer100g: cal,
        proteinPer100g: prot,
        carbsPer100g: carb,
        fatsPer100g: fat,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is ApiException ? e.message : 'Error al crear'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'NUEVO ALIMENTO',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _SheetField(ctrl: nameCtrl, label: 'Nombre', hint: 'Ej: Pan integral'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SheetField(ctrl: calCtrl, label: 'Kcal /100g', hint: 'Ej: 250', numeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _SheetField(ctrl: protCtrl, label: 'Proteína /100g', hint: 'Ej: 9', numeric: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SheetField(ctrl: carbCtrl, label: 'Hidratos /100g', hint: 'Ej: 45', numeric: true)),
              const SizedBox(width: 8),
              Expanded(child: _SheetField(ctrl: fatCtrl, label: 'Grasas /100g', hint: 'Ej: 3', numeric: true)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Text(
                      'CREAR ALIMENTO',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.numeric = false,
  });

  final TextEditingController ctrl;
  final String label;
  final String hint;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: AppColors.textMain, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600),
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
