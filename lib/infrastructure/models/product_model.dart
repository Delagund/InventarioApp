import '../../domain/models/product.dart';
import '../../domain/models/category.dart';
import '../database/schema_constants.dart';

/// Modelo exclusivo de la capa de infraestructura para el mapeo con SQLite.
/// Aísla a la entidad de dominio 'Product' de los detalles de persistencia.
class ProductModel {
  final int? id;
  final String sku;
  final String name;
  final String? barcode;
  final int quantity;
  final String? description;
  final String? imagePath;
  final DateTime? createdAt;

  ProductModel({
    this.id,
    required this.sku,
    required this.name,
    this.barcode,
    required this.quantity,
    this.description,
    this.imagePath,
    this.createdAt,
  });

  /// Convierte el modelo en un Mapa para SQLite usando las constantes de esquema.
  Map<String, dynamic> toMap() {
    return {
      SchemaConstants.columnProductId: id,
      SchemaConstants.columnProductSku: sku,
      SchemaConstants.columnProductName: name,
      SchemaConstants.columnProductBarcode: barcode,
      SchemaConstants.columnProductQuantity: quantity,
      SchemaConstants.columnProductDescription: description,
      SchemaConstants.columnProductImagePath: imagePath,
      SchemaConstants.columnProductCreatedAt:
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  /// Crea un modelo a partir de un Mapa de SQLite.
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map[SchemaConstants.columnProductId],
      sku: map[SchemaConstants.columnProductSku],
      name: map[SchemaConstants.columnProductName],
      barcode: map[SchemaConstants.columnProductBarcode],
      quantity: map[SchemaConstants.columnProductQuantity] ?? 0,
      description: map[SchemaConstants.columnProductDescription],
      imagePath: map[SchemaConstants.columnProductImagePath],
      createdAt: map[SchemaConstants.columnProductCreatedAt] != null
          ? DateTime.parse(map[SchemaConstants.columnProductCreatedAt])
          : null,
    );
  }

  /// Convierte este modelo de infraestructura en una entidad de dominio.
  Product toEntity({List<Category> categories = const []}) {
    return Product(
      id: id,
      sku: sku,
      name: name,
      barcode: barcode,
      quantity: quantity,
      description: description,
      imagePath: imagePath,
      createdAt: createdAt,
      categories: categories,
    );
  }

  /// Crea un modelo de infraestructura a partir de una entidad de dominio.
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      sku: entity.sku,
      name: entity.name,
      barcode: entity.barcode,
      quantity: entity.quantity,
      description: entity.description,
      imagePath: entity.imagePath,
      createdAt: entity.createdAt,
    );
  }
}
