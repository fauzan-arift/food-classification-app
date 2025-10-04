import 'package:flutter/material.dart';

class MealDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String mealName;

  const MealDetailAppBar({super.key, required this.mealName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        mealName,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: Colors.orange.shade600,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
