import 'package:flutter/material.dart';
import '../../domain/models/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../../core/constants/app_strings.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/services/logging_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final ICategoryRepository _repository;

  // Estado
  List<Category> _categories = [];
  Category?
  _selectedCategory; // Null representa "Todos los productos" o "General"
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryViewModel({required ICategoryRepository repository})
    : _repository = repository {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.getAllCategories();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = AppStrings.errorCargarCategorias;
      LoggingService.error("Error loading categories", e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(Category? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String name, String? description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newCategory = Category(name: name, description: description);
      await _repository.createCategory(newCategory);
      await loadCategories();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "${AppStrings.errorCargarCategorias}: $e";
      LoggingService.error(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(int id, String newName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final category = _categories.firstWhere((c) => c.id == id);
      final updatedCategory = category.copyWith(name: newName);
      await _repository.updateCategory(updatedCategory);

      // Si la categoría editada era la seleccionada, actualizamos la referencia
      if (_selectedCategory?.id == id) {
        _selectedCategory = updatedCategory;
      }

      await loadCategories();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "Error al actualizar categoría: $e";
      LoggingService.error(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCategory(id);
      if (_selectedCategory?.id == id) {
        _selectedCategory = null;
      }
      await loadCategories();
    } on AppException catch (e) {
      _errorMessage = e.toString();
      LoggingService.error(_errorMessage!);
    } catch (e) {
      _errorMessage = "${AppStrings.errorEliminarCategoria}: $e";
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
