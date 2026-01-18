import '../repositories/i_product_repository.dart';
import '../models/product.dart';
import '../models/product_filter.dart';

class CreateProductUseCase {
  final IProductRepository _repository;

  CreateProductUseCase(this._repository);

  Future<void> execute(Product product) async {
    // 1. Regla de Negocio: Validar SKU
    // Nota: getProducts usa búsqueda "LIKE" (parcial) en nombre y SKU.
    // Debemos verificar si existe una coincidencia EXACTA de SKU en los resultados.
    final potentialMatches = await _repository.getProducts(
      filter: ProductFilter(searchQuery: product.sku)
    );

    if (potentialMatches.any((p) => p.sku == product.sku)) {
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