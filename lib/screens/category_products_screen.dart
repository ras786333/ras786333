import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_grid.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          final products = productProvider.products
              .where((product) => product.category == category)
              .toList();

          if (products.isEmpty) {
            return const Center(
              child: Text('ഈ വിഭാഗത്തിൽ ഉൽപ്പന്നങ്ങൾ ഇല്ല'),
            );
          }

          return ProductGrid(products: products);
        },
      ),
    );
  }
}
