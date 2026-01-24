import '../../domain/models/category.dart';

/// Entidad de dominio pura que representa un producto.
/// No contiene lógica de persistencia (SQLite, JSON, etc).
class Product {
  final int? id; // El ID que genera SQLite
  final String sku; // Tu código interno
  final String name;
  final String? barcode;
  final int quantity;
  final String? description;
  final String? imagePath;
  final DateTime? createdAt;
  final List<Category>? categories; // Categorías asociadas

  Product({
    this.id,
    required this.sku,
    required this.name,
    this.barcode,
    this.quantity = 0,
    this.description,
    this.imagePath,
    this.createdAt,
    this.categories = const [], // Por defecto, una lista vacía
  });

  // La clase es ahora una entidad pura de dominio.
  // El mapeo a persistencia se delegó a ProductModel en la capa de infraestructura.
}
