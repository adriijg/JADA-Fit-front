import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_food_model.dart';
import '../../data/models/meal_type.dart';
import '../../data/services/catalog_food_service.dart';
import '../../data/services/nutrition_meal_service.dart';

class RegisterMealScreen extends StatefulWidget {
  RegisterMealScreen({
    super.key,
    required this.food,
    required this.initialMealType,
    required this.initialDate,
  }) : isManualCreate = false;

  RegisterMealScreen.fromRecent({
    super.key,
    required String foodName,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    required MealType initialMealType,
    required DateTime initialDate,
  })  : food = CatalogFoodModel(
          id: '',
          name: foodName,
          brand: null,
          barcode: null,
          source: 'USER',
          caloriesPer100g: caloriesPer100g,
          proteinPer100g: proteinPer100g,
          carbsPer100g: carbsPer100g,
          fatsPer100g: fatsPer100g,
        ),
        initialMealType = initialMealType,
        initialDate = initialDate,
        isManualCreate = false;

  RegisterMealScreen.manualCreate({
    super.key,
    required MealType initialMealType,
    required DateTime initialDate,
  })  : food = CatalogFoodModel(
          id: '',
          name: '',
          brand: null,
          barcode: null,
          source: 'USER',
          caloriesPer100g: 0,
          proteinPer100g: 0,
          carbsPer100g: 0,
          fatsPer100g: 0,
        ),
        initialMealType = initialMealType,
        initialDate = initialDate,
        isManualCreate = true;

  final CatalogFoodModel food;
  final MealType initialMealType;
  final DateTime initialDate;
  final bool isManualCreate;

  @override
  State<RegisterMealScreen> createState() => _RegisterMealScreenState();
}

class _RegisterMealScreenState extends State<RegisterMealScreen> {
  final NutritionMealService _nutritionMealService = NutritionMealService();
  final CatalogFoodService _catalogFoodService = CatalogFoodService();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController fatsController = TextEditingController();

  late MealType selectedMealType;
  late DateTime selectedDate;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    quantityController.text = '100';
    if (widget.isManualCreate) {
      foodNameController.text = '';
      caloriesController.text = '';
      proteinController.text = '';
      carbsController.text = '';
      fatsController.text = '';
    }
    selectedMealType = widget.initialMealType;
    selectedDate = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
      widget.initialDate.day,
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    foodNameController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatsController.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');

    if (trimmed.isEmpty) return null;

