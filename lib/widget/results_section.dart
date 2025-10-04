import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/image_classification_provider.dart';
import 'classification_item.dart';

class ResultsSection extends StatelessWidget {
  const ResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageClassificationProvider>(
      builder: (context, provider, child) {
        if (provider.state == ClassificationState.initial) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildContent(context, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.auto_awesome,
            color: Colors.orange.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Analysis Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Powered by machine learning',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    ImageClassificationProvider provider,
  ) {
    if (provider.isLoading) {
      return const _LoadingState();
    } else if (provider.state == ClassificationState.error) {
      return _ErrorState(error: provider.error);
    } else if (provider.classifications.isNotEmpty) {
      return _ResultsState(
        classifications: provider.classifications,
        topLabel: provider.topLabel,
        topConfidence: provider.topConfidence,
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analyzing image'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }
}

class _ResultsState extends StatelessWidget {
  final List<Map<String, dynamic>> classifications;
  final String topLabel;
  final double topConfidence;

  const _ResultsState({
    required this.classifications,
    required this.topLabel,
    required this.topConfidence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClassificationResultsList(classifications: classifications),
        const SizedBox(height: 16),
        _buildBestMatch(context),
      ],
    );
  }

  Widget _buildBestMatch(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Best Match',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ClassificationItem(
          label: topLabel,
          confidence: topConfidence / 100,
          index: 0,
          isTopResult: true,
        ),
      ],
    );
  }
}

class ClassificationResultsList extends StatelessWidget {
  final List<Map<String, dynamic>> classifications;

  const ClassificationResultsList({super.key, required this.classifications});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Results',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...classifications.take(5).map((classification) {
          final index = classifications.indexOf(classification);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ClassificationItem(
              label: classification['label'] as String,
              confidence: (classification['confidence'] as num).toDouble(),
              index: index,
            ),
          );
        }),
      ],
    );
  }
}
