import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/product.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/constants/app_strings.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';

class CategoryEditor extends StatefulWidget {
  final Product product;

  const CategoryEditor({super.key, required this.product});

  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  bool _isEditing = false;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _syncCategories();
  }

  @override
  void didUpdateWidget(CategoryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product.id != oldWidget.product.id ||
        widget.product.categories != oldWidget.product.categories) {
      _syncCategories();
    }
  }

  void _syncCategories() {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(widget.product.categories?.map((c) => c.id!) ?? {});
    });
  }

  Future<void> _save(BuildContext context) async {
    final categoryVM = context.read<CategoryViewModel>();
    final productVM = context.read<ProductViewModel>();

    final selectedCategories = categoryVM.categories
        .where((c) => _selectedIds.contains(c.id))
        .toList();

    final success = await productVM.updateProductDetails(
      categories: selectedCategories,
    );

    if (success && context.mounted) {
      setState(() => _isEditing = false);
      context.read<CategoryViewModel>().loadCategories();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Categorías actualizadas")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.categoriasLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                if (_isEditing) {
                  _save(context);
                } else {
                  setState(() => _isEditing = true);
                }
              },
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit_outlined,
                size: 16,
              ),
              label: Text(_isEditing ? AppStrings.guardar : "Editar"),
            ),
          ],
        ),
        const SizedBox(height: AppLayout.spaceS),

        if (_isEditing)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: categoryVM.categories.map((cat) {
              final isSelected = _selectedIds.contains(cat.id);
              return FilterChip(
                label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIds.add(cat.id!);
                    } else {
                      _selectedIds.remove(cat.id!);
                    }
                  });
                },
              );
            }).toList(),
          )
        else if (widget.product.categories == null ||
            widget.product.categories!.isEmpty)
          Text(
            "Sin categorías",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.product.categories!.map((cat) {
              return Chip(
                label: Text(cat.name, style: const TextStyle(fontSize: 12)),
                backgroundColor: theme.colorScheme.secondaryContainer
                    .withValues(alpha: 0.5),
                side: BorderSide.none,
              );
            }).toList(),
          ),
      ],
    );
  }
}
