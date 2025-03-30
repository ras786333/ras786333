import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;

  const ProductGrid({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSmallScreen = screenSize.width < 600;

    // Grid layout
    final crossAxisCount = screenSize.width < 600
        ? 2
        : screenSize.width < 900
            ? 3
            : 4;

    final crossAxisSpacing = isSmallScreen ? 8.0 : 12.0;
    final mainAxisSpacing = isSmallScreen ? 8.0 : 12.0;
    final padding = isSmallScreen ? 8.0 : 12.0;

    // Dynamically calculate aspect ratio based on screen size
    final screenHeight = screenSize.height;
    final itemWidth = (screenSize.width -
            (padding * 2) -
            (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;
    final desiredItemHeight =
        itemWidth * 1.5; // Adjust this multiplier as needed
    final availableHeight = screenHeight -
        (MediaQuery.of(context).padding.top +
            MediaQuery.of(context).padding.bottom);
    final childAspectRatio = itemWidth /
        (desiredItemHeight > availableHeight / 3
            ? availableHeight / 3
            : desiredItemHeight);

    // Base font sizes - reduced for better fit
    final baseTitleSize = isSmallScreen ? 14.0 : 16.0;
    final basePriceSize = isSmallScreen ? 16.0 : 18.0;
    final baseStockSize = isSmallScreen ? 10.0 : 12.0;

    // Responsive font sizes with max constraints
    final titleFontSize = (isSmallScreen
            ? baseTitleSize * textScale
            : (baseTitleSize + 1.0) * textScale)
        .clamp(12.0, 18.0);
    final priceFontSize = (isSmallScreen
            ? basePriceSize * textScale
            : (basePriceSize + 1.0) * textScale)
        .clamp(14.0, 20.0);
    final stockFontSize = (isSmallScreen
            ? baseStockSize * textScale
            : (baseStockSize + 1.0) * textScale)
        .clamp(10.0, 14.0);

    // Calculate image dimensions
    final imageSize = (screenSize.width -
            (padding * 2) -
            (crossAxisSpacing * (crossAxisCount - 1))) /
        crossAxisCount;
    final cacheSize =
        (imageSize * MediaQuery.of(context).devicePixelRatio).toInt();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    productId: product.id,
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: product.id,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          cacheWidth: cacheSize,
                          cacheHeight: cacheSize,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: isSmallScreen ? 24 : 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (product.stock == 0)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.6),
                          child: Center(
                            child: Text(
                              'സ്റ്റോക്കിൽ ഇല്ല',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '₹${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: priceFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (product.stock > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 6,
                                  vertical: isSmallScreen ? 2 : 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${product.stock} ലഭ്യം',
                                  style: TextStyle(
                                    fontSize: stockFontSize,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
