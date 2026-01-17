import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

// Importaciones de tu proyecto
import 'package:inventory_app/presentation/widgets/add_product_dialog.dart';
import 'package:inventory_app/presentation/viewmodels/product_viewmodel.dart';
import 'package:inventory_app/presentation/viewmodels/category_viewmodel.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/domain/models/product.dart';
// Generamos mocks para los ViewModels
// (Recuerda ejecutar build_runner de nuevo si agregas esto)
@GenerateNiceMocks([
  MockSpec<ProductViewModel>(),
  MockSpec<CategoryViewModel>(),
])
import 'add_product_dialog_test.mocks.dart';

void main() {
  late MockProductViewModel mockProductViewModel;
  late MockCategoryViewModel mockCategoryViewModel;

  setUp(() {
    mockProductViewModel = MockProductViewModel();
    mockCategoryViewModel = MockCategoryViewModel();

    // Configuración por defecto para los mocks
    // Cuando la UI pida categorías, devolvemos una lista de prueba
    when(mockCategoryViewModel.categories).thenReturn([
      Category(id: 1, name: 'Categoría Prueba', description: 'Desc'),
      Category(id: 2, name: 'Otra Cat', description: 'Desc'),
    ]);
  });

  // Función helper para montar el widget con sus Providers
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProductViewModel>.value(value: mockProductViewModel),
        ChangeNotifierProvider<CategoryViewModel>.value(value: mockCategoryViewModel),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: AddProductDialog(),
        ),
      ),
    );
  }

  testWidgets('Debe mostrar validaciones si intentas guardar vacío', (WidgetTester tester) async {
    // 1. Renderizar el widget
    await tester.pumpWidget(createWidgetUnderTest());

    // 2. Buscar el botón Guardar y pulsarlo
    final saveButton = find.text('Guardar Producto');
    await tester.tap(saveButton);
    await tester.pump(); // Re-renderizar para mostrar errores

    // 3. Verificar que aparecen los mensajes de error
    expect(find.text('Requerido'), findsNWidgets(3)); // Nombre, SKU y Stock
    // Verifica que NO se llamó a addProduct
    verifyNever(mockProductViewModel.addProduct(any));
  });

  testWidgets('Debe llamar a addProduct cuando el formulario es válido', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // 1. Llenar el formulario
    // Encontrar campos por label o tipo
    await tester.enterText(find.widgetWithText(TextFormField, 'Nombre del Producto'), 'Nuevo Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'SKU'), 'SKU-123');
    await tester.enterText(find.widgetWithText(TextFormField, 'Stock Inicial'), '50');

    // 2. Seleccionar Categoría (FilterChip)
    // Buscamos el Chip por el texto de la categoría mockeada
    await tester.tap(find.text('Categoría Prueba'));
    await tester.pump(); // Actualizar estado visual del chip

    // 3. Pulsar Guardar
    await tester.tap(find.text('Guardar Producto'));
    await tester.pump(); // Procesar el callback

    // 4. Verificar que se llamó al método del ViewModel con los datos correctos
    // Capturamos el argumento pasado a addProduct
    final capturedCall = verify(mockProductViewModel.addProduct(captureAny)).captured;
    final createdProduct = capturedCall.first as Product;

    expect(createdProduct.name, 'Nuevo Item');
    expect(createdProduct.sku, 'SKU-123');
    expect(createdProduct.quantity, 50);
    expect(createdProduct.categories?.first.id, 1);
  });
}