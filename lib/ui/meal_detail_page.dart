import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/meal_detail_provider.dart';
import '../controller/meal_search_provider.dart';
import '../widget/meal_detail_app_bar.dart';
import '../widget/meal_detail_content.dart';
import '../widget/meal_selection_tabs.dart';

class MealDetailPage extends StatelessWidget {
  final String mealName;
  final String? mealId;

  const MealDetailPage({super.key, required this.mealName, this.mealId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          MealDetailProvider()..searchMeals(mealName, mealId: mealId),
      child: Consumer2<MealDetailProvider, MealSearchProvider>(
        builder: (context, provider, searchProvider, child) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: MealDetailAppBar(mealName: mealName),
            body: _buildBody(context, provider, searchProvider),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MealDetailProvider provider,
    MealSearchProvider searchProvider,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error: ${provider.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.searchMeals(mealName, mealId: mealId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (searchProvider.hasMultipleResults)
          MealSelectionTabs(
            meals: searchProvider.searchResults,
            selectedIndex: searchProvider.selectedMealIndex,
            onMealSelected: (index) => searchProvider.selectMeal(index),
          ),

        Expanded(
          child: _getMealContentWidget(context, provider, searchProvider),
        ),
      ],
    );
  }

  Widget _getMealContentWidget(
    BuildContext context,
    MealDetailProvider provider,
    MealSearchProvider searchProvider,
  ) {
    if (searchProvider.selectedMeal != null) {
      return MealDetailContent(meal: searchProvider.selectedMeal!);
    } else if (provider.selectedMeal != null) {
      return MealDetailContent(meal: provider.selectedMeal!);
    } else if (searchProvider.state == MealSearchState.loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return _buildNoResultsWidget(context, searchProvider);
    }
  }

  Widget _buildNoResultsWidget(
    BuildContext context,
    MealSearchProvider searchProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searchProvider.lastSearchQuery.isNotEmpty
                  ? 'No recipes found for "${searchProvider.lastSearchQuery}"'
                  : 'Try searching for a different food item',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Try Another Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
