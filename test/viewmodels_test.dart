import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:inventory_app/domain/repositories/i_product_repository.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/presentation/viewmodels/product_viewmodel.dart';
import 'package:inventory_app/domain/models/product_filter.dart';
import 'package:inventory_app/domain/usecases/create_product_usecase.dart';
import 'package:inventory_app/domain/usecases/adjust_stock_usecase.dart';

// Genera el código para MockIProductRepository
// Ejecuta en terminal: flutter pub run build_runner build
@GenerateNiceMocks([
  MockSpec<IProductRepository>(),
  MockSpec<CreateProductUseCase>(),
  MockSpec<AdjustStockUseCase>(),
])
import 'viewmodels_test.mocks.dart';

void main() {
  late ProductViewModel viewModel;
  late MockIProductRepository mockRepository;
  late MockCreateProductUseCase mockCreateUseCase;
  late MockAdjustStockUseCase mockAdjustUseCase;

  setUp(() {
    mockRepository = MockIProductRepository();
    mockCreateUseCase = MockCreateProductUseCase();
    mockAdjustUseCase = MockAdjustStockUseCase();

    viewModel = ProductViewModel(
      createProductUseCase: mockCreateUseCase,
      repository: mockRepository,
      adjustStockUseCase: mockAdjustUseCase,
    );
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
      description: 'Gadgets',
    );

    test('El estado inicial debe ser correcto', () {
      expect(viewModel.products, []);
      expect(viewModel.isLoading, false);
    });

    test('loadProducts debe llenar la lista de productos', () async {
      // ARRANGE: Enseñamos al mock qué responder
      when(
        mockRepository.getProducts(filter: anyNamed('filter')),
      ).thenAnswer((_) async => [tProduct]);

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
      when(
        mockRepository.getProducts(filter: anyNamed('filter')),
      ).thenAnswer((_) async => [tProduct]);

      // ACT: Pedimos cargar productos pasando la categoría
      await viewModel.loadProducts(
        filter: ProductFilter(categoryId: tCategory.id),
      );

      // ASSERT: Verificamos que se llamó al método de filtrado y no al de "todos"
      verify(
        mockRepository.getProducts(
          filter: argThat(
            predicate<ProductFilter>((f) => f.categoryId == tCategory.id),
            named: 'filter',
          ),
        ),
      ).called(1);
      expect(viewModel.products.length, 1);
    });

    test('addProduct debe guardar y recargar la lista', () async {
      // ARRANGE
      // 1. Mock para la validación de SKU (debe retornar vacío para permitir guardar)
      when(
        mockRepository.getProducts(
          filter: argThat(
            predicate<ProductFilter>((f) => f.searchQuery == tProduct.sku),
            named: 'filter',
          ),
        ),
      ).thenAnswer((_) async => []);

      // 2. Mock para la recarga de lista (debe retornar el producto guardado)
      when(
        mockRepository.getProducts(
          filter: argThat(
            predicate<ProductFilter>((f) => f.searchQuery == null),
            named: 'filter',
          ),
        ),
      ).thenAnswer((_) async => [tProduct]);

      // ACT
      await viewModel.addProduct(tProduct);

      // ASSERT
      // Ahora el ViewModel delega al UseCase, no al repositorio directamente
      verify(mockCreateUseCase.execute(tProduct)).called(1);

      // Verificamos que se llamó a getProducts para recargar (filtro sin search query)
      verify(
        mockRepository.getProducts(
          filter: argThat(
            predicate<ProductFilter>((f) => f.searchQuery == null),
            named: 'filter',
          ),
        ),
      ).called(1);
    });

    test(
      'toggleSelectionMode debe cambiar el modo y limpiar selección al salir',
      () {
        viewModel.toggleSelectionMode(); // Entrar
        expect(viewModel.isSelectionMode, true);

        viewModel.toggleProductSelection(1);
        expect(viewModel.selectedProductIds.length, 1);

        viewModel.toggleSelectionMode(); // Salir
        expect(viewModel.isSelectionMode, false);
        expect(viewModel.selectedProductIds.isEmpty, true);
      },
    );

    test('toggleProductSelection debe añadir o quitar IDs', () {
      viewModel.toggleProductSelection(1);
      expect(viewModel.selectedProductIds.contains(1), true);

      viewModel.toggleProductSelection(1);
      expect(viewModel.selectedProductIds.contains(1), false);
    });

    test(
      'deleteSelectedProducts debe eliminar todos los seleccionados y recargar',
      () async {
        // ARRANGE
        viewModel.toggleProductSelection(1);
        viewModel.toggleProductSelection(2);

        when(
          mockRepository.getProducts(filter: anyNamed('filter')),
        ).thenAnswer((_) async => []);

        // ACT
        await viewModel.deleteSelectedProducts();

        // ASSERT
        verify(mockRepository.deleteProduct(1)).called(1);
        verify(mockRepository.deleteProduct(2)).called(1);
        expect(viewModel.selectedProductIds.isEmpty, true);
        expect(viewModel.isSelectionMode, false);
        verify(
          mockRepository.getProducts(filter: anyNamed('filter')),
        ).called(1);
      },
    );
  });
}
