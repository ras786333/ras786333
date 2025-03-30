import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../screens/admin/edit_product_screen.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('എല്ലാ പ്രോഡക്റ്റുകളും'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final allProducts = productProvider.allProducts;

          if (allProducts.isEmpty) {
            return const Center(
              child: Text('പ്രോഡക്റ്റുകൾ ഒന്നും ഇല്ല'),
            );
          }

          return ListView.builder(
            itemCount: allProducts.length,
            itemBuilder: (context, index) {
              final product = allProducts[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    product.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error_outline);
                    },
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('വില: ₹${product.price.toStringAsFixed(2)}'),
                      Text('സ്റ്റോക്ക്: ${product.stock}'),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(product.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(product.status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: product.status == 'pending'
                      ? TextButton(
                          onPressed: () async {
                            await productProvider.updateProductStatus(
                              product.id,
                              'approved',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('പ്രോഡക്റ്റ് അംഗീകരിച്ചു'),
                                ),
                              );
                            }
                          },
                          child: const Text('അംഗീകരിക്കുക'),
                        )
                      : TextButton(
                          onPressed: () async {
                            final updatedProduct = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                  product: product,
                                ),
                              ),
                            );
                            if (updatedProduct != null) {
                              await Provider.of<ProductProvider>(context,
                                      listen: false)
                                  .updateProduct(updatedProduct);
                            }
                          },
                          child: const Text('തിരുത്തുക'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'അംഗീകരിച്ചു';
      case 'pending':
        return 'പെൻഡിംഗ്';
      default:
        return status;
    }
  }
}
