import 'package:flutter/material.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/models/product_filter.dart';

class ProductViewModel extends ChangeNotifier {
  final CreateProductUseCase _createProductUseCase; // Inyectamos el Caso de Uso
  final IProductRepository _repository; // Inyectamos el Repositorio

  // Estado interno
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para que la UI pueda leer los datos pero no modificarlos directamente
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Ahora inyectamos el Caso de Uso además del Repositorio
  ProductViewModel({
    required IProductRepository repository,
  })  : _repository = repository,
        _createProductUseCase = CreateProductUseCase(repository);

  // Cargar inicial de productos de la DB aplicando filtros
  Future<void> loadProducts({ProductFilter? filter}) async {
    _setLoading(true); // Usamos el setter para notificar a la UI
    _errorMessage = null;

    try {
      // Delegamos toda la lógica al repositorio.
      // El repositorio ya sabe combinar búsqueda + categoría + ordenamiento en SQL.
      _products = await _repository.getProducts(
        filter: filter ?? ProductFilter(),
      );
    } catch (e) {
      _errorMessage = "Error al cargar productos: $e";
      debugPrint(_errorMessage);

    } finally {
      _setLoading(false);
    }
  }

  // Agregar un producto y refrescar la lista
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    
    try {
      // Delegamos toda la lógica al caso de uso
      await _createProductUseCase.execute(product);
      // Si pasa sin excepciones, recargamos la lista
      await loadProducts();
      return true;

    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception: ", "");
      debugPrint(_errorMessage);
      return false;

    } finally {
      _setLoading(false);
    }
  }


  // Eliminar producto
  Future<void> deleteProduct(int id) async {
    _isLoading = true;

    try {
      await _repository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      _errorMessage = "Error al eliminar: $e";
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false); // Usamos el helper para evitar repetir notifyListeners
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  // TODO: Borrar lineas siguientes si no se usan
  /*
  // Verificar si un SKU ya existe en la base de datos
  Future<bool> checkSkuExists(String sku) async {
    final product = await repository.getProductBySku(sku);
    return product != null;
  }*/
}