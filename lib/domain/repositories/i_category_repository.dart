import '../models/category.dart';

abstract class ICategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<void> createCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<void> updateCategory(Category category);
}
