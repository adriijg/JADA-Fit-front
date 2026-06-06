import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_food_model.dart';
import '../../data/models/meal_type.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';
import 'food_search_screen.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key, this.recipe});

  final RecipeModel? recipe;

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _IngredientEntry {
  _IngredientEntry({
    required this.foodName,
    required this.quantityGrams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
  });

  String foodName;
  double quantityGrams;
  double caloriesPer100g;
  double proteinPer100g;
  double carbsPer100g;
  double fatsPer100g;

  double get calories => caloriesPer100g * quantityGrams / 100;
  double get protein => proteinPer100g * quantityGrams / 100;
  double get carbs => carbsPer100g * quantityGrams / 100;
  double get fats => fatsPer100g * quantityGrams / 100;
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingsController = TextEditingController(text: '1');

  final List<_IngredientEntry> _ingredients = [];
  bool _isSaving = false;
  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.recipe;
    if (recipe != null) {
      _nameController.text = recipe.name;
      if (recipe.servings != null) {
        _servingsController.text = recipe.servings.toString();
      }
      for (final ing in recipe.ingredients) {
        final qty = ing.quantityGrams;
        _ingredients.add(_IngredientEntry(
          foodName: ing.foodName,
          quantityGrams: qty,
          caloriesPer100g: qty > 0 ? ing.calories / qty * 100 : 0,
          proteinPer100g: qty > 0 ? ing.protein / qty * 100 : 0,
          carbsPer100g: qty > 0 ? ing.carbs / qty * 100 : 0,
          fatsPer100g: qty > 0 ? ing.fats / qty * 100 : 0,
        ));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  double get _totalCalories =>
      _ingredients.fold(0.0, (sum, i) => sum + i.calories);
  double get _totalProtein =>
      _ingredients.fold(0.0, (sum, i) => sum + i.protein);
  double get _totalCarbs =>
      _ingredients.fold(0.0, (sum, i) => sum + i.carbs);
  double get _totalFats =>
      _ingredients.fold(0.0, (sum, i) => sum + i.fats);

  void _showAddIngredientSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: context.colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.nutritionAddIngredientTitle,
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 16),
            _OptionRow(
              icon: Icons.search,
              label: AppLocalizations.of(context)!.nutritionSearchFood,
              subtitle: AppLocalizations.of(context)!.nutritionSearchOrScan,
              onTap: () {
                Navigator.pop(context);
                _openFoodPicker();
              },
            ),
            _OptionRow(
              icon: Icons.edit_note,
              label: AppLocalizations.of(context)!.nutritionAddManually,
              subtitle: AppLocalizations.of(context)!.nutritionEnterNameAndMacros,
              onTap: () {
                Navigator.pop(context);
                _addManualIngredient();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFoodPicker() async {
    final food = await Navigator.push<CatalogFoodModel>(
      context,
      MaterialPageRoute(
        builder: (_) => FoodSearchScreen(
          pickerMode: true,
          initialMealType: MealType.lunch,
          initialDate: DateTime.now(),
        ),
      ),
    );

    if (food == null || !mounted) return;

    setState(() {
      _ingredients.add(_IngredientEntry(
        foodName: food.name,
        quantityGrams: 100,
        caloriesPer100g: food.caloriesPer100g,
        proteinPer100g: food.proteinPer100g,
        carbsPer100g: food.carbsPer100g,
        fatsPer100g: food.fatsPer100g,
      ));
    });
  }

  void _addManualIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry(
        foodName: '',
        quantityGrams: 100,
        caloriesPer100g: 0,
        proteinPer100g: 0,
        carbsPer100g: 0,
        fatsPer100g: 0,
      ));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nutritionAddAtLeastOneIngredient),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final body = {
        'name': _nameController.text.trim(),
        'servings': int.tryParse(_servingsController.text.trim()),
        'ingredients': _ingredients.map((i) => {
          'foodName': i.foodName.trim(),
          'quantityGrams': i.quantityGrams,
          'caloriesPer100g': i.caloriesPer100g,
          'proteinPer100g': i.proteinPer100g,
          'carbsPer100g': i.carbsPer100g,
          'fatsPer100g': i.fatsPer100g,
        }).toList(),
      };

      if (_isEditing) {
        await _recipeService.updateRecipe(widget.recipe!.id, body);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.nutritionRecipeUpdated),
          ),
        );
      } else {
        await _recipeService.createRecipe(body);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.nutritionRecipeCreated),
          ),
        );
      }

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.nutritionRecipeSaveError),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar receta' : 'Nueva receta',
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveRecipe,
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: context.colors.primary,
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameField(),
              SizedBox(height: 14),
              _buildServingsField(),
              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'INGREDIENTES',
                    style: TextStyle(
                      color: context.colors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '${_ingredients.length} alimento${_ingredients.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: context.colors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              ...List.generate(_ingredients.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: _IngredientCard(
                    ingredient: _ingredients[index],
                    index: index,
                    onRemove: () => _removeIngredient(index),
                  ),
                );
              }),
              SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddIngredientSheet,
                  icon: Icon(Icons.add, size: 18),
                  label: Text(AppLocalizations.of(context)!.nutritionAddIngredient),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.primary,
                    side: BorderSide(
                      color: context.colors.primary.withOpacity(0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_ingredients.isNotEmpty) ...[
                SizedBox(height: 24),
                _buildMacroPreview(),
              ],
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return AppCard.elevated(
      borderRadius: 20,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOMBRE DE LA RECETA',
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Ej: Sandwich Vegetal',
              hintStyle: TextStyle(
                color: context.colors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServingsField() {
    return AppCard.elevated(
      borderRadius: 20,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PORCIONES',
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _servingsController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '1',
              hintStyle: TextStyle(
                color: context.colors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPreview() {
    return AppCard.primary(
      borderRadius: 24,
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: context.colors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'TOTAL RECETA',
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              _MacroBadge(
                label: AppLocalizations.of(context)!.nutritionCalories,
                value: '${_totalCalories.toStringAsFixed(0)} kcal',
              ),
              SizedBox(width: 8),
              _MacroBadge(
                label: AppLocalizations.of(context)!.nutritionProtein,
                value: '${_totalProtein.toStringAsFixed(1)} g',
              ),
              SizedBox(width: 8),
              _MacroBadge(
                label: 'Hidratos',
                value: '${_totalCarbs.toStringAsFixed(1)} g',
              ),
              SizedBox(width: 8),
              _MacroBadge(
                label: 'Grasas',
                value: '${_totalFats.toStringAsFixed(1)} g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
    required this.ingredient,
    required this.index,
    required this.onRemove,
  });

  final _IngredientEntry ingredient;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 20,
      padding: EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppCardIcon(
                icon: Icons.tag,
                size: 32,
                borderRadius: 12,
                iconSize: 13,
                color: context.colors.primary,
                backgroundColor: context.colors.inputBackground,
              ),
              SizedBox(width: 10),
              Text(
                'ALIMENTO',
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Spacer(),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: context.colors.secondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            initialValue: ingredient.foodName,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Nombre del alimento',
              labelStyle: TextStyle(
                color: context.colors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: context.colors.inputBorder, width: 0.7),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: context.colors.inputBorder, width: 0.7),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                borderSide: BorderSide(color: context.colors.primary, width: 1.2),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              isDense: true,
            ),
            onChanged: (value) => ingredient.foodName = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Obligatorio';
              }
              return null;
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MacroField(
                  label: 'Cantidad (g)',
                  initialValue: ingredient.quantityGrams.toString(),
                  onChanged: (v) => ingredient.quantityGrams = v,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroField(
                  label: 'Kcal/100g',
                  initialValue: ingredient.caloriesPer100g.toString(),
                  onChanged: (v) => ingredient.caloriesPer100g = v,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _MacroField(
                  label: 'Prot/100g',
                  initialValue: ingredient.proteinPer100g.toString(),
                  onChanged: (v) => ingredient.proteinPer100g = v,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroField(
                  label: 'Carb/100g',
                  initialValue: ingredient.carbsPer100g.toString(),
                  onChanged: (v) => ingredient.carbsPer100g = v,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _MacroField(
                  label: 'Gras/100g',
                  initialValue: ingredient.fatsPer100g.toString(),
                  onChanged: (v) => ingredient.fatsPer100g = v,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          AppCard.input(
            padding: EdgeInsets.all(10),
            borderRadius: 12,
            child: Row(
              children: [
                _MiniMacro(color: context.colors.secondary, text: '${ingredient.calories.toStringAsFixed(0)} kcal'),
                SizedBox(width: 10),
                _MiniMacro(color: context.colors.secondary, text: 'P ${ingredient.protein.toStringAsFixed(1)}g'),
                SizedBox(width: 10),
                _MiniMacro(color: context.colors.secondary, text: 'C ${ingredient.carbs.toStringAsFixed(1)}g'),
                SizedBox(width: 10),
                _MiniMacro(color: context.colors.secondary, text: 'G ${ingredient.fats.toStringAsFixed(1)}g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _MiniMacro({required Color color, required String text}) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  const _MacroField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: TextStyle(
        color: context.colors.textMain,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: context.colors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: context.colors.inputBorder, width: 0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: context.colors.inputBorder, width: 0.7),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: context.colors.primary, width: 1.2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        isDense: true,
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          onChanged(parsed);
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Req.';
        }
        final parsed = double.tryParse(value);
        if (parsed == null || parsed < 0) {
          return 'Inv.';
        }
        return null;
      },
    );
  }
}

class _MacroBadge extends StatelessWidget {
  const _MacroBadge({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return AppMacroBadge(
      label: label,
      value: value,
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetOption(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
