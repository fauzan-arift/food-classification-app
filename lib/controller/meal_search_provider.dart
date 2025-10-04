import 'dart:developer';
import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

enum MealSearchState { initial, loading, loaded, error }

class MealSearchProvider extends ChangeNotifier {
  final MealService _mealService = MealService();

  MealSearchState _state = MealSearchState.initial;
  List<Meal> _searchResults = [];
  int _selectedMealIndex = 0;
  String _error = '';
  String _lastSearchQuery = '';

  // Getters
  MealSearchState get state => _state;
  List<Meal> get searchResults => _searchResults;
  int get selectedMealIndex => _selectedMealIndex;
  String get error => _error;
  String get lastSearchQuery => _lastSearchQuery;
  bool get isLoading => _state == MealSearchState.loading;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasMultipleResults => _searchResults.length > 1;

  Meal? get selectedMeal {
    if (_searchResults.isEmpty || _selectedMealIndex >= _searchResults.length) {
      return null;
    }
    return _searchResults[_selectedMealIndex];
  }

  Future<void> searchMeals(String mealName) async {
    if (mealName.trim().isEmpty) {
      clearResults();
      return;
    }

    _state = MealSearchState.loading;
    _error = '';
    _lastSearchQuery = mealName;
    notifyListeners();

    try {
      log('Searching meals for: $mealName');

      final results = await _mealService.searchMealsByName(mealName);

      if (results.isNotEmpty) {
        _searchResults = results
            .map((mealData) => Meal.fromJson(mealData))
            .toList();
        _selectedMealIndex = 0; 
        _state = MealSearchState.loaded;

        log('Found ${_searchResults.length} meals for "$mealName"');
      } else {
        _searchResults = [];
        _selectedMealIndex = 0;
        _state = MealSearchState.loaded;

        log('No meals found for "$mealName"');
      }
    } catch (e) {
      _error = 'Failed to search meals: $e';
      _state = MealSearchState.error;
      _searchResults = [];
      _selectedMealIndex = 0;

      log('Error searching meals: $e');
    }

    notifyListeners();
  }

  void selectMeal(int index) {
    if (index >= 0 &&
        index < _searchResults.length &&
        index != _selectedMealIndex) {
      _selectedMealIndex = index;
      log('Selected meal at index $index: ${_searchResults[index].strMeal}');
      notifyListeners();
    }
  }

  void clearResults() {
    _searchResults = [];
    _selectedMealIndex = 0;
    _error = '';
    _lastSearchQuery = '';
    _state = MealSearchState.initial;
    notifyListeners();
  }

  void retry() {
    if (_lastSearchQuery.isNotEmpty) {
      searchMeals(_lastSearchQuery);
    }
  }

  @override
  void dispose() {
    _searchResults.clear();
    super.dispose();
  }
}
