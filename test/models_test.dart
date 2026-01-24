import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/infrastructure/models/product_model.dart';
import 'package:inventory_app/domain/models/category.dart';

void main() {
  group('Model Tests', () {
    final tProduct = Product(
      sku: 'ABC-123',
      name: 'Producto Test',
      quantity: 10,
      createdAt: DateTime(2023, 1, 1),
    );

    test('ProductModel debe convertirse a mapa correctamente', () {
      final model = ProductModel.fromEntity(tProduct);
      final map = model.toMap();

      expect(map['sku'], 'ABC-123');
      expect(map['name'], 'Producto Test');
      expect(map['quantity'], 10);
      expect(map['created_at'], isNotNull);
    });

    test('ProductModel debe crearse desde un mapa correctamente', () {
      final map = {
        'id': 1,
        'sku': 'XYZ-999',
        'name': 'Producto Desde DB',
        'quantity': 5,
        'created_at': DateTime(2023, 1, 1).toIso8601String(),
      };

      final model = ProductModel.fromMap(map);
      final productFromMap = model.toEntity();

      expect(productFromMap.id, 1);
      expect(productFromMap.sku, 'XYZ-999');
      expect(productFromMap.createdAt?.year, 2023);
    });

    test('Category copyWith crea una copia modificada', () {
      final cat = Category(id: 1, name: 'Original', description: 'Desc');
      final newCat = cat.copyWith(name: 'Modificado');

      expect(newCat.id, 1);
      expect(newCat.name, 'Modificado');
      expect(newCat.description, 'Desc');
    });
  });
}
