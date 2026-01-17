import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:inventory_app/domain/repositories/i_product_repository.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/presentation/viewmodels/product_viewmodel.dart';

// Genera el código para MockIProductRepository
// Ejecuta en terminal: flutter pub run build_runner build
@GenerateNiceMocks([MockSpec<IProductRepository>()])
import 'viewmodels_test.mocks.dart';

void main() {
  late ProductViewModel viewModel;
  late MockIProductRepository mockRepository;

  setUp(() {
    mockRepository = MockIProductRepository();
    viewModel = ProductViewModel(repository: mockRepository);
  });

  group('ProductViewModel Tests', () {
    final tProduct = Product(
      id: 1,
      sku: 'TEST-001',
      name: 'Producto Test',
      quantity: 10,
      createdAt: DateTime.now(),
    );

    test('El estado inicial debe ser correcto', () {
      expect(viewModel.products, []);
      expect(viewModel.isLoading, false);
    });

    test('loadProducts debe llenar la lista de productos', () async {
      // ARRANGE: Enseñamos al mock qué responder
      when(mockRepository.getAllProducts())
          .thenAnswer((_) async => [tProduct]);

      // ACT: Ejecutamos la acción
      // Nota: loadProducts no retorna la lista, actualiza el estado interno
      final future = viewModel.loadProducts();
      
      // Verificamos que isLoading sea true mientras carga (opcional/complejo por asincronía)
      expect(viewModel.isLoading, true);
      
      await future;

      // ASSERT: Verificamos el resultado final
      expect(viewModel.isLoading, false);
      expect(viewModel.products.length, 1);
      expect(viewModel.products.first.name, 'Producto Test');
      // Verificamos que el repositorio fue llamado una vez
      verify(mockRepository.getAllProducts()).called(1);
    });

    test('addProduct debe guardar y recargar la lista', () async {
      // ARRANGE
      when(mockRepository.getAllProducts())
          .thenAnswer((_) async => [tProduct]); // Simula que ya se guardó y lo devuelve

      // ACT
      await viewModel.addProduct(tProduct);

      // ASSERT
      verify(mockRepository.saveProduct(tProduct)).called(1);
      verify(mockRepository.getAllProducts()).called(1); // loadProducts se llama al final de addProduct
    });
  });
}