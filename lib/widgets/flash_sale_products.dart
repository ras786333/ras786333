import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'product_grid.dart';

class FlashSaleProducts extends StatefulWidget {
  const FlashSaleProducts({super.key});

  @override
  State<FlashSaleProducts> createState() => _FlashSaleProductsState();
}

class _FlashSaleProductsState extends State<FlashSaleProducts> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ഇനിപ്പോൾ ആവശ്യമില്ല, ഹോം സ്ക്രീനിൽ നിന്ന് ലോഡ് ചെയ്യുന്നു
  }

  void _loadFlashSaleProducts() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false)
        .getFlashSaleProducts()
        .then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final flashSaleProducts = productProvider.cachedFlashSaleProducts;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: const Text(
                      'ഫ്ലാഷ് സെയിൽ ഉൽപ്പന്നങ്ങൾ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    onPressed: _isLoading ? null : _loadFlashSaleProducts,
                    tooltip: 'റീലോഡ് ചെയ്യുക',
                  ),
                ],
              ),
            ),
            if (flashSaleProducts.isEmpty && !_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flash_off,
                        size: isSmallScreen ? 48 : 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ഫ്ലാഷ് സെയിൽ ഉൽപ്പന്നങ്ങൾ ഇല്ല',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 300, // Fixed height for products grid
                child: ProductGrid(products: flashSaleProducts),
              ),
          ],
        );
      },
    );
  }
}
