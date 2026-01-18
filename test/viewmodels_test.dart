import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:inventory_app/domain/repositories/i_product_repository.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/presentation/viewmodels/product_viewmodel.dart';
import 'package:inventory_app/domain/models/product_filter.dart';

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
    
    final tCategory = Category(
      id: 5, 
      name: 'Electrónica', 
      description: 'Gadgets'
    );

    test('El estado inicial debe ser correcto', () {
      expect(viewModel.products, []);
      expect(viewModel.isLoading, false);
    });

    test('loadProducts debe llenar la lista de productos', () async {
      // ARRANGE: Enseñamos al mock qué responder
      when(mockRepository.getProducts(filter: anyNamed('filter')))
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
      verify(mockRepository.getProducts(filter: anyNamed('filter'))).called(1);
    });

    test('loadProducts con categoría debe filtrar la lista', () async {
      // ARRANGE: Simulamos que el repo devuelve productos filtrados por ID 5
      when(mockRepository.getProducts(filter: anyNamed('filter')))
          .thenAnswer((_) async => [tProduct]);

      // ACT: Pedimos cargar productos pasando la categoría
      await viewModel.loadProducts(
        filter: ProductFilter(categoryId: tCategory.id),
      );

      // ASSERT: Verificamos que se llamó al método de filtrado y no al de "todos"
      verify(mockRepository.getProducts(filter: argThat(
        predicate<ProductFilter>((f) => f.categoryId == tCategory.id),
        named: 'filter'
      ))).called(1);
      expect(viewModel.products.length, 1);
    });

    test('addProduct debe guardar y recargar la lista', () async {
      // ARRANGE
      // 1. Mock para la validación de SKU (debe retornar vacío para permitir guardar)
      when(mockRepository.getProducts(filter: argThat(
        predicate<ProductFilter>((f) => f.searchQuery == tProduct.sku),
        named: 'filter'
      ))).thenAnswer((_) async => []);

      // 2. Mock para la recarga de lista (debe retornar el producto guardado)
      when(mockRepository.getProducts(filter: argThat(
        predicate<ProductFilter>((f) => f.searchQuery == null),
        named: 'filter'
      ))).thenAnswer((_) async => [tProduct]);

      // ACT
      await viewModel.addProduct(tProduct);

      // ASSERT
      verify(mockRepository.saveProduct(tProduct)).called(1);
      // Verificamos que se llamó a getProducts para recargar (filtro sin search query)
      verify(mockRepository.getProducts(filter: argThat(
        predicate<ProductFilter>((f) => f.searchQuery == null),
        named: 'filter'
      ))).called(1);
    });
  });
}