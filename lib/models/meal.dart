class MealDBResponse {
  final List<Meal> meals;

  MealDBResponse({required this.meals});

  factory MealDBResponse.fromJson(Map<String, dynamic> json) {
    return MealDBResponse(
      meals: json['meals'] != null
          ? (json['meals'] as List).map((meal) => Meal.fromJson(meal)).toList()
          : [],
    );
  }
}

class Meal {
  final String idMeal;
  final String strMeal;
  final String? strMealThumb;
  final String? strInstructions;
  final String? strCategory;
  final String? strArea;
  final String? strTags;
  final String? strYoutube;
  final String? strSource;
  final List<String> ingredients;
  final List<String> measurements;

  Meal({
    required this.idMeal,
    required this.strMeal,
    this.strMealThumb,
    this.strInstructions,
    this.strCategory,
    this.strArea,
    this.strTags,
    this.strYoutube,
    this.strSource,
    this.ingredients = const [],
    this.measurements = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measurements = [];

    // Extract ingredients and measurements (up to 20 possible entries)
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measurement = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measurements.add(measurement?.toString().trim() ?? '');
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'],
      strCategory: json['strCategory'],
      strArea: json['strArea'],
      strTags: json['strTags'],
      strYoutube: json['strYoutube'],
      strSource: json['strSource'],
      strInstructions: json['strInstructions'],
      ingredients: ingredients,
      measurements: measurements,
    );
  }
}
