import '../repositories/i_product_repository.dart';
import '../models/product.dart';

class CreateProductUseCase {
  final IProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<void> execute(Product product) async {
    // 1. Regla de Negocio: Validar SKU
    final existingProduct = await _repository.getProductBySku(product.sku);
    if (existingProduct != null) {
      throw Exception("El SKU ${product.sku} ya existe.");
    }

    // 2. Regla de Negocio: Validar Stock inicial no negativo
    if (product.quantity < 0) {
      throw Exception("El stock no puede ser negativo.");
    }

    // 3. Persistir
    await _repository.saveProduct(product);
  }
}