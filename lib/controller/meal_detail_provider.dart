import 'dart:developer';
import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

enum MealDetailState { initial, loading, loaded, error }

class MealDetailProvider extends ChangeNotifier {
  final MealService _mealService = MealService();
  
  MealDetailState _state = MealDetailState.initial;
  List<Meal> _searchResults = [];
  Meal? _selectedMeal;
  String _error = '';

  MealDetailState get state => _state;
  List<Meal> get searchResults => _searchResults;
  Meal? get selectedMeal => _selectedMeal;
  String get error => _error;
  bool get isLoading => _state == MealDetailState.loading;
  bool get hasMultipleResults => _searchResults.length > 1;

  Future<void> searchMeals(String mealName, {String? mealId}) async {
    _state = MealDetailState.loading;
    _error = '';
    notifyListeners();

    try {
      if (mealId != null) {
        // Get specific meal by ID
        final mealData = await _mealService.getMealById(mealId);
        if (mealData != null) {
          final meal = Meal.fromJson(mealData);
          _selectedMeal = meal;
          _searchResults = [meal];
        }
      } else {
        // Search meals by name
        final cleanedName = _mealService.cleanMealName(mealName);
        final results = await _mealService.searchMealsByName(cleanedName);

        _searchResults = results.map((json) => Meal.fromJson(json)).toList();
        if (_searchResults.isNotEmpty) {
          _selectedMeal = _searchResults.first;
        }
      }
      
      _state = MealDetailState.loaded;
    } catch (e) {
      _error = 'Failed to load meal information: $e';
      _state = MealDetailState.error;
      log('Error loading meals: $e');
    }

    notifyListeners();
  }

  void selectMeal(Meal meal) {
    _selectedMeal = meal;
    notifyListeners();
  }

  void retry(String mealName, {String? mealId}) {
    searchMeals(mealName, mealId: mealId);
  }

  void clearData() {
    _state = MealDetailState.initial;
    _searchResults = [];
    _selectedMeal = null;
    _error = '';
    notifyListeners();
  }
}