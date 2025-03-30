import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../screens/product_detail_screen.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({Key? key}) : super(key: key);

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final approvedProducts = productProvider.products
            .where((product) => product.status == 'approved')
            .toList();

        if (_currentPage < approvedProducts.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _startAutoPlay();
      } else if (mounted) {
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSmallScreen = screenSize.width < 600;

    // Base font sizes
    final baseTitleSize = 18.0;
    final basePriceSize = 16.0;

    // Responsive font sizes
    final titleFontSize = isSmallScreen
        ? baseTitleSize * textScale
        : (baseTitleSize + 2.0) * textScale;
    final priceFontSize = isSmallScreen
        ? basePriceSize * textScale
        : (basePriceSize + 2.0) * textScale;

    // Banner height based on screen size
    final bannerHeight =
        isSmallScreen ? screenSize.height * 0.25 : screenSize.height * 0.3;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final approvedProducts = productProvider.products
            .where((product) => product.status == 'approved')
            .toList();

        if (approvedProducts.isEmpty) {
          return SizedBox(
            height: bannerHeight,
            child: Center(
              child: Text(
                'അപ്രൂവ് ചെയ്ത ഉൽപ്പന്നങ്ങൾ ഇല്ല',
                style: TextStyle(fontSize: titleFontSize),
              ),
            ),
          );
        }

        return Stack(
          children: [
            SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: approvedProducts.length,
                itemBuilder: (context, index) {
                  final product = approvedProducts[index];
                  return GestureDetector(
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          cacheWidth: (screenSize.width *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                          cacheHeight: (bannerHeight *
                                  MediaQuery.of(context).devicePixelRatio)
                              .toInt(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 32,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 12,
                              horizontal: isSmallScreen ? 16 : 24,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: priceFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  approvedProducts.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withAlpha(128),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
