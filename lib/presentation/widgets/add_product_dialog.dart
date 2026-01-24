import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'inputs/custom_text_field.dart';

// ViewModels and Entities
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../../infrastructure/services/image_picker_service.dart';
import '../../core/constants/app_strings.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para capturar el texto
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();

  // Estado local para selecciones
  final Set<int> _selectedCategoryIds = {};
  String? _imagePath;

  @override
  void dispose() {
    // ¡Siempre limpia los controladores!
    _nameController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Lógica para seleccionar imagen en macOS y guardarla en la carpeta de la App
  Future<void> _pickImage() async {
    // 1. Llamamos al servicio reutilizable
    final newPath = await ImagePickerService.selectAndSaveImage();

    // 2. Si hay resultado, actualizamos el estado visual del diálogo
    if (newPath != null && mounted) {
      setState(() {
        _imagePath = newPath;
      });
    } else if (newPath == null && mounted) {
      // Opcional: Manejar cancelación o error silencioso
    }
  }

  // Lógica de Guardado
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      // 1. Validar lógica extra (ej. categoría obligatoria)
      if (_selectedCategoryIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona al menos una categoría'),
          ),
        );
        return;
      }

      if (_stockController.text.isEmpty ||
          int.parse(_stockController.text) < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El stock inicial no puede estar vacío o ser negativo',
            ),
          ),
        );
        return;
      }

      // Capturamos las referencias antes de los await para no depender del context entre pausas
      final categoryVM = context.read<CategoryViewModel>();
      final productVM = context.read<ProductViewModel>();

      // Obtenemos la lista de objetos Category basada en los IDs seleccionados
      final selectedCategories = categoryVM.categories
          .where((c) => _selectedCategoryIds.contains(c.id))
          .toList();

      // 2. Crear el objeto Producto (Dominio)
      // Nota: Asumimos ID 0 o null si es autoincremental en DB
      final newProduct = Product(
        id: null,
        sku: _skuController.text,
        name: _nameController.text,
        barcode: null, // Puede ser null
        quantity: int.parse(_stockController.text),
        description: null,
        imagePath: _imagePath, // Puede ser null
        categories: selectedCategories,
        createdAt: DateTime.now(),
      );

      // 3. Llamar al ViewModel
      // Ejecutamos las operaciones asíncronas secuencialmente
      final bool success = await productVM.addProduct(newProduct);

      if (!mounted) return;

      if (success) {
        // --- CASO ÉXITO ---
        // Actualizamos conteos de categorías si es necesario
        await categoryVM.loadCategories();

        if (mounted) {
          Navigator.of(context).pop(); // Cerramos el diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto guardado correctamente')),
          );
        }
      } else {
        // --- CASO ERROR (Validación de Negocio) ---
        // No cerramos el diálogo. Mostramos el error que capturó el ViewModel.
        final String errorMsg =
            productVM.errorMessage ?? 'Error desconocido al guardar';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accedemos a las categorías para el Dropdown
    final categories = context.watch<CategoryViewModel>().categories;

    return AlertDialog(
      title: const Text(AppStrings.nuevoProducto),
      content: SizedBox(
        width: 400, // Ancho fijo cómodo para Desktop
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- SELECCIÓN DE IMAGEN ---
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                              // Esto muestra un icono si no se puede leer la imagen (por permisos o ruta inválida)
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- CAMPOS DE TEXTO ---
                CustomTextField(
                  controller: _nameController,
                  label: AppStrings.nombreProducto,
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.errorRequerido : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _skuController,
                        label: AppStrings.sku,
                        validator: (value) =>
                            value!.isEmpty ? AppStrings.errorRequerido : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _stockController,
                        label: AppStrings.stockInicial,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return AppStrings.errorRequerido;
                          if (int.tryParse(value) == null)
                            return AppStrings.errorNumero;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // --- SELECCIÓN MÚLTIPLE DE CATEGORÍAS ---
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: AppStrings.categoriasLabel,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    children: categories.map((Category cat) {
                      return FilterChip(
                        label: Text(cat.name),
                        selected: _selectedCategoryIds.contains(cat.id),
                        onSelected: (bool selected) {
                          setState(() {
                            selected
                                ? _selectedCategoryIds.add(cat.id!)
                                : _selectedCategoryIds.remove(cat.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancelar),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(AppStrings.guardarProducto),
        ),
      ],
    );
  }
}
