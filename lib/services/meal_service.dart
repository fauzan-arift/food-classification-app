import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  MealService._();
  static final MealService _instance = MealService._();
  factory MealService() => _instance;

  Future<List<Map<String, dynamic>>> searchMealsByName(String mealName) async {
    try {
      log('Searching meals for: $mealName');

      String cleanedMealName = cleanMealName(mealName);
      log('Cleaned meal name: $cleanedMealName');

      final url = '$_baseUrl/search.php?s=$cleanedMealName';
      log('API URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      log('Response status: ${response.statusCode}');
      log('Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        log('Response data keys: ${data.keys}');

        if (data['meals'] != null) {
          final meals = List<Map<String, dynamic>>.from(data['meals']);
          log('Found ${meals.length} meals for "$mealName"');

          if (meals.isNotEmpty) {
            log('First few results:');
            for (int i = 0; i < meals.length && i < 3; i++) {
              log('  ${i + 1}. ${meals[i]['strMeal']}');
            }
          }

          return meals;
        } else {
          log('No meals found for "$mealName" - data[meals] is null');
          log('Full response: ${response.body}');
          return [];
        }
      } else {
        log('Error searching meals: ${response.statusCode}');
        log('Error response: ${response.body}');
        throw Exception('Failed to search meals: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in searchMealsByName: $e');
      throw Exception('Failed to search meals: $e');
    }
  }

  Future<Map<String, dynamic>?> getMealById(String mealId) async {
    try {
      log('Getting meal details for ID: $mealId');

      final response = await http.get(
        Uri.parse('$_baseUrl/lookup.php?i=$mealId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = Map<String, dynamic>.from(data['meals'][0]);
          log('Found meal details for ID: $mealId');
          return meal;
        } else {
          log('No meal found for ID: $mealId');
          return null;
        }
      } else {
        log('Error getting meal details: ${response.statusCode}');
        throw Exception('Failed to get meal details: ${response.statusCode}');
      }
    } catch (e) {
      log('Error in getMealById: $e');
      throw Exception('Failed to get meal details: $e');
    }
  }

  List<Map<String, String>> extractIngredients(Map<String, dynamic> meal) {
    final ingredients = <Map<String, String>>[];

    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient.toString().trim(),
          'measure': measure?.toString().trim() ?? '',
        });
      }
    }

    return ingredients;
  }

  String cleanMealName(String mealName) {
    final commonWords = ['food', 'dish', 'recipe', 'cooked', 'fried', 'baked'];
    String cleaned = mealName.toLowerCase();

    for (final word in commonWords) {
      cleaned = cleaned.replaceAll(word, '').trim();
    }

    cleaned = cleaned.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.isEmpty ? mealName : cleaned;
  }
}
