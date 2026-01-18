import '../repositories/i_product_repository.dart';

class AdjustStockUseCase {
  final IProductRepository _repository;

  AdjustStockUseCase(this._repository);

  Future<void> execute({
    required int productId, 
    required int quantityDelta, 
    required String reason,
    String user = "Local_user",
  }) async {
    // Validaciones de negocio (opcional)
    if (quantityDelta == 0) {
      throw Exception("El ajuste no puede ser cero.");
    }

    // Aquí podrías validar si hay stock suficiente antes de restar (opcional)
    // final product = await _repository.getProductById(productId);
    // if (product.quantity + quantityDelta < 0) throw Exception("Stock insuficiente");

    await _repository.updateStock(productId, quantityDelta, reason, user: user);
  }
}