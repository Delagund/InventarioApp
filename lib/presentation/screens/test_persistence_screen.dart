import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product.dart';
import '../viewmodels/product_viewmodel.dart';

class TestPersistenceScreen extends StatelessWidget {
  const TestPersistenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Test de Persistencia SQLite')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                // TEST: Crear un producto ficticio
                final testProduct = Product(
                  sku: "PROD-${DateTime.now().millisecond}",
                  name: "Producto de Prueba ${DateTime.now().second}",
                  quantity: 10,
                );
                
                await viewModel.addProduct(testProduct);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Producto guardado en tu Mac!'))
                );
              },
              child: const Text('Insertar Producto Aleatorio'),
            ),
          ),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: viewModel.products.length,
                    itemBuilder: (context, index) {
                      final p = viewModel.products[index];
                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text("SKU: ${p.sku} | Stock: ${p.quantity}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => viewModel.deleteProduct(p.id!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}