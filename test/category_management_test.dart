import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:inventory_app/domain/models/category.dart';
import 'package:inventory_app/domain/repositories/i_category_repository.dart';
import 'package:inventory_app/presentation/viewmodels/category_viewmodel.dart';

@GenerateMocks([ICategoryRepository])
import 'category_management_test.mocks.dart';

void main() {
  late CategoryViewModel viewModel;
  late MockICategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockICategoryRepository();

    // Stub initial loadCategories called in constructor
    when(mockRepository.getAllCategories()).thenAnswer((_) async => []);

    viewModel = CategoryViewModel(repository: mockRepository);
  });

  group('CategoryViewModel Logic Tests', () {
    test('Initial state is correct', () async {
      expect(viewModel.categories, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('addCategory calls repository and reloads', () async {
      when(mockRepository.createCategory(any)).thenAnswer((_) async => 1);
      when(mockRepository.getAllCategories()).thenAnswer(
        (_) async => [Category(id: 1, name: 'New Cat', productCount: 0)],
      );

      await viewModel.addCategory('New Cat', null);

      verify(mockRepository.createCategory(any)).called(1);
      expect(viewModel.categories.length, 1);
      expect(viewModel.categories.first.name, 'New Cat');
    });

    test('deleteCategory updates selection if deleted', () async {
      final cat = Category(id: 1, name: 'Delete Me');
      viewModel.selectCategory(cat);

      when(mockRepository.deleteCategory(1)).thenAnswer((_) async => {});
      when(mockRepository.getAllCategories()).thenAnswer((_) async => []);

      await viewModel.deleteCategory(1);

      expect(viewModel.selectedCategory, isNull);
      verify(mockRepository.deleteCategory(1)).called(1);
    });
  });
}
