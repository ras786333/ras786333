import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/banner_slider.dart';
import '../widgets/featured_products.dart';
import '../widgets/flash_sale_products.dart';
import '../widgets/product_grid.dart';
import '../screens/categories_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ആപ്പ് ആരംഭിക്കുമ്പോൾ തന്നെ എല്ലാ പ്രോഡക്ട്ടുകളും ലോഡ് ചെയ്യുന്നു
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchProducts(); // സാധാരണ പ്രോഡക്ടുകൾ ലോഡ് ചെയ്യുന്നു

      // ഫീച്ചേർഡ്/ഫ്ലാഷ് സെയിൽ പ്രോഡക്ടുകൾ ഫയർബേസിൽ നിന്ന് നേരിട്ട് ലോഡ് ചെയ്യുന്നു
      productProvider.getFeaturedProducts();
      productProvider.getFlashSaleProducts();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesScreen(),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddProductScreen(),
          ),
        );
        break;
      case 3:
        _showContactDialog();
        break;
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('കോൺടാക്റ്റ്'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('ഫോൺ'),
              subtitle: const Text('+91 1234567890'),
              onTap: () {
                // TODO: Implement phone call
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('വാട്സ്ആപ്പ്'),
              subtitle: const Text('+91 1234567890'),
              onTap: () {
                // TODO: Implement WhatsApp
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('ഇമെയിൽ'),
              subtitle: const Text('contact@mobileshop.com'),
              onTap: () {
                // TODO: Implement email
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ശരി'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSmallScreen = screenSize.width < 600;

    // Base font sizes
    final baseTitleSize = 20.0;
    final baseSubtitleSize = 14.0;
    final baseBodySize = 12.0;

    // Responsive font sizes
    final titleFontSize = isSmallScreen
        ? baseTitleSize * textScale
        : (baseTitleSize + 4.0) * textScale;
    final subtitleFontSize = isSmallScreen
        ? baseSubtitleSize * textScale
        : (baseSubtitleSize + 2.0) * textScale;
    final bodyFontSize = isSmallScreen
        ? baseBodySize * textScale
        : (baseBodySize + 2.0) * textScale;

    // Drawer font sizes
    final drawerTitleSize = isSmallScreen ? 24.0 * textScale : 28.0 * textScale;
    final drawerItemTitleSize =
        isSmallScreen ? 16.0 * textScale : 18.0 * textScale;
    final drawerItemSubtitleSize =
        isSmallScreen ? 12.0 * textScale : 14.0 * textScale;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(fontSize: bodyFontSize),
            decoration: InputDecoration(
              hintText: 'ഉൽപ്പന്നങ്ങൾ തിരയുക',
              hintStyle: TextStyle(fontSize: bodyFontSize),
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onTap: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
            readOnly: true,
          ),
        ),
        actions: [
          Tooltip(
            message: 'അഡ്മിൻ പാനൽ',
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.shopping_bag,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ഓൺലൈൻ ചന്ത',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: drawerTitleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ഉൽപ്പന്നങ്ങൾ ഓർഡർ ചെയ്യാൻ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: subtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.home,
              title: 'ഹോം',
              subtitle: 'എല്ലാ ഉൽപ്പന്നങ്ങളും കാണുക',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            _buildDrawerItem(
              icon: Icons.category,
              title: 'വിഭാഗങ്ങൾ',
              subtitle: 'ഉൽപ്പന്നങ്ങൾ വിഭാഗം തിരിച്ച് കാണുക',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
            _buildDrawerItem(
              icon: Icons.add_circle,
              title: 'ഉൽപ്പന്നം ചേർക്കുക',
              subtitle: 'പുതിയ ഉൽപ്പന്നം വിൽപ്പനയ്ക്ക് വയ്ക്കാം',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 2;
                });
              },
            ),
            _buildDrawerItem(
              icon: Icons.phone,
              title: 'കോൺടാക്റ്റ്',
              subtitle: 'ഞങ്ങളുമായി ബന്ധപ്പെടുക',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              icon: Icons.admin_panel_settings,
              title: 'അഡ്മിൻ',
              subtitle: 'അഡ്മിൻ പാനൽ',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
                  ),
                );
              },
            ),
            const Divider(height: 32),
            _buildDrawerItem(
              icon: Icons.help,
              title: 'ഉപയോഗിക്കുന്നതെങ്ങനെ?',
              subtitle: 'ആപ്പ് ഉപയോഗിക്കാനുള്ള സഹായം',
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'അപ്ലിക്കേഷനെ കുറിച്ച്',
              subtitle: 'ആപ്പിനെ കുറിച്ചുള്ള വിവരങ്ങൾ',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ProductProvider>(context, listen: false)
              .fetchProducts();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerSlider(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'പ്രമുഖ ഉൽപ്പന്നങ്ങൾ',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to featured products
                      },
                      child: const Text('കൂടുതൽ കാണുക'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const FeaturedProducts(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ഫ്ലാഷ് സെയിൽ',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to flash sale products
                      },
                      child: const Text('കൂടുതൽ കാണുക'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const FlashSaleProducts(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'എല്ലാ ഉൽപ്പന്നങ്ങളും',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  final products = productProvider.availableProducts;
                  return ProductGrid(products: products);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ഹോം',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'വിഭാഗങ്ങൾ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'ഉൽപ്പന്നം',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'കോൺടാക്റ്റ്',
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    final itemTitleSize = isSmallScreen ? 16.0 * textScale : 18.0 * textScale;
    final itemSubtitleSize =
        isSmallScreen ? 12.0 * textScale : 14.0 * textScale;

    return ListTile(
      leading: Icon(icon, color: Colors.blue, size: 28),
      title: Text(
        title,
        style: TextStyle(
          fontSize: itemTitleSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: itemSubtitleSize,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTap,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('How to Use?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                icon: Icons.home,
                title: 'ഹോം സ്ക്രീൻ',
                description: 'എല്ലാ ഉൽപ്പന്നങ്ങളും ഇവിടെ കാണാം',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.category,
                title: 'വിഭാഗങ്ങൾ',
                description: 'ഉൽപ്പന്നങ്ങൾ വിഭാഗം തിരിച്ച് കാണാം',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.add_circle,
                title: 'ഉൽപ്പന്നം ചേർക്കുക',
                description: 'പുതിയ ഉൽപ്പന്നം വിൽപ്പനയ്ക്ക് വയ്ക്കാം',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                icon: Icons.search,
                title: 'തിരയൽ',
                description: 'ഉൽപ്പന്നങ്ങൾ പേര് വച്ച് തിരയാം',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('മനസ്സിലായി'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    final helpTitleSize = isSmallScreen ? 14.0 * textScale : 16.0 * textScale;
    final helpDescriptionSize =
        isSmallScreen ? 12.0 * textScale : 14.0 * textScale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: helpTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: helpDescriptionSize,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Text('about app'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ഓൺലൈൻ ചന്ത ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'വേർഷൻ 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'ഈ ആപ്പ് ഉപയോഗിച്ച് നിങ്ങൾക്ക്:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text('• ഉൽപ്പന്നങ്ങൾ വിൽക്കാം'),
            Text('• ഉൽപ്പന്നങ്ങൾ വാങ്ങാം'),
            Text('• വിഭാഗം തിരിച്ച് കാണാം'),
            Text('• വിലകൾ താരതമ്യം ചെയ്യാം'),
            SizedBox(height: 16),
            Text(
              '© 2025 ഓൺലൈൻ ചന്ത ',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ശരി'),
          ),
        ],
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final products = productProvider.products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (products.isEmpty) {
          return const Center(
            child: Text('അംഗീകരിച്ച ഉൽപ്പന്നങ്ങൾ കണ്ടെത്താൻ കഴിയുന്നില്ല'),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
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
              subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
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
            );
          },
        );
      },
    );
  }
}
