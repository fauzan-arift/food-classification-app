import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealDetailContent extends StatelessWidget {
  final Meal meal;

  const MealDetailContent({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          _buildMealInfo(context),
          _buildIngredients(context),
          _buildInstructions(context),
          const SizedBox(height: 24), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: meal.strMealThumb != null
            ? Image.network(
                meal.strMealThumb!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
                ),
              ),
      ),
    );
  }

  Widget _buildMealInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.strMeal,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.category, 'Category', meal.strCategory),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.public, 'Cuisine', meal.strArea),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(
          child: Text(value, style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  Widget _buildIngredients(BuildContext context) {
    final ingredients = _getIngredients();
    if (ingredients.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...ingredients.map(
                (ingredient) => _buildIngredientItem(ingredient),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientItem(Map<String, String> ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14),
                children: [
                  TextSpan(
                    text: ingredient['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (ingredient['measure']?.isNotEmpty == true) ...[
                    const TextSpan(text: ' - '),
                    TextSpan(
                      text: ingredient['measure'],
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    if (meal.strInstructions == null || meal.strInstructions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.menu_book, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                meal.strInstructions!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getIngredients() {
    final ingredients = <Map<String, String>>[];


    for (int i = 0; i < meal.ingredients.length; i++) {
      final ingredient = meal.ingredients[i];
      final measurement = i < meal.measurements.length
          ? meal.measurements[i]
          : '';

      if (ingredient.isNotEmpty) {
        ingredients.add({'name': ingredient, 'measure': measurement});
      }
    }

    return ingredients;
  }
}
