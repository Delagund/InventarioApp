import '../models/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getAllCategories();
  Future<void> createCategory(Category category);
  Future<void> deleteCategory(int id);
}