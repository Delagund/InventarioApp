class Category {
  final int? id;         // El ID que genera SQLite
  final String name;     // Nombre de la categoría
  final String? description;  // Descripción opcional
  final int productCount; // Número de productos en esta categoría

  Category({
    this.id,
    required this.name,
    this.description,
    this.productCount = 0, // Valor por defecto 0
  });

  // Permite crear una copia modificando solo ciertos campos (Inmutabilidad)
  Category copyWith({
    int? id,
    String? name,
    String? description,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      productCount: productCount ?? this.productCount,
    );
  }
}