class Category {
  final int? id;         // El ID que genera SQLite
  final String name;
  final String? description;

  Category({
    this.id,
    required this.name,
    this.description,
  });

  // Para insertar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Para leer de SQLite
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
