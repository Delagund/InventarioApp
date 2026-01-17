import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository;

  // Estado
  List<Category> _categories = [];
  Category? _selectedCategory; // Null representa "Todos los productos" o "General"
  bool _isLoading = false;

  // Getters
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  CategoryViewModel({required CategoryRepository repository}) : _repository = repository {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Aquí se invoca al repositorio que ya calcula el productCount mediante JOIN
      _categories = await _repository.getAllCategories(); 
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Selección de categoría para filtrado en el Dashboard
  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String name, String? description) async {
    final newCategory = Category(name: name, description: description);
    await _repository.createCategory(newCategory);
    await loadCategories(); // Recargamos para actualizar la lista y los conteos
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    // Si la categoría eliminada estaba seleccionada, deseleccionamos
    if (_selectedCategory?.id == id) {
      _selectedCategory = null;
    }
    await loadCategories();
  }
}