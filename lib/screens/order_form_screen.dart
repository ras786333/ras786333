import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/product.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/product_provider.dart';
import '../models/order.dart';
import '../providers/order_provider.dart';

class OrderFormScreen extends StatefulWidget {
  final Product product;
  final String sellerPhone;
  int quantity;

  OrderFormScreen({
    Key? key,
    required this.product,
    required this.sellerPhone,
    required this.quantity,
  }) : super(key: key);

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _launchWhatsApp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: widget.product.id,
        productName: widget.product.name,
        price: widget.product.price,
        quantity: widget.quantity,
        customerName: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        note: _noteController.text,
        orderDate: DateTime.now(),
        status: 'pending',
      );

      // WhatsApp-ലേക്ക് ഓർഡർ വിവരങ്ങൾ അയയ്ക്കുക
      final message = '''
*പുതിയ ഓർഡർ*
------------------
*ഉൽപ്പന്നം:* ${widget.product.name} 
*വില:* ₹${widget.product.price}
*എണ്ണം:* ${widget.quantity}
*ആകെ തുക:* ₹${widget.product.price * widget.quantity}

*ഉപഭോക്താവിന്റെ വിവരങ്ങൾ:*
പേർ: ${_nameController.text}
ഫോൺ: ${_phoneController.text}
വിലാസം: ${_addressController.text}
''';

      final encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/${widget.sellerPhone}?text=$encodedMessage';

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));

        // ഓർഡർ സേവ് ചെയ്യുക
        await Provider.of<OrderProvider>(context, listen: false)
            .addOrder(order);

        // സ്റ്റോക്ക് അപ്ഡേറ്റ് ചെയ്യുക
        await Provider.of<ProductProvider>(context, listen: false)
            .updateProductStock(
          widget.product.id,
          widget.product.stock - widget.quantity,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ഓർഡർ ഫോം'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ഉൽപ്പന്ന വിവരങ്ങൾ
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ഉൽപ്പന്ന വിവരങ്ങൾ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    widget.product.image,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${widget.product.price}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ഉപഭോക്താവിന്റെ വിവരങ്ങൾ
                    const Text(
                      'നിങ്ങളുടെ വിവരങ്ങൾ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'പേര്',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ദയവായി പേര് നൽകുക';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'ഫോൺ നമ്പർ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ദയവായി ഫോൺ നമ്പർ നൽകുക';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'വിലാസം',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ദയവായി വിലാസം നൽകുക';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'എണ്ണം',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (widget.quantity > 1) {
                                        setState(() {
                                          widget.quantity--;
                                        });
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    color: Colors.orange,
                                  ),
                                  Text(
                                    '${widget.quantity} ഐറ്റം',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (widget.quantity <
                                          widget.product.stock) {
                                        setState(() {
                                          widget.quantity++;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: Colors.orange,
                                  ),
                                ],
                              ),
                              Text(
                                '₹${widget.product.price * widget.quantity}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _launchWhatsApp,
                        icon: const FaIcon(FontAwesomeIcons.whatsapp),
                        label: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'ഓർഡർ സ്ഥിരീകരിക്കുക',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
}
