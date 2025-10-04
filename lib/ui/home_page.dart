import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/image_classification_provider.dart';
import '../widget/image_display_area.dart';
import '../widget/action_buttons_row.dart';
import '../widget/results_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _clearResults() {
    context.read<ImageClassificationProvider>().clearResults();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageClassificationProvider>().initialize();
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Food Classifier',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Consumer<ImageClassificationProvider>(
            builder: (context, provider, child) {
              if (!provider.showCamera) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: _clearResults,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                    tooltip: 'Clear Results',
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            const ImageDisplayArea(),

            const SizedBox(height: 24),

            const ActionButtonsRow(),

            const SizedBox(height: 24),

            const ResultsSection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
