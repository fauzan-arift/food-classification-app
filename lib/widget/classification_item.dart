import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/meal_search_provider.dart';
import '../ui/meal_detail_page.dart';

class ClassificationItem extends StatelessWidget {
  final String label;
  final double confidence;
  final int index;
  final bool isTopResult;

  const ClassificationItem({
    super.key,
    required this.label,
    required this.confidence,
    required this.index,
    this.isTopResult = false,
  });

  String _getSearchTermFromLabel(String label) {
    return label.trim();
  }

  void _navigateToMealDetail(BuildContext context) async {
    final searchProvider = context.read<MealSearchProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String searchTerm = _getSearchTermFromLabel(label);
    log('DEBUG: Searching directly for ML result: "$searchTerm"');

    await searchProvider.searchMeals(searchTerm);

    if (context.mounted) {
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MealDetailPage(mealName: label),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidencePercentage = (confidence * 100).toStringAsFixed(1);

    return GestureDetector(
      onTap: () => _navigateToMealDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isTopResult
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isTopResult
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: isTopResult ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isTopResult
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Label and confidence
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: isTopResult ? 16 : 14,
                      fontWeight: isTopResult
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isTopResult
                          ? Theme.of(context).primaryColor
                          : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Confidence bar
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: LinearProgressIndicator(
                          value: confidence,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isTopResult
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        flex: 2,
                        child: Text(
                          '$confidencePercentage%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isTopResult
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Confidence indicator icon
            if (confidence > 0.8)
              Icon(Icons.check_circle, color: Colors.green, size: 20)
            else if (confidence > 0.5)
              Icon(Icons.help_outline, color: Colors.orange, size: 20)
            else
              Icon(Icons.error_outline, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }
}

class ClassificationResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> classifications;
  final bool showOnlyTop;

  const ClassificationResultsList({
    super.key,
    required this.classifications,
    this.showOnlyTop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (classifications.isEmpty) {
      return const Center(
        child: Text(
          'No classification results',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final resultsToShow = showOnlyTop
        ? classifications.take(1).toList()
        : classifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!showOnlyTop) ...[
          Text(
            'Classification Results',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
        ],

        ...resultsToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;

          return ClassificationItem(
            label: result['label'] as String,
            confidence: result['confidence'] as double,
            index: index,
            isTopResult: index == 0,
          );
        }),

        if (showOnlyTop && classifications.length > 1) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '+${classifications.length - 1} more results',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
