import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import 'order_form_screen.dart';
import 'dart:io' show Platform;
import 'admin/edit_product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firestore_service.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../utils/app_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  final String productId;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  late Product product;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedQuantity = 1;
  bool _isLoading = true;
  bool _isAdmin = false;
  final FirestoreService _firestoreService = FirestoreService();
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _reviews = [];
  double _averageRating = 0.0;
  bool _isReviewing = false;
  double _selectedRating = 0.0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
    _loadProduct();
    _checkAdminStatus();
    _loadReviews();
    _setupReviewListener();
  }

  void _setupReviewListener() {
    _firestoreService.getReviewsStream(widget.productId).listen((reviews) {
      setState(() {
        _reviews = reviews;
        _calculateAverageRating();
      });
    });
  }

  void _calculateAverageRating() {
    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }
    final totalRating =
        _reviews.fold(0.0, (sum, review) => sum + (review['rating'] as double));
    _averageRating = totalRating / _reviews.length;
  }

  Future<void> _checkAdminStatus() async {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.checkAdminStatus();
    if (mounted) {
      setState(() {
        _isAdmin = productProvider.isAdmin;
      });
    }
  }

  Future<void> _loadProduct() async {
    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      product = productProvider.findById(widget.productId);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ഉൽപ്പന്നം കണ്ടെത്താൻ കഴിഞ്ഞില്ല'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      _reviews = await _firestoreService.getProductReviews(widget.productId);
      _averageRating =
          await _firestoreService.getProductAverageRating(widget.productId);
    } catch (e) {
      print('Error loading reviews: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0.0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide both rating and comment')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      await _firestoreService.addReview(
        widget.productId,
        user?.uid ?? 'anonymous',
        user?.displayName ?? 'Anonymous User',
        _selectedRating,
        _reviewController.text,
      );
      _reviewController.clear();
      _selectedRating = 0.0;
      setState(() => _isReviewing = false);
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    }
    setState(() => _isLoading = false);
  }

  void _checkStock() {
    if (product.stock <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('സ്റ്റോക്ക് ഇല്ല'),
            content:
                const Text('ഈ ഉൽപ്പന്നത്തിന്റെ സ്റ്റോക്ക് ഇപ്പോൾ ലഭ്യമല്ല.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text('ശരി'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final message = '''
*പുതിയ ഓർഡർ*
------------------
*ഉൽപ്പന്നം:* ${product.name} 
*വില:* ₹${product.price}
*എണ്ണം:* $_selectedQuantity
*ആകെ തുക:* ₹${product.price * _selectedQuantity}

*ഉപഭോക്താവിന്റെ വിവരങ്ങൾ:*
പേർ: ${_nameController.text}
ഫോൺ: ${_addressController.text}
വിലാസം: ${_addressController.text}
''';

      final encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/${product.sellerPhone}?text=$encodedMessage';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));

        // ഓർഡർ സേവ് ചെയ്യുക
        final order = Order(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: _selectedQuantity,
          customerName: _nameController.text,
          phoneNumber: _addressController.text,
          address: _addressController.text,
          note: _noteController.text,
          orderDate: DateTime.now(),
          status: 'pending',
        );

        await Provider.of<OrderProvider>(context, listen: false)
            .addOrder(order);

        // സ്റ്റോക്ക് അപ്ഡേറ്റ് ചെയ്യുക
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProductStock(
          product.id,
          product.stock - _selectedQuantity,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ഓർഡർ വിജയകരമായി സ്വീകരിച്ചു'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp തുറക്കാൻ കഴിയുന്നില്ല'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('എന്തോ പിശക് സംഭവിച്ചു: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.error_outline, color: Colors.red, size: 48),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDialog() {
    if (product.stock <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('സ്റ്റോക്ക് ഇല്ല'),
          content: const Text('ഈ ഉൽപ്പന്നത്തിന്റെ സ്റ്റോക്ക് ഇപ്പോൾ ലഭ്യമല്ല.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ശരി'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ഓർഡർ ചെയ്യുക',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'വില: ₹${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'സ്റ്റോക്ക്: ${product.stock} ഐറ്റം',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ആകെ തുക:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₹${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderFormScreen(
                          product: product,
                          sellerPhone: product.sellerPhone,
                          quantity: 1,
                        ),
                      ),
                    );

                    if (result == true) {
                      // Update local product state
                      setState(() {
                        product.stock -= 1;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'ഓർഡർ ചെയ്യുക',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProduct() async {
    final message = AppConstants.getProductShareMessage(
      product.name,
      product.id,
      product.price,
    );

    await Share.share(
      message,
      subject: 'Check out ${product.name}',
    );
  }

  Future<void> _launchAppStore() async {
    final url =
        'https://play.google.com/store/apps/details?id=com.mob.mobile_shop';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ആപ്പ് സ്റ്റോർ ലിങ്ക് തുറക്കാൻ കഴിയുന്നില്ല'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
      locale: 'en_IN',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updatedProduct = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProductScreen(product: product),
                  ),
                );
                if (updatedProduct != null) {
                  setState(() {
                    product = updatedProduct;
                  });
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _launchAppStore,
          ),
          Tooltip(
            message: 'പ്രിയപ്പെട്ടവയിൽ ചേർക്കുക',
            child: IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                setState(() {
                  product.toggleFavoriteStatus();
                });
              },
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: Hero(
                      tag: 'product_image_${widget.productId}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: GestureDetector(
                          onTap: () =>
                              _showFullScreenImage(context, product.imageUrl),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[100]!,
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red[50]!, Colors.red[100]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error,
                                      size: 48, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ചിത്രം ല്യമല്ല',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'വലുതാക്കി കാണാൻ ടാപ്പ് ചെയ്യുക',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: 'product_name_${widget.productId}',
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(product.price),
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: product.stock > 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            product.stock > 0
                                ? 'സ്റ്റോക്കിൽ ഉണ്ട്'
                                : 'സ്റ്റോക്കിൽ ഇല്ല',
                            style: TextStyle(
                              color: product.stock > 0
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'വിശദാംശങ്ങൾ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            icon: Icons.category,
                            label: 'വിഭാഗം',
                            value: product.category,
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.inventory_2,
                            label: 'ലഭ്യമായ സ്റ്റോക്ക്',
                            value: '${product.stock} എണ്ണം',
                          ),
                          const Divider(height: 24),
                          _buildDetailRow(
                            icon: Icons.calendar_today,
                            label: 'ചേർത്ത തീയതി',
                            value: DateFormat('dd/MM/yyyy')
                                .format(product.submittedDate),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'വിവരണം',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildReviewSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: product.stock > 0
                        ? LinearGradient(
                            colors: [
                              Colors.orange[700]!,
                              Colors.orange[500]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey[400]!, Colors.grey[300]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: product.stock > 0
                            ? Colors.orange[300]!.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: product.stock > 0 ? _showOrderDialog : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              product.stock > 0
                                  ? 'ഓർഡർ ചെയ്യുക'
                                  : 'സ്റ്റോക്കിൽ ഇല്ല',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF25D366).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _launchWhatsApp,
                      borderRadius: BorderRadius.circular(12),
                      child: const Center(
                        child: Icon(
                          Icons.chat_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 4),
            Text(
              _averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text('(${_reviews.length} reviews)'),
          ],
        ),
        const SizedBox(height: 16),
        if (!_isReviewing)
          ElevatedButton(
            onPressed: () => setState(() => _isReviewing = true),
            child: const Text('Write a Review'),
          ),
        if (_isReviewing) ...[
          const Text('Your Rating:'),
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () => setState(() => _selectedRating = index + 1.0),
              );
            }),
          ),
          TextField(
            controller: _reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _isReviewing = false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _submitReview,
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          const Center(
            child: Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            review['userName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '${review['rating']} ★',
                            style: const TextStyle(color: Colors.amber),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(review['comment']),
                      const SizedBox(height: 8),
                      Text(
                        review['timestamp']
                                ?.toDate()
                                .toString()
                                .split(' ')[0] ??
                            '',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
