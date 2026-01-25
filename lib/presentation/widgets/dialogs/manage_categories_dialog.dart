import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../../core/constants/app_strings.dart';

class ManageCategoriesDialog extends StatefulWidget {
  const ManageCategoriesDialog({super.key});

  @override
  State<ManageCategoriesDialog> createState() => _ManageCategoriesDialogState();
}

class _ManageCategoriesDialogState extends State<ManageCategoriesDialog> {
  final _addController = TextEditingController();
  int? _editingId;
  final _editController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _onAdd(BuildContext context) {
    if (_addController.text.isNotEmpty) {
      context.read<CategoryViewModel>().addCategory(_addController.text, null);
      _addController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _onSaveEdit(BuildContext context, int id) {
    if (_editController.text.isNotEmpty) {
      context.read<CategoryViewModel>().updateCategory(
        id,
        _editController.text,
      );
      setState(() => _editingId = null);
    }
  }

  void _showDeleteConfirm(BuildContext context, int categoryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.eliminarCategoria),
        content: const Text(AppStrings.confirmarEliminarCategoria),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancelar),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              context.read<CategoryViewModel>().deleteCategory(categoryId);
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.eliminar),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<CategoryViewModel>();
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.gestionarCategorias,
                  style: theme.textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input para añadir
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addController,
                    decoration: const InputDecoration(
                      hintText: AppStrings.nuevaCategoria,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _onAdd(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _onAdd(context),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de categorías
            Flexible(
              child: categoryVM.isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: categoryVM.categories.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final category = categoryVM.categories[index];
                        final isEditing = _editingId == category.id;

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: isEditing
                              ? TextField(
                                  controller: _editController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) =>
                                      _onSaveEdit(context, category.id!),
                                )
                              : Text(category.name),
                          subtitle: isEditing
                              ? null
                              : Text(
                                  "${category.productCount} productos",
                                  style: theme.textTheme.bodySmall,
                                ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isEditing) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                  onPressed: () =>
                                      _onSaveEdit(context, category.id!),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      setState(() => _editingId = null),
                                ),
                              ] else ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _editController.text = category.name;
                                    setState(() => _editingId = category.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                  ),
                                  color: theme.colorScheme.error,
                                  onPressed: () =>
                                      _showDeleteConfirm(context, category.id!),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
