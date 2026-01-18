import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Imports de tu proyecto
import 'package:inventory_app/infrastructure/database/database_helper.dart';
import 'package:inventory_app/infrastructure/repositories/sqlite_product_repository.dart';
import 'package:inventory_app/infrastructure/repositories/sqlite_category_repository.dart';
import 'package:inventory_app/domain/models/product.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/domain/models/product_filter.dart';
void main() {
  // Inicializar FFI para tests de escritorio/memoria
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late SQLiteProductRepository productRepo;
  late SQLiteCategoryRepository categoryRepo;

  setUp(() async {
    // 1. Abrimos una base de datos EN MEMORIA (se borra al terminar el test)
    db = await openDatabase(inMemoryDatabasePath, version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
      // Replicamos la creación de tablas que tienes en DatabaseHelper
      // (Idealmente, DatabaseHelper._onCreate debería ser público para reutilizarlo aquí)
      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sku TEXT UNIQUE NOT NULL,
          name TEXT NOT NULL,
          barcode TEXT,
          quantity INTEGER DEFAULT 0 CHECK(quantity >= 0),
          description TEXT,
          image_path TEXT,
          created_at TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE NOT NULL,
          description TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE product_categories (
          product_id INTEGER,
          category_id INTEGER,
          FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE,
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
          PRIMARY KEY (product_id, category_id)
        )
      ''');
    });

    // 2. Inyectamos la DB en memoria al Helper
    DatabaseHelper.setDatabase(db);

    // 3. Inicializamos los repositorios
    productRepo = SQLiteProductRepository();
    categoryRepo = SQLiteCategoryRepository();
  });

  tearDown(() async {
    await db.close();
  });

  group('Persistencia de Productos y Categorías', () {
    test('Debe guardar y recuperar un producto', () async {
      final newProduct = Product(sku: 'A001', name: 'Laptop', quantity: 5);
      
      await productRepo.saveProduct(newProduct);
      
      final products = await productRepo.getProducts(filter: ProductFilter());
      expect(products.length, 1);
      expect(products.first.name, 'Laptop');
      expect(products.first.id, isNotNull); // SQLite generó el ID
    });

    test('Debe relacionar Producto con Categoría y contar correctamente', () async {
      // 1. Crear Categoría
      final cat = Category(name: 'Electrónica');
      await categoryRepo.createCategory(cat);
      final categories = await categoryRepo.getAllCategories();

      // 2. Crear Producto asignado a esa Categoría
      final product = Product(
        sku: 'B002', 
        name: 'Mouse', 
        categories: [categories.first]
      );
      await productRepo.saveProduct(product);

      // 3. Verificar que el producto guardó la relación
      final savedProducts = await productRepo.getProducts(filter: ProductFilter());
      expect(savedProducts.length, 1);
      expect(savedProducts.first.id, isNotNull);
      
      // Nota: No verificamos 'categories' aquí porque getProducts usa Lazy Loading.
      // La persistencia de la relación se confirma en el paso 4 (conteo en categoría).

      // 4. Verificar que la categoría actualizó su conteo (JOIN logic)
      final updatedCategories = await categoryRepo.getAllCategories();
      expect(updatedCategories.first.productCount, 1);
    });

    test('Debe filtrar productos por categoría', () async {
      // Setup: Crear 2 categorías y 2 productos
      await categoryRepo.createCategory(Category(name: 'Cat1'));
      await categoryRepo.createCategory(Category(name: 'Cat2'));
      final cats = await categoryRepo.getAllCategories();
      
      await productRepo.saveProduct(Product(sku: 'P1', name: 'Prod1', categories: [cats[0]]));
      await productRepo.saveProduct(Product(sku: 'P2', name: 'Prod2', categories: [cats[1]]));

      // Test: Pedir solo productos de Cat1
      final cat1Products = await productRepo.getProducts(filter: ProductFilter(categoryId: cats[0].id!));
      
      expect(cat1Products.length, 1);
      expect(cat1Products.first.sku, 'P1');
    });
    
    test('Debe eliminar producto y actualizar conteo', () async {
      // Crear categoría y producto
      await categoryRepo.createCategory(Category(name: 'TestCat'));
      final cats = await categoryRepo.getAllCategories();
      await productRepo.saveProduct(Product(sku: 'DEL', name: 'Borrar', categories: [cats.first]));

      // Verificar existencia
      expect((await productRepo.getProducts(filter: ProductFilter())).length, 1);
      expect((await categoryRepo.getAllCategories()).first.productCount, 1);

      // Borrar
      final prodId = (await productRepo.getProducts(filter: ProductFilter())).first.id!;
      await productRepo.deleteProduct(prodId);

      // Verificar eliminación y conteo 0
      expect((await productRepo.getProducts(filter: ProductFilter())).isEmpty, true);
      expect((await categoryRepo.getAllCategories()).first.productCount, 0);
    });
  });
}