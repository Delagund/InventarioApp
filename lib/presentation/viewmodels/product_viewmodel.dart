import 'package:flutter/material.dart';
import '../../domain/models/product.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';

class ProductViewModel extends ChangeNotifier {
  final CreateProductUseCase _createProductUseCase; // Inyectamos el Caso de Uso
  final IProductRepository _repository; // Inyectamos el Repositorio
  final AdjustStockUseCase _adjustStockUseCase; // Inyectamos el Caso de Uso para ajustar stock

  // Estado interno
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  //Propiedad de producto seleccionado
  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct; //getter

  // Getters para que la UI pueda leer los datos pero no modificarlos directamente
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Ahora inyectamos el Caso de Uso además del Repositorio
  ProductViewModel({
    required IProductRepository repository,
  })  : _repository = repository,
        _createProductUseCase = CreateProductUseCase(repository),
        _adjustStockUseCase = AdjustStockUseCase(repository);

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

  Future<bool> updateProductStock(int productId, int delta, String reason) async {
    _setLoading(true);
    try {
      await _adjustStockUseCase.execute(
        productId: productId, 
        quantityDelta: delta, 
        reason: reason
      );
      await loadProducts(); // Recargar para ver el nuevo stock en la Grid
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      return false;
      
    } finally {
      _setLoading(false);
    }
  }

  // Método para seleccionar un producto
  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // método auxiliar para establecer el estado de carga y notificar a los oyentes
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}