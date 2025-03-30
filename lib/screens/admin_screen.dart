import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'add_product_screen.dart';
import 'admin/edit_product_screen.dart';
import 'admin/all_products_screen.dart';
import 'product_detail_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pendingScrollController = ScrollController();
  final _approvedScrollController = ScrollController();
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pendingScrollController.dispose();
    _approvedScrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAuthenticated = prefs.getBool('isAdminAuthenticated') ?? false;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Admin authentication logic
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username == 'admin' && password == 'admin123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAdminAuthenticated', true);
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('അസാധുവായ ഉപയോക്തൃനാമം അല്ലെങ്കിൽ പാസ്‌വേഡ്'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ലോഗ്ഔട്ട് ചെയ്യണോ?'),
        content: const Text('നിങ്ങൾക്ക് ലോഗ്ഔട്ട് ചെയ്യണമെന്ന് ഉറപ്പാണോ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('വേണ്ട'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isAdminAuthenticated', false);
              setState(() {
                _isAuthenticated = false;
                _usernameController.clear();
                _passwordController.clear();
              });
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('വിജയകരമായി ലോഗ്ഔട്ട് ചെയ്തു'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('ലോഗ്ഔട്ട്'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phoneNumber, String message) async {
    try {
      // Clean and format the phone number
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      final fullNumber =
          cleanNumber.startsWith('91') ? cleanNumber : '91$cleanNumber';

      // Create WhatsApp URL with proper encoding
      final encodedMessage = Uri.encodeComponent(message);
      final webUrl =
          Uri.parse('https://wa.me/$fullNumber?text=$encodedMessage');

      // Try to launch WhatsApp web
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('വാട്സ്ആപ്പ് തുറക്കാൻ കഴിയുന്നില്ല'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('വാട്സ്ആപ്പ് തുറക്കാൻ കഴിയുന്നില്ല: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          size: 64,
                          color: primaryColor,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'അഡ്മിൻ ലോഗിൻ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'അഡ്മിൻ പാനൽ ഉപയോഗിക്കാൻ ലോഗിൻ ചെയ്യുക',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: inputDecoration.copyWith(
                                  labelText: 'ഉപയോക്തൃനാമം',
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: primaryColor,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ഉപയോക്തൃനാമം നൽകുക';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: inputDecoration.copyWith(
                                  labelText: 'പാസ്‌വേഡ്',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: primaryColor,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'പാസ്‌വേഡ് നൽകുക';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'ലോഗിൻ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'അഡ്മിൻ പാനൽ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add-product');
              },
              tooltip: 'പുതിയ ഉൽപ്പന്നം',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'ലോഗ്ഔട്ട്',
            ),
          ],
          bottom: TabBar(
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
            ),
            indicatorWeight: 3,
            indicatorColor: primaryColor,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.pending_actions),
                    const SizedBox(width: 8),
                    const Text('പെൻഡിങ്'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    const Text('അപ്രൂവ്ഡ്'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPendingProductsTab(),
            _buildApprovedProductsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/add-product');
          },
          backgroundColor: primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPendingProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'ഉൽപ്പന്നങ്ങൾ ലോഡ് ചെയ്യുന്നു...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final products = productProvider.pendingProducts;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pending_actions,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'അപ്രൂവ് ചെയ്യാത്ത ഉൽപ്പന്നങ്ങൾ ഒന്നും ഇല്ല',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _pendingScrollController,
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductScreen(
                        product: product,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.image,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            cacheWidth: 600,
                            cacheHeight: 600,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error,
                                      size: 48, color: Colors.red[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ചിത്രം ലഭ്യമല്ല',
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _launchWhatsApp(product.whatsapp, 'Hi'),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: Icon(Icons.phone_android,
                                      color: Colors.green[700]),
                                  label: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'വിളിക്കുക',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product.whatsapp,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                color: Colors.green,
                                onPressed: () async {
                                  await productProvider.updateProductStatus(
                                    product.id,
                                    'approved',
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('ഉൽപ്പന്നം അപ്രൂവ് ചെയ്തു'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    _launchWhatsApp(
                                      product.whatsapp,
                                      'നിങ്ങളുടെ ഉൽപ്പന്നം "${product.name}" അപ്രൂവ് ചെയ്തിരിക്കുന്നു. ഇനി മുതൽ ഇത് ആപ്പിൽ പ്രദർശിപ്പിക്കുന്നതാണ്.',
                                    );
                                  }
                                },
                                tooltip: 'അപ്രൂവ് ചെയ്യുക',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('ഉറപ്പാണോ?'),
                                      content: const Text(
                                        'ഈ ഉൽപ്പന്നം ഡിലീറ്റ് ചെയ്യണമെന്ന് ഉറപ്പാണോ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('വേണ്ട'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            productProvider
                                                .deleteProduct(product.id);
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('ഡിലീറ്റ് ചെയ്യുക'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'ഡിലീറ്റ് ചെയ്യുക',
                              ),
                              IconButton(
                                icon: Icon(
                                  product.isFeatured
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () async {
                                  await productProvider.toggleFeature(
                                    product.id,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          product.isFeatured
                                              ? 'ഫീച്ചർ നീക്കം ചെയ്തു'
                                              : 'ഫീച്ചർ ചെയ്തു',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                tooltip: product.isFeatured
                                    ? 'ഫീച്ചർ നീക്കം ചെയ്യുക'
                                    : 'ഫീച്ചർ ചെയ്യുക',
                              ),
                              IconButton(
                                icon: Icon(
                                  product.isFlashSale
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  await productProvider.toggleFlashSale(
                                    product.id,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          product.isFlashSale
                                              ? 'ഫ്ലാഷ് സെയിൽ നീക്കം ചെയ്തു'
                                              : 'ഫ്ലാഷ് സെയിലിൽ ചേർത്തു',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                tooltip: product.isFlashSale
                                    ? 'ഫ്ലാഷ് സെയിൽ നീക്കം ചെയ്യുക'
                                    : 'ഫ്ലാഷ് സെയിലിൽ ചേർക്കുക',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApprovedProductsTab() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (productProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'ഉൽപ്പന്നങ്ങൾ ലോഡ് ചെയ്യുന്നു...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final products = productProvider.products;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'അപ്രൂവ് ചെയ്ത ഉൽപ്പന്നങ്ങൾ ഒന്നും ഇല്ല',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _approvedScrollController,
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProductScreen(
                        product: product,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.image,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            cacheWidth: 600,
                            cacheHeight: 600,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error,
                                      size: 48, color: Colors.red[400]),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ചിത്രം ലഭ്യമല്ല',
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
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _launchWhatsApp(product.whatsapp, 'Hi'),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: Icon(Icons.phone_android,
                                      color: Colors.green[700]),
                                  label: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'വിളിക്കുക',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        product.whatsapp,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.unpublished),
                                color: Colors.orange,
                                onPressed: () {
                                  final reasonController =
                                      TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('കാരണം'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                              'ഉൽപ്പന്നം അപ്രൂവ് ചെയ്യാത്തതിന്റെ കാരണം നൽകുക:'),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: reasonController,
                                            decoration: const InputDecoration(
                                              hintText: 'കാരണം നൽകുക',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('വേണ്ട'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            final reason =
                                                reasonController.text.trim();
                                            if (reason.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text('കാരണം നൽകുക'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                            Navigator.pop(context);
                                            await productProvider
                                                .updateProductStatus(
                                              product.id,
                                              'pending',
                                            );
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'അപ്രൂവൽ നീക്കം ചെയ്തു'),
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                              _launchWhatsApp(
                                                product.whatsapp,
                                                'നിങ്ങളുടെ ഉൽപ്പന്നം "${product.name}" നിലവിൽ അപ്രൂവ് ചെയ്തിട്ടില്ല.\n\nകാരണം: $reason\n\nകൂടുതൽ വിവരങ്ങൾക്ക് ദയവായി ഞങ്ങളുമായി ബന്ധപ്പെടുക.',
                                              );
                                            }
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.orange,
                                          ),
                                          child: const Text('അയക്കുക'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'അപ്രൂവൽ നീക്കം ചെയ്യുക',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('ഉറപ്പാണോ?'),
                                      content: const Text(
                                        'ഈ ഉൽപ്പന്നം ഡിലീറ്റ് ചെയ്യണമെന്ന് ഉറപ്പാണോ?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('വേണ്ട'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            productProvider
                                                .deleteProduct(product.id);
                                            Navigator.pop(context);
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('ഡിലീറ്റ് ചെയ്യുക'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                tooltip: 'ഡിലീറ്റ് ചെയ്യുക',
                              ),
                              IconButton(
                                icon: Icon(
                                  product.isFeatured
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () async {
                                  await productProvider.toggleFeature(
                                    product.id,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          product.isFeatured
                                              ? 'ഫീച്ചർ നീക്കം ചെയ്തു'
                                              : 'ഫീച്ചർ ചെയ്തു',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                tooltip: product.isFeatured
                                    ? 'ഫീച്ചർ നീക്കം ചെയ്യുക'
                                    : 'ഫീച്ചർ ചെയ്യുക',
                              ),
                              IconButton(
                                icon: Icon(
                                  product.isFlashSale
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  color: Colors.orange,
                                ),
                                onPressed: () async {
                                  await productProvider.toggleFlashSale(
                                    product.id,
                                  );
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          product.isFlashSale
                                              ? 'ഫ്ലാഷ് സെയിൽ നീക്കം ചെയ്തു'
                                              : 'ഫ്ലാഷ് സെയിലിൽ ചേർത്തു',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                tooltip: product.isFlashSale
                                    ? 'ഫ്ലാഷ് സെയിൽ നീക്കം ചെയ്യുക'
                                    : 'ഫ്ലാഷ് സെയിലിൽ ചേർക്കുക',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