    return double.tryParse(trimmed);
  }

  DateTime _selectedDateTime() {
    final now = DateTime.now();

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  String _formatSelectedDate() {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final year = selectedDate.year.toString();

    return '$day/$month/$year';
  }

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  double _calculateForQuantity(double per100g, double quantity) {
    return per100g * quantity / 100;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.primary,
              surface: context.colors.surface,
              onSurface: context.colors.textMain,
            ),
            dialogTheme: DialogThemeData(
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  Future<void> _saveMeal() async {
    final quantity = _parseDouble(quantityController.text);
    final loggedAt = _selectedDateTime();

    setState(() {
      errorMessage = null;
    });

    if (quantity == null) {
      setState(() {
        errorMessage = 'Introduce la cantidad en gramos';
      });
      return;
    }

    if (quantity <= 0) {
      setState(() {
        errorMessage = 'La cantidad debe ser mayor que 0';
      });
      return;
    }

    if (widget.isManualCreate && _foodName.isEmpty) {
      setState(() {
        errorMessage = 'Introduce el nombre del alimento';
      });
      return;
    }

    if (loggedAt.isAfter(DateTime.now())) {
      setState(() {
        errorMessage = 'No puedes registrar una comida en una fecha futura';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      if (widget.isManualCreate) {
        await _catalogFoodService.createCustomFood(
          name: _foodName,
          caloriesPer100g: _calsPer100g,
          proteinPer100g: _protPer100g,
          carbsPer100g: _carbPer100g,
          fatsPer100g: _fatPer100g,
        );
        if (!mounted) return;
      }

      await _nutritionMealService.createMeal(
        externalFoodId: widget.food.externalFoodId ?? widget.food.barcode,
        foodName: _foodName,
        foodSource: widget.food.source,
        mealType: selectedMealType,
        quantityGrams: quantity,
        caloriesPer100g: _calsPer100g,
        proteinPer100g: _protPer100g,
        carbsPer100g: _carbPer100g,
        fatsPer100g: _fatPer100g,
        loggedAt: loggedAt,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nutritionMealRegistered),
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo registrar la comida';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  double get _calsPer100g =>
      widget.isManualCreate ? (_parseDouble(caloriesController.text) ?? 0) : widget.food.caloriesPer100g;
  double get _protPer100g =>
      widget.isManualCreate ? (_parseDouble(proteinController.text) ?? 0) : widget.food.proteinPer100g;
  double get _carbPer100g =>
      widget.isManualCreate ? (_parseDouble(carbsController.text) ?? 0) : widget.food.carbsPer100g;
  double get _fatPer100g =>
      widget.isManualCreate ? (_parseDouble(fatsController.text) ?? 0) : widget.food.fatsPer100g;
  String get _foodName =>
      widget.isManualCreate ? foodNameController.text.trim() : widget.food.name;

  @override
  Widget build(BuildContext context) {
    final quantity = _parseDouble(quantityController.text) ?? 0;

    final calories = _calculateForQuantity(
      _calsPer100g,
      quantity,
    );
    final protein = _calculateForQuantity(
      _protPer100g,
      quantity,
    );
    final carbs = _calculateForQuantity(
      _carbPer100g,
      quantity,
    );
    final fats = _calculateForQuantity(
      _fatPer100g,
      quantity,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          'Registrar comida',
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              widget.isManualCreate
                  ? _ManualFoodCard(
                      foodNameController: foodNameController,
                      caloriesController: caloriesController,
                      proteinController: proteinController,
                      carbsController: carbsController,
                      fatsController: fatsController,
                    )
                  : _FoodHeaderCard(food: widget.food),
              SizedBox(height: 20),
              _QuantityCard(
                controller: quantityController,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 16),
              _MealTypeCard(
                selectedMealType: selectedMealType,
                onSelected: (mealType) {
                  setState(() {
                    selectedMealType = mealType;
                  });
                },
              ),
              SizedBox(height: 16),
              _DateCard(
                selectedDate: _formatSelectedDate(),
                onPickDate: _pickDate,
              ),
              SizedBox(height: 16),
              _MacroPreviewCard(
                calories: _formatDouble(calories, 'kcal'),
                protein: _formatDouble(protein, 'g'),
                carbs: _formatDouble(carbs, 'g'),
                fats: _formatDouble(fats, 'g'),
              ),
              SizedBox(height: 18),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.background,
                    elevation: 12,
                    shadowColor: context.colors.primary.withOpacity(0.32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: context.colors.background,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'REGISTRAR COMIDA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.restaurant_menu, size: 20),
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

class _ManualFoodCard extends StatelessWidget {
  const _ManualFoodCard({
    required this.foodNameController,
    required this.caloriesController,
    required this.proteinController,
    required this.carbsController,
    required this.fatsController,
  });

  final TextEditingController foodNameController;
  final TextEditingController caloriesController;
  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatsController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.create, color: context.colors.primary, size: 22),
              SizedBox(width: 10),
              Text(
                'NUEVO ALIMENTO',
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          _ManualField(
            controller: foodNameController,
            label: AppLocalizations.of(context)!.nutritionFoodName,
            hint: AppLocalizations.of(context)!.nutritionFoodNameHint,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ManualField(
                  controller: caloriesController,
                  label: AppLocalizations.of(context)!.nutritionCaloriesPer100g,
                  hint: 'Ej: 130',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ManualField(
                  controller: proteinController,
                  label: AppLocalizations.of(context)!.nutritionProteinPer100g,
                  hint: 'Ej: 2.7',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ManualField(
                  controller: carbsController,
                  label: AppLocalizations.of(context)!.nutritionCarbsPer100g,
                  hint: 'Ej: 28',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ManualField(
                  controller: fatsController,
                  label: AppLocalizations.of(context)!.nutritionFatPer100g,
                  hint: 'Ej: 1.2',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ManualField extends StatelessWidget {
  const _ManualField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      style: TextStyle(
        color: context.colors.textMain,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.inputBackground,
        labelText: label,
        labelStyle: TextStyle(
          color: context.colors.secondary,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.primary,
            width: 1.4,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class _FoodHeaderCard extends StatelessWidget {
  const _FoodHeaderCard({
    required this.food,
  });

  final CatalogFoodModel food;

  String _sourceLabel(String source) {
    switch (source) {
      case 'USER':
        return 'Alimento personalizado';
      case 'OPEN_FOOD_FACTS':
        return 'Open Food Facts';
      default:
        return source;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = food.brand == null || food.brand!.trim().isEmpty
        ? 'Sin marca'
        : food.brand!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.28),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.restaurant_menu,
            color: context.colors.primary,
            size: 42,
          ),
          SizedBox(height: 18),
          Text(
            food.name,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '$brand · ${_sourceLabel(food.source)}',
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: TextStyle(
          color: context.colors.textMain,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colors.inputBackground,
          labelText: 'Cantidad',
          labelStyle: TextStyle(
            color: context.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Ej: 150',
          prefixIcon: Icon(
            Icons.scale_outlined,
            color: context.colors.primary,
          ),
          suffixText: 'g',
          suffixStyle: TextStyle(
            color: context.colors.secondary,
            fontWeight: FontWeight.w700,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: context.colors.inputBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MealTypeCard extends StatelessWidget {
  const _MealTypeCard({
    required this.selectedMealType,
    required this.onSelected,
  });

  final MealType selectedMealType;
  final ValueChanged<MealType> onSelected;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TIPO DE COMIDA',
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MealType.values.map((mealType) {
              final isSelected = mealType == selectedMealType;

              return InkWell(
                onTap: () => onSelected(mealType),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.inputBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    mealType.label,
                    style: TextStyle(
                      color: isSelected
                          ? context.colors.background
                          : context.colors.textMain,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.selectedDate,
    required this.onPickDate,
  });

  final String selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: onPickDate,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.inputBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: context.colors.inputBorder,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: context.colors.primary,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  selectedDate,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.edit_calendar,
                color: context.colors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPreviewCard extends StatelessWidget {
  const _MacroPreviewCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final String calories;
  final String protein;
  final String carbs;
  final String fats;

  @override
  Widget build(BuildContext context) {
    return _Card(
      borderColor: context.colors.primary.withOpacity(0.28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.nutritionCalculatedSummary,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroBox(
                  label: AppLocalizations.of(context)!.nutritionCalories,
                  value: calories,
                  icon: Icons.local_fire_department,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MacroBox(
                  label: AppLocalizations.of(context)!.nutritionProtein,
                  value: protein,
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MacroBox(
                  label: AppLocalizations.of(context)!.nutritionCarbs,
                  value: carbs,
                  icon: Icons.grain,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MacroBox(
                  label: AppLocalizations.of(context)!.nutritionFat,
                  value: fats,
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroBox extends StatelessWidget {
  const _MacroBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: context.colors.primary,
            size: 23,
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.borderColor,
  });

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor ?? context.colors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: child,
    );
  }
}
