import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/domain/models/category.dart';
// Asegúrate de ajustar los imports según el nombre de tu paquete en pubspec.yaml

void main() {
  group('Model Tests', () {
    
    test('Product toMap devuelve mapa correcto', () {
      final product = Product(
        sku: 'ABC-123',
        name: 'Producto Test',
        quantity: 10,
        createdAt: DateTime(2023, 1, 1),
      );

      final map = product.toMap();

      expect(map['sku'], 'ABC-123');
      expect(map['name'], 'Producto Test');
      expect(map['quantity'], 10);
      expect(map['created_at'], isNotNull);
    });

    test('Product fromMap crea objeto correcto', () {
      final map = {
        'id': 1,
        'sku': 'XYZ-999',
        'name': 'Producto Desde DB',
        'quantity': 5,
        'created_at': DateTime(2023, 1, 1).toIso8601String(),
      };

      final product = Product.fromMap(map);

      expect(product.id, 1);
      expect(product.sku, 'XYZ-999');
      expect(product.createdAt?.year, 2023);
    });

    test('Category copyWith crea una copia modificada', () {
      final cat = Category(id: 1, name: 'Original', description: 'Desc');
      final newCat = cat.copyWith(name: 'Modificado');

      expect(newCat.id, 1); // Mantiene el ID
      expect(newCat.name, 'Modificado'); // Cambia el nombre
      expect(newCat.description, 'Desc'); // Mantiene descripción
    });
  });
}