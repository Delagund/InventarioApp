import 'package:get_it/get_it.dart';

// Imports de Dominio (Interfaces, UseCases)
import 'domain/repositories/i_product_repository.dart';
import 'domain/repositories/i_category_repository.dart';
import 'domain/usecases/create_product_usecase.dart';
import 'domain/usecases/adjust_stock_usecase.dart'; // Del paso anterior

// Imports de Infraestructura (Implementaciones)
import 'infrastructure/repositories/sqlite_product_repository.dart';
import 'infrastructure/repositories/sqlite_category_repository.dart';

// Imports de Presentación (ViewModels)
import 'presentation/viewmodels/product_viewmodel.dart';
import 'presentation/viewmodels/category_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // --- 1. ViewModels (Factory) ---
  // La UI los pedirá. GetIt inyectará automáticamente los repos/usecases necesarios.
  getIt.registerFactory(
    () => ProductViewModel(
      createProductUseCase: getIt(),
      repository: getIt(),
      adjustStockUseCase: getIt(),
    ),
  );

  getIt.registerFactory(() => CategoryViewModel(repository: getIt()));

  // --- 2. Casos de Uso (Lazy Singleton) ---
  // Solo necesitamos una instancia de la lógica pura.
  getIt.registerLazySingleton(() => CreateProductUseCase(getIt()));

  // Si implementaste el AdjustStockUseCase del paso 2, regístralo aquí:
  getIt.registerLazySingleton(() => AdjustStockUseCase(getIt()));

  // --- 3. Repositorios (Lazy Singleton) ---
  // La implementación concreta (SQLite) se oculta tras la interfaz.
  getIt.registerLazySingleton<IProductRepository>(
    () => SQLiteProductRepository(),
  );

  getIt.registerLazySingleton<ICategoryRepository>(
    () => SQLiteCategoryRepository(),
  );
}
