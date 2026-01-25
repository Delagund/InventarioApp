import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'inputs/custom_text_field.dart';
import 'forms/product_image_picker.dart';
import 'forms/category_selector_field.dart';

// ViewModels and Entities
import '../../domain/models/product.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_layout.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();

  final Set<int> _selectedCategoryIds = {};
  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryIds.isEmpty) {
      _showSnackbar('Por favor selecciona al menos una categoría');
      return;
    }

    final categoryVM = context.read<CategoryViewModel>();
    final productVM = context.read<ProductViewModel>();

    final selectedCategories = categoryVM.categories
        .where((c) => _selectedCategoryIds.contains(c.id))
        .toList();

    final newProduct = Product(
      id: null,
      sku: _skuController.text,
      name: _nameController.text,
      barcode: null,
      quantity: int.parse(_stockController.text),
      imagePath: _imagePath,
      categories: selectedCategories,
      createdAt: DateTime.now(),
    );

    final bool success = await productVM.addProduct(newProduct);

    if (!mounted) return;

    if (success) {
      await categoryVM.loadCategories();
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackbar('Producto guardado correctamente');
      }
    } else {
      _showSnackbar(
        productVM.errorMessage ?? 'Error desconocido',
        isError: true,
      );
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryViewModel>().categories;

    return AlertDialog(
      title: const Text(AppStrings.nuevoProducto),
      scrollable: true,
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProductImagePicker(
                imagePath: _imagePath,
                onImageSelected: (path) => setState(() => _imagePath = path),
              ),
              const SizedBox(height: AppLayout.spaceL),

              CustomTextField(
                controller: _nameController,
                label: AppStrings.nombreProducto,
                validator: (val) =>
                    val!.isEmpty ? AppStrings.errorRequerido : null,
              ),
              const SizedBox(height: AppLayout.spaceM),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _skuController,
                      label: AppStrings.sku,
                      validator: (val) =>
                          val!.isEmpty ? AppStrings.errorRequerido : null,
                    ),
                  ),
                  const SizedBox(width: AppLayout.spaceM),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: AppStrings.stockInicial,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) => (val == null || val.isEmpty)
                          ? AppStrings.errorRequerido
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppLayout.spaceL),

              CategorySelectorField(
                allCategories: categories,
                selectedCategoryIds: _selectedCategoryIds,
                onSelectionChanged: (id, selected) {
                  setState(() {
                    selected
                        ? _selectedCategoryIds.add(id)
                        : _selectedCategoryIds.remove(id);
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancelar),
        ),
        FilledButton(onPressed: _submit, child: const Text(AppStrings.guardar)),
      ],
    );
  }
}
