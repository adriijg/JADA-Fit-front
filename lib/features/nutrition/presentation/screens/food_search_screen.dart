import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/catalog_food_model.dart';
import '../../data/models/meal_type.dart';
import '../../data/services/catalog_food_service.dart';
import 'barcode_scanner_screen.dart';
import 'register_meal_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({
    super.key,
    required this.initialMealType,
    required this.initialDate,
    this.pickerMode = false,
  });

  final MealType initialMealType;
  final DateTime initialDate;
  final bool pickerMode;

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final CatalogFoodService _catalogFoodService = CatalogFoodService();
  final TextEditingController searchController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  List<CatalogFoodModel> foods = const [];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFoods() async {
    final query = searchController.text.trim();

    if (query.length < 2) {
      setState(() {
        errorMessage = 'Escribe al menos 2 caracteres';
        foods = const [];
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _catalogFoodService.searchFoods(query);

      if (!mounted) return;

      setState(() {
        foods = result;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo buscar alimentos';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _scanFood() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerScreen(),
      ),
    );

    if (scannedCode == null || scannedCode.isEmpty) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final food = await _catalogFoodService.getFoodByBarcode(scannedCode);

      if (!mounted) return;

      await _openRegisterMeal(food);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo escanear el alimento';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openRegisterMeal(CatalogFoodModel food) async {
    if (widget.pickerMode) {
      Navigator.pop(context, food);
      return;
    }

    final registered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterMealScreen(
          food: food,
          initialMealType: widget.initialMealType,
          initialDate: widget.initialDate,
        ),
      ),
    );

    if (!mounted) return;

    if (registered == true) {
      Navigator.pop(context, true);
    }
  }

  String _formatDouble(double value, String unit) {
    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  String _sourceLabel(String source) {
    switch (source) {
      case 'USER':
        return 'Personalizado';
      case 'OPEN_FOOD_FACTS':
        return 'Open Food Facts';
      default:
        return source;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: Text(
          widget.pickerMode
              ? 'Seleccionar alimento'
              : 'Añadir a ${widget.initialMealType.label.toLowerCase()}',
          style: const TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              _SearchCard(
                controller: searchController,
                isLoading: isLoading,
                onSearch: _searchFoods,
                onScan: _scanFood,
              ),
              const SizedBox(height: 18),
              if (errorMessage != null)
                _ErrorCard(
                  message: errorMessage!,
                ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 28),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              if (!isLoading && foods.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: foods.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final food = foods[index];

                    final brand =
                        food.brand == null || food.brand!.trim().isEmpty
                            ? 'Sin marca'
                            : food.brand!;

                    return InkWell(
                      onTap: () => _openRegisterMeal(food),
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.divider.withOpacity(0.4),
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: AppColors.inputBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.restaurant_menu,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: const TextStyle(
                                      color: AppColors.textMain,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '$brand · ${_sourceLabel(food.source)}',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_formatDouble(food.caloriesPer100g, 'kcal')} / 100g · '
                                    'P ${_formatDouble(food.proteinPer100g, 'g')} · '
                                    'C ${_formatDouble(food.carbsPer100g, 'g')} · '
                                    'G ${_formatDouble(food.fatsPer100g, 'g')}',
                                    style: TextStyle(
                                      color: AppColors.textMain
                                          .withOpacity(0.58),
                                      fontSize: 11,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.secondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (!isLoading && foods.isEmpty && errorMessage == null)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    'Busca un alimento por nombre o escanea su código de barras.',
                    style: TextStyle(
                      color: AppColors.textMain.withOpacity(0.55),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    required this.onScan,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => onSearch(),
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputBackground,
              hintText: 'Buscar alimento, ej: Nutella',
              hintStyle: TextStyle(
                color: AppColors.textMain.withOpacity(0.45),
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.secondary,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.inputBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'BUSCAR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                width: 58,
                child: OutlinedButton(
                  onPressed: isLoading ? null : onScan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Icon(Icons.qr_code_scanner),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.5),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textMain,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
