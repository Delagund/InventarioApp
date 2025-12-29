import 'package:flutter/material.dart';
import '../../domain/models/product.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_product_repository.dart';

class ProductViewModel extends ChangeNotifier {
  final IProductRepository repository;

  List<Product> _products = [];
  bool _isLoading = false;

  // Getters para que la UI pueda leer los datos pero no modificarlos directamente
  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductViewModel({required this.repository});

  // Cargar inicial de productos de la DB
  Future<void> loadProducts({Category? category}) async {
    _isLoading = true;
    notifyListeners(); // Avisa a la UI que muestre un círculo de carga

    try {
      if (category == null) {
        // Cargar todo si no hay categoría seleccionada
        _products = await repository.getAllProducts();
      } else {
        // Cargar filtrado
        _products = await repository.getProductsByCategory(category.id!);
      }
    } catch (e) {
      debugPrint("Error al cargar productos: $e");
    } finally {
    _isLoading = false;
    notifyListeners(); // Avisa a la UI que ya hay datos para mostrar
    }
  }

  // Agregar un producto y refrescar la lista
  Future<void> addProduct(Product product) async {
    await repository.saveProduct(product);
    await loadProducts(); // Recargamos la lista automáticamente
  }

  // Eliminar producto
  Future<void> deleteProduct(int id) async {
    await repository.deleteProduct(id);
    await loadProducts();
  }
}