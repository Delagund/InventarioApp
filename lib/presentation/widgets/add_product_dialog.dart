import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// ViewModels and Entities
import '../../domain/models/category.dart';
import '../../domain/models/product.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';

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
    final XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'png', 'jpeg'],
      uniformTypeIdentifiers: <String>['public.jpg', 'public.png', 'public.jpeg'],
    );
    // Abre ventana nativa de macOS
    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[typeGroup]
    );
    
    if (file == null) {
      return;
    } else {
      try {
        // Copiamos la imagen a la carpeta de la aplicación para tener control sobre ella
        final appDir = await getApplicationDocumentsDirectory();
        // Definimos nuestra carpeta específica "product_images"
        final String folderPath = path.join(appDir.path, 'product_images');
        // Creamos la carpeta si no existe (esto asegura que siempre haya destino)
        final Directory folderDir = Directory(folderPath);
        if (!await folderDir.exists()) {
          await folderDir.create(recursive: true);
        }
        // Obtenemos el nombre original del archivo (ej: "foto.jpg")
        final String fileName = path.basename(file.path);
        // Agregamos un timestamp para evitar que dos fotos con el mismo nombre se reemplacen
        final String uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        // Definimos la ruta completa donde se guardará la imagen
        final String savedImagePath = path.join(folderPath, uniqueName);
        
        await file.saveTo(savedImagePath);

        if (!mounted) return; // Evita errores si el diálogo se cerró
        setState(() {
          _imagePath = savedImagePath;
        });
      } catch (e) {
        debugPrint('Error al guardar la imagen: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar la imagen seleccionada')),
          );
        }
      }
    }
  }

  // Lógica de Guardado
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 1. Validar lógica extra (ej. categoría obligatoria)
      if (_selectedCategoryIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona al menos una categoría')),
        );
        return;
      }

      // Obtenemos la lista de objetos Category basada en los IDs seleccionados
      final selectedCategories = context.read<CategoryViewModel>().categories
          .where((c) => _selectedCategoryIds.contains(c.id)).toList();

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
      // listen: false porque estamos dentro de un callback, no repintando
      context.read<ProductViewModel>().addProduct(newProduct);

      // 4. Cerrar el diálogo
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accedemos a las categorías para el Dropdown
    final categories = context.watch<CategoryViewModel>().categories;

    return AlertDialog(
      title: const Text('Nuevo Producto'),
      content: SizedBox(
        width: 400, // Ancho fijo cómodo para Desktop
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
                                child: Icon(Icons.broken_image, color: Colors.red),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              // --- CAMPOS DE TEXTO ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                validator: (value) => value!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skuController,
                      decoration: const InputDecoration(labelText: 'SKU'),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(labelText: 'Stock Inicial'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Requerido';
                        if (int.tryParse(value) == null) return 'Debe ser número';
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
                  labelText: 'Categorías',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Wrap(
                  spacing: 8.0,
                  children: categories.map((Category cat) {
                    return FilterChip(
                      label: Text(cat.name),
                      selected: _selectedCategoryIds.contains(cat.id),
                      onSelected: (bool selected) {
                        setState(() {
                          selected ? _selectedCategoryIds.add(cat.id!) : _selectedCategoryIds.remove(cat.id);
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar Producto'),
        ),
      ],
    );
  }
}