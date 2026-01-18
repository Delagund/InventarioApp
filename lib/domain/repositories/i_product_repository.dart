import '../models/product.dart';
import '../models/stock_transaction.dart';
import '../models/product_filter.dart';

/// Definimos la interfaz como una clase abstracta.

abstract class IProductRepository {
  
  // Obtener productos con filtros dinámicos.
  Future<List<Product>> getProducts({required ProductFilter filter});

  // Guardar un nuevo producto o actualizar uno existente
  Future<void> saveProduct(Product product);

  // Eliminar un producto
  Future<void> deleteProduct(int id);

  // Buscar productos que coincidan con un término (nombre o SKU)
  Future<List<Product>> searchProducts(String query);

  // Vincular un producto con una categoría (en la tabla pivot)
  Future<void> addCategoryToProduct(int productId, int categoryId);

  // Desvincular un producto de una categoría
  Future<void> removeCategoryFromProduct(int productId, int categoryId);

  // Actualizar el stock de un producto
  Future<void> updateStock(int productId, int quantityDelta, String reason, {String user});

  Future<List<StockTransaction>> getStockHistory(int productId);
}