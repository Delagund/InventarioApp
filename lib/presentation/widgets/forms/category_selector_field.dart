import 'package:flutter/material.dart';
import '../../../domain/models/category.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_layout.dart';

class CategorySelectorField extends StatelessWidget {
  final List<Category> allCategories;
  final Set<int> selectedCategoryIds;
  final Function(int, bool) onSelectionChanged;

  const CategorySelectorField({
    super.key,
    required this.allCategories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppStrings.categoriasLabel,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerLow,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusM),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: allCategories.map((Category cat) {
          final isSelected = selectedCategoryIds.contains(cat.id);
          return FilterChip(
            label: Text(cat.name, style: const TextStyle(fontSize: 12)),
            selected: isSelected,
            onSelected: (bool selected) =>
                onSelectionChanged(cat.id!, selected),
            backgroundColor: Colors.transparent,
            selectedColor: theme.colorScheme.primaryContainer,
            checkmarkColor: theme.colorScheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppLayout.radiusS),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
