import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  final _priceController = TextEditingController();
  String? _selectedQuantityType;
  final _stockController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _categoryController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  final _primaryColor = const Color(0xFF6B4EFF);
  final _secondaryColor = const Color(0xFFFF4E8C);
  final _backgroundColor = const Color(0xFFF8F9FE);
  final _cardColor = Colors.white;
  final _textColor = const Color(0xFF2D3142);

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  // വിഭാഗങ്ങൾ
  final List<String> _categories = [
    // ഇലക്ട്രോണിക്സ് വിഭാഗങ്ങൾ
    'സ്മാർട്ട്ഫോണുകൾ',
    'ടാബ്‌ലെറ്റുകൾ',
    'ലാപ്ടോപ്പുകൾ',
    'ഡെസ്ക്ടോപ്പുകൾ',
    'കമ്പ്യൂട്ടർ അക്സസറികൾ',
    'മൊബൈൽ അക്സസറികൾ',
    'നെറ്റ്‌വർക്കിംഗ് ഉപകരണങ്ങൾ',
    'ഗെയിമിംഗ് കൺസോളുകൾ',
    'ഗെയിമിംഗ് അക്സസറികൾ',
    'സ്മാർട്ട് വാച്ചുകൾ',
    'ബ്ലൂടൂത്ത് ഉപകരണങ്ങൾ',
    'ഹെഡ്‌ഫോണുകൾ',
    'സ്പീക്കറുകൾ',
    'പവർ ബാങ്കുകൾ',
    'മെമ്മറി & സ്റ്റോറേജ്',
    'പ്രിന്റർ & സ്കാനർ',
    'കാമറകൾ',
    'സെക്യൂരിറ്റി ക്യാമറകൾ',
    'സ്മാർട്ട് ഹോം ഉപകരണങ്ങൾ',
    'ഇലക്ട്രോണിക് അക്സസറികൾ',

    // ഭക്ഷണ വിഭാഗങ്ങൾ
    'പച്ചക്കറികൾ',
    'പഴവർഗ്ഗങ്ങൾ',
    'മാംസം & മത്സ്യം',
    'പാലുല്പന്നങ്ങൾ',
    'ബേക്കറി ഉല്പന്നങ്ങൾ',
    'പലവ്യഞ്ജനം',
    'ധാന്യങ്ങൾ',
    'പാനീയങ്ങൾ',
    'സ്നാക്സ്',
    'പാചക സാധനങ്ങൾ',
    'ഇറച്ചി ഉല്പന്നങ്ങൾ',
    'മുട്ട & കോഴി',
    'ആയുർവേദ ഭക്ഷണം',
    'ഓർഗാനിക് ഭക്ഷണം',
    'തയ്യാർ ഭക്ഷണം',
  ];

  // അളവ് തരങ്ങൾ
  final List<String> _quantityTypes = [
    // അടിസ്ഥാന അളവുകൾ
    'എണ്ണം',
    'പീസ്',
    'സെറ്റ്',
    'പായ്ക്കറ്റ്',
    'പൊതി',
    'ബോക്സ്',
    'കാർട്ടൺ',
    'ബാഗ്',

    // ഭാരം അളവുകൾ
    'ഗ്രാം',
    'കിലോഗ്രാം',
    'ടൺ',

    // ദ്രാവക അളവുകൾ
    'മില്ലിലിറ്റർ',
    'ലിറ്റർ',

    // നീളം അളവുകൾ
    'മില്ലിമീറ്റർ',
    'സെന്റിമീറ്റർ',
    'മീറ്റർ',

    // വിസ്തീർണ്ണം അളവുകൾ
    'ചതുരശ്ര മീറ്റർ',
    'ചതുരശ്ര അടി',

    // പരമ്പരാഗത അളവുകൾ
    'പറ',
    'ഇടങ്ങഴി',
    'കുറുണി',
  ];

  Future<void> _openImageUploadGuide() async {
    final Uri url = Uri.parse('https://imgbb.com');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ലിങ്ക് തുറക്കാൻ കഴിയുന്നില്ല'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ലിങ്ക് തുറക്കാൻ പിശക് സംഭവിച്ചു: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _whatsappController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _phoneController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ദയവായി ഒരു വിഭാഗം തിരഞ്ഞെടുക്കുക'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedQuantityType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ദയവായി ഒരു അളവ് തരം തിരഞ്ഞെടുക്കുക'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newProduct = Product(
        id: '', // Will be set by Firestore
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory!,
        imageUrl: _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageUrlController.text,
        image: _imageUrlController.text.isEmpty
            ? 'https://via.placeholder.com/150'
            : _imageUrlController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_stockController.text),
        stock: int.parse(_stockController.text),
        whatsapp: _whatsappController.text,
        submittedDate: DateTime.now(),
        status: 'pending',
        sellerPhone: _phoneController.text,
        createdAt: DateTime.now(), // Will be set by Firestore
        updatedAt: DateTime.now(), // Will be set by Firestore
      );

      await Provider.of<ProductProvider>(context, listen: false)
          .addProduct(newProduct);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ഉൽപ്പന്നം ചേർക്കാൻ കഴിയുന്നില്ല: $error'),
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
    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor),
      ),
      filled: true,
      fillColor: _cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      helperStyle: TextStyle(color: _textColor.withOpacity(0.7)),
      labelStyle: TextStyle(color: _textColor),
    );

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'ഉൽപ്പന്നം ചേർക്കുക',
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'ഉൽപ്പന്നം സേവ് ചെയ്യുന്നു...',
                    style: TextStyle(
                      color: _textColor,
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
                    // അടിസ്ഥാന വിവരങ്ങൾ
                    _buildSectionTitle('അടിസ്ഥാന വിവരങ്ങൾ',
                        'ഉൽപ്പന്നത്തിന്റെ പേരും വിവരണവും നൽകുക'),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'ഉൽപ്പന്നത്തിന്റെ പേര്',
                                prefixIcon: Icon(Icons.shopping_bag,
                                    color: _primaryColor),
                                helperText: 'ഉദാ: സാംസങ് ഗാലക്സി എം 34',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി ഉൽപ്പന്നത്തിന്റെ പേര് നൽകുക';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'വിവരണം',
                                prefixIcon: Icon(Icons.description,
                                    color: _primaryColor),
                                helperText:
                                    'ഉൽപ്പന്നത്തിന്റെ പ്രത്യേകതകൾ വിശദമാക്കുക',
                                alignLabelWithHint: true,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി വിവരണം നൽകുക';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // വിഭാഗവും അളവും
                    _buildSectionTitle('വിഭാഗവും അളവും',
                        'ഉൽപ്പന്നത്തിന്റെ വിഭാഗവും അളവ് രീതിയും തിരഞ്ഞെടുക്കുക'),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(minHeight: 60),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: _selectedCategory,
                                decoration: inputDecoration.copyWith(
                                  labelText: 'വിഭാഗം',
                                  prefixIcon: Icon(Icons.category,
                                      color: _primaryColor),
                                ),
                                items: _categories.map((String category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(
                                      category,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedQuantityType,
                              decoration: inputDecoration.copyWith(
                                labelText: 'അളവ് തരം',
                                prefixIcon: Icon(Icons.straighten,
                                    color: _primaryColor),
                                helperText:
                                    'ഉൽപ്പന്നം എങ്ങനെ അളക്കും (എണ്ണം, കിലോ, ലിറ്റർ, etc.)',
                              ),
                              items: _quantityTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedQuantityType = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ചിത്രം
                    _buildSectionTitle('ചിത്രം',
                        'ഉൽപ്പന്നത്തിന്റെ ചിത്രം അപ്‌ലോഡ് ചെയ്ത് ലിങ്ക് നൽകുക'),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _imageUrlController,
                                    focusNode: _imageUrlFocusNode,
                                    decoration: inputDecoration.copyWith(
                                      labelText: 'ചിത്രത്തിന്റെ URL',
                                      helperText:
                                          '1. imgbb.com-ൽ പോകുക\n2. ചിത്രം അപ്‌ലോഡ് ചെയ്യുക\n3. ലിങ്ക് ഇവിടെ പേസ്റ്റ് ചെയ്യുക',
                                      helperMaxLines: 3,
                                      prefixIcon: Icon(Icons.image,
                                          color: _primaryColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.help_outline,
                                            color: _primaryColor),
                                        onPressed: _openImageUploadGuide,
                                        tooltip:
                                            'ചിത്രം അപ്‌ലോഡ് ചെയ്യുന്നത് എങ്ങനെ?',
                                      ),
                                    ),
                                    onEditingComplete: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                if (_imageUrlController.text.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _primaryColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: CachedNetworkImage(
                                          imageUrl: _imageUrlController.text,
                                          placeholder: (context, url) => Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                color: _primaryColor,
                                              ),
                                              const SizedBox(height: 8),
                                              const Text(
                                                'ലോഡ് ചെയ്യുന്നു...',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error,
                                                  color: _secondaryColor),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'ചിത്രം ലഭ്യമല്ല',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // വിലയും സ്റ്റോക്കും
                    _buildSectionTitle('വിലയും സ്റ്റോക്കും',
                        'ഉൽപ്പന്നത്തിന്റെ വിലയും ലഭ്യമായ സ്റ്റോക്കും നൽകുക'),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _priceController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'വില',
                                prefixIcon: Icon(Icons.currency_rupee,
                                    color: _primaryColor),
                                prefixText: '₹ ',
                                helperText: 'ഉദാ: 499.99',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി വില നൽകുക';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'ദയവായി ശരിയായ വില നൽകുക';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _stockController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'സ്റ്റോക്ക്',
                                prefixIcon: Icon(Icons.inventory_2,
                                    color: _primaryColor),
                                helperText: 'ലഭ്യമായ എണ്ണം/അളവ്',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി സ്റ്റോക്ക് നൽകുക';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'ദയവായി ശരിയായ സ്റ്റോക്ക് നൽകുക';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ബന്ധപ്പെടാൻ
                    _buildSectionTitle('ബന്ധപ്പെടാൻ',
                        'ഉപഭോക്താക്കൾക്ക് താങ്കളുമായി ബന്ധപ്പെടാനുള്ള വിവരങ്ങൾ'),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _whatsappController,
                              decoration: inputDecoration.copyWith(
                                labelText: 'വാട്സ്ആപ്പ് നമ്പർ',
                                prefixIcon: Icon(Icons.phone_android,
                                    color: _primaryColor),
                                prefixText: '+91 ',
                                helperText:
                                    '10 അക്ക മൊബൈൽ നമ്പർ (ഉദാ: 9876543210)',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ദയവായി വാട്സ്ആപ്പ് നമ്പർ നൽകുക';
                                }
                                if (value.length != 10) {
                                  return 'ദയവായി ശരിയായ വാട്സ്ആപ്പ് നമ്പർ നൽകുക';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'വാട്സ്ആപ്പ് നമ്പർ',
                                border: OutlineInputBorder(),
                                helperText: 'ഉദാ: +91 9876543210',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'വാട്സ്ആപ്പ് നമ്പർ നൽകുക';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'ഉൽപ്പന്നം ചേർക്കുക',
                          style: TextStyle(
                            fontSize: 18,
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: _textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
