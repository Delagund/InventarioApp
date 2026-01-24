import 'package:flutter/foundation.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_filter.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/models/stock_transaction.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/models/stock_adjustment_reason.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logging_service.dart';

class ProductViewModel extends ChangeNotifier {
  final CreateProductUseCase _createProductUseCase;
  final IProductRepository _repository;
  final AdjustStockUseCase _adjustStockUseCase;

  ProductViewModel({
    required CreateProductUseCase createProductUseCase,
    required IProductRepository repository,
    required AdjustStockUseCase adjustStockUseCase,
  }) : _createProductUseCase = createProductUseCase,
       _repository = repository,
       _adjustStockUseCase = adjustStockUseCase;

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  Product? _selectedProduct;
  final Set<int> _selectedProductIds = {};
  bool _isSelectionMode = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Product? get selectedProduct => _selectedProduct;
  Set<int> get selectedProductIds => _selectedProductIds;
  bool get isSelectionMode => _isSelectionMode;

  void selectProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void toggleSelection(int productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
    notifyListeners();
  }

  // Alias for compatibility
  void toggleProductSelection(int productId) => toggleSelection(productId);

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedProductIds.clear();
    }
    notifyListeners();
  }

  Future<void> filterByCategory(int? categoryId) async {
    await loadProducts(filter: ProductFilter(categoryId: categoryId));
  }

  Future<void> loadProducts({ProductFilter? filter}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _products = await _repository.getProducts(
        filter: filter ?? ProductFilter(),
      );
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "${AppStrings.errorCargarProductos}: $e";
      LoggingService.error(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createProductUseCase.execute(product);
      await loadProducts();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;

    try {
      await _repository.deleteProduct(id);
      if (_selectedProduct?.id == id) {
        selectProduct(null);
      }
      await loadProducts();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "${AppStrings.errorEliminarProducto}: $e";
      LoggingService.error(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSelectedProducts() async {
    _setLoading(true);
    try {
      for (final id in _selectedProductIds) {
        await _repository.deleteProduct(id);
      }
      _selectedProductIds.clear();
      _isSelectionMode = false;
      await loadProducts();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "${AppStrings.errorEliminarProducto}: $e";
      LoggingService.error(_errorMessage!);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProductStock(
    int productId,
    int delta,
    StockAdjustmentReason reason,
  ) async {
    _setLoading(true);
    try {
      await _adjustStockUseCase.execute(
        productId: productId,
        quantityDelta: delta,
        reason: reason,
      );
      await loadProducts();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Alias for Inspector compatibility
  Future<bool> adjustStockFromInspector(
    int delta,
    StockAdjustmentReason reason,
  ) async {
    if (_selectedProduct == null) return false;
    return await updateProductStock(_selectedProduct!.id!, delta, reason);
  }

  Future<bool> updateProductDetails({
    String? name,
    String? sku,
    String? barcode,
    String? description,
    String? imagePath,
  }) async {
    if (_selectedProduct == null) return false;

    final updatedProduct = Product(
      id: _selectedProduct!.id,
      name: name ?? _selectedProduct!.name,
      sku: sku ?? _selectedProduct!.sku,
      barcode: barcode ?? _selectedProduct!.barcode,
      description: description ?? _selectedProduct!.description,
      quantity: _selectedProduct!.quantity,
      imagePath: imagePath ?? _selectedProduct!.imagePath,
      categories: _selectedProduct!.categories,
      createdAt: _selectedProduct!.createdAt,
    );

    try {
      await _repository.saveProduct(updatedProduct);
      _selectedProduct = updatedProduct;
      await loadProducts();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<StockTransaction> _history = [];
  List<StockTransaction> get history => _history;

  Future<void> loadHistory() async {
    if (_selectedProduct == null) return;
    try {
      _history = await _repository.getStockHistory(_selectedProduct!.id!);
      notifyListeners();
    } catch (e) {
      LoggingService.error("Error loading history", e);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
