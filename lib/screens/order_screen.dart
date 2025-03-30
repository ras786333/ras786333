import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/order_provider.dart';
import '../models/product.dart';
import '../models/order.dart';
import 'package:uuid/uuid.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  Product? _selectedProduct;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_formKey.currentState!.validate() && _selectedProduct != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final order = Order(
          id: const Uuid().v4(),
          productId: _selectedProduct!.id,
          productName: _selectedProduct!.name,
          price: _selectedProduct!.price,
          quantity: 1,
          customerName: _nameController.text,
          phoneNumber: _phoneController.text,
          address: _addressController.text,
          note: _noteController.text,
          orderDate: DateTime.now(),
          status: 'pending',
        );

        context.read<OrderProvider>().addOrder(order);
        _updateStock(
            context, _selectedProduct!.id, _selectedProduct!.stock - 1);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[100]),
                  const SizedBox(width: 8),
                  const Text('ഓർഡർ വിജയകരമായി സബ്മിറ്റ് ചെയ്തു'),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[100]),
                  const SizedBox(width: 8),
                  const Text('ഓർഡർ സബ്മിറ്റ് ചെയ്യുന്നതിൽ പിശക് സംഭവിച്ചു'),
                ],
              ),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
  }

  void _updateStock(BuildContext context, String productId, int quantity) {
    context.read<ProductProvider>().updateProductStock(productId, quantity);
  }

  @override
  Widget build(BuildContext context) {
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
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'ഓർഡർ ഫോം',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ഓർഡർ സബ്മിറ്റ് ചെയ്യുന്നു...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'ഉൽപ്പന്നം തിരഞ്ഞെടുക്കുക',
                      'ഓർഡർ ചെയ്യാൻ ആഗ്രഹിക്കുന്ന ഉൽപ്പന്നം തിരഞ്ഞെടുക്കുക',
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Consumer<ProductProvider>(
                          builder: (context, productProvider, child) {
                            final products = productProvider.products
                                .where((product) =>
                                    product.status == 'approved' &&
                                    product.stock > 0)
                                .toList();

                            if (products.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange[200]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'ഇപ്പോൾ ഓർഡർ ചെയ്യാൻ ലഭ്യമായ ഉൽപ്പന്നങ്ങൾ ഒന്നും ഇല്ല',
                                        style: TextStyle(
                                          color: Colors.orange[900],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<Product>(
                                  value: _selectedProduct,
                                  decoration: inputDecoration.copyWith(
                                    labelText: 'ഉൽപ്പന്നം',
                                    prefixIcon: Icon(
                                      Icons.shopping_bag,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  items: products.map((product) {
                                    return DropdownMenuItem(
                                      value: product,
                                      child: Text(
                                        '${product.name} (സ്റ്റോക്ക്: ${product.stock})',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedProduct = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'ദയവായി ഒരു ഉൽപ്പന്നം തിരഞ്ഞെടുക്കുക';
                                    }
                                    return null;
                                  },
                                ),
                                if (_selectedProduct != null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.blue[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'വില: ₹${_selectedProduct!.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.blue[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'വ്യക്തിഗത വിവരങ്ങൾ',
                      'ഓർഡർ ഡെലിവറി ചെയ്യുന്നതിനുള്ള വിവരങ്ങൾ',
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'പേര്',
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Theme.of(context).primaryColor,
                                ),
                                helperText: 'നിങ്ങളുടെ മുഴുവൻ പേര് നൽകുക',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി നിങ്ങളുടെ പേര് നൽകുക';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'ഫോൺ നമ്പർ',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Theme.of(context).primaryColor,
                                ),
                                prefixText: '+91 ',
                                helperText:
                                    'നിങ്ങളുമായി ബന്ധപ്പെടാനുള്ള മൊബൈൽ നമ്പർ',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി ഫോൺ നമ്പർ നൽകുക';
                                }
                                if (value.length != 10) {
                                  return 'ശരിയായ 10 അക്ക ഫോൺ നമ്പർ നൽകുക';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'വിലാസം',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Theme.of(context).primaryColor,
                                ),
                                helperText:
                                    'ഉൽപ്പന്നം എത്തിക്കേണ്ട വിലാസം പൂർണ്ണമായി നൽകുക',
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി വിലാസം നൽകുക';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'അധിക വിവരങ്ങൾ',
                      'ഓർഡറിനെ കുറിച്ചുള്ള കൂടുതൽ വിവരങ്ങൾ (ഓപ്ഷണൽ)',
                    ),
                    const SizedBox(height: 8),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _noteController,
                          decoration: inputDecoration.copyWith(
                            labelText: 'കുറിപ്പ്',
                            prefixIcon: Icon(
                              Icons.note,
                              color: Theme.of(context).primaryColor,
                            ),
                            helperText:
                                'ഡെലിവറി സമയം, പ്രത്യേക നിർദ്ദേശങ്ങൾ തുടങ്ങിയവ',
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_cart_checkout),
                        label: const Text(
                          'ഓർഡർ സബ്മിറ്റ് ചെയ്യുക',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
