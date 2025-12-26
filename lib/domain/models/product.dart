import '../../domain/models/category.dart';

class Product {
  final int? id;         // El ID que genera SQLite
  final String sku;      // Tu código interno
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

  // Convierte un Producto en un Mapa para guardarlo en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sku': sku,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'description': description,
      'image_path': imagePath,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Crea un Producto a partir de un Mapa (cuando lo lees de SQLite)
  factory Product.fromMap(Map<String, dynamic> map, {List<Category> categories = const []}) {
    return Product(
      id: map['id'],
      sku: map['sku'],
      name: map['name'],
      barcode: map['barcode'],
      quantity: map['quantity'] ?? 0,
      description: map['description'],
      imagePath: map['image_path'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : null,
      categories: categories,
    );
  }
}