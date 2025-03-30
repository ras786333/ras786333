import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _flashSaleProducts = [];
  bool _isLoading = false;
  bool _isAdmin = false;
  final List<String> _categories = [
    'ഫലങ്ങൾ',
    'പച്ചക്കറികൾ',
    'അരി',
    'എണ്ണ',
    'മറ്റ്',
  ];
  final List<String> _units = [
    'കിലോ',
    'ലിറ്റർ',
    'നമ്പർ',
    'പാക്കറ്റ്',
    'ബാഗ്',
  ];

  List<Product> get allProducts => [..._products];
  List<Product> get availableProducts => _products
      .where((product) => product.stock > 0 && product.status == 'approved')
      .toList();
  List<Product> get products =>
      _products.where((product) => product.status == 'approved').toList();
  List<Product> get pendingProducts =>
      _products.where((product) => product.status == 'pending').toList();
  List<Product> get rejectedProducts =>
      _products.where((product) => product.status == 'rejected').toList();
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;
  List<String> get units => _units;
  bool get isAdmin => _isAdmin;

  List<Product> get cachedFeaturedProducts => _featuredProducts;
  List<Product> get cachedFlashSaleProducts => _flashSaleProducts;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsData = await _firestoreService.getProducts();
      _products = productsData.map((data) => Product.fromJson(data)).toList();
    } catch (e) {
      print('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_products.map((p) => p.toJson()).toList());
      await prefs.setString('products', encoded);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _firestoreService.addProduct(product.toJson());
      await loadProducts();
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestoreService.updateProduct(product.id, product.toJson());
      await loadProducts();
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestoreService.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  Future<void> updateProductStatus(String id, String status) async {
    try {
      final product = await _firestoreService.getProduct(id);
      if (product != null) {
        final updatedProduct =
            Product.fromJson(product).copyWith(status: status);
        await updateProduct(updatedProduct);
      }
    } catch (e) {
      print('Error updating product status: $e');
      rethrow;
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final product = _products[productIndex];
        final updatedProduct = Product(
          id: product.id,
          name: product.name,
          description: product.description,
          category: product.category,
          imageUrl: product.imageUrl,
          image: product.image,
          price: product.price,
          quantity: product.quantity,
          stock: newStock,
          whatsapp: product.whatsapp,
          submittedDate: product.submittedDate,
          status: product.status,
          isFavorite: product.isFavorite,
          isFeatured: product.isFeatured,
          isFlashSale: product.isFlashSale,
          sellerPhone: product.sellerPhone,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
        );
        await _firestoreService.updateProduct(
            productId, updatedProduct.toJson());
        await loadProducts();
      }
    } catch (e) {
      print('Error updating product stock: $e');
      rethrow;
    }
  }

  Future<void> toggleFavoriteStatus(String id) async {
    final product = findById(id);
    product.toggleFavoriteStatus();
    await saveData();
    notifyListeners();
  }

  Future<void> toggleFeature(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isFeatured: !_products[index].isFeatured,
      );

      // Update in Firebase Firestore
      try {
        await _firestoreService.updateProduct(id, {
          'isFeatured': _products[index].isFeatured,
        });
      } catch (e) {
        print('Error updating feature status in Firestore: $e');
      }

      await saveData();
      notifyListeners();
    }
  }

  Future<void> toggleFlashSale(String id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        isFlashSale: !_products[index].isFlashSale,
      );

      // Update in Firebase Firestore
      try {
        await _firestoreService.updateProduct(id, {
          'isFlashSale': _products[index].isFlashSale,
        });
      } catch (e) {
        print('Error updating flash sale status in Firestore: $e');
      }

      await saveData();
      notifyListeners();
    }
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }

  List<Product> get featuredProducts {
    return _products
        .where((product) => product.isFeatured && product.stock > 0)
        .toList();
  }

  List<Product> get flashSaleProducts {
    return _products
        .where((product) => product.isFlashSale && product.stock > 0)
        .toList();
  }

  List<Product> get favoriteProducts {
    return _products
        .where((product) => product.isFavorite && product.stock > 0)
        .toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products
        .where((product) => product.category == category && product.stock > 0)
        .toList();
  }

  // Sample data for testing
  void loadSampleData() {
    _products = [
      Product(
        id: '1',
        name: 'iPhone 13',
        description: 'Latest iPhone model with A15 Bionic chip',
        category: 'Smartphones',
        imageUrl: 'https://example.com/iphone13.jpg',
        image: 'https://example.com/iphone13.jpg',
        price: 799.99,
        quantity: 1,
        stock: 10,
        whatsapp: '+1234567890',
        submittedDate: DateTime.now(),
        status: 'approved',
        isFeatured: true,
        sellerPhone: '+1234567890',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S21',
        description: '5G enabled Android flagship',
        category: 'Smartphones',
        imageUrl: 'https://example.com/samsung-s21.jpg',
        image: 'https://example.com/samsung-s21.jpg',
        price: 699.99,
        quantity: 1,
        stock: 15,
        whatsapp: '+1234567890',
        submittedDate: DateTime.now(),
        status: 'pending',
        isFlashSale: true,
        sellerPhone: '+1234567890',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    saveData();
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    try {
      await loadProducts();
    } catch (error) {
      print('Error fetching products: $error');
      rethrow;
    }
  }

  Future<void> checkAdminStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool('isAdminAuthenticated') ?? false;
    notifyListeners();
  }

  Future<Product?> getProduct(String id) async {
    try {
      final productData = await _firestoreService.getProduct(id);
      if (productData != null) {
        return Product.fromJson(productData);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: 'approved')
          .get();

      _featuredProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      notifyListeners();
      return _featuredProducts;
    } catch (e) {
      print('Error getting featured products: $e');
      return [];
    }
  }

  Future<List<Product>> getFlashSaleProducts() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('isFlashSale', isEqualTo: true)
          .where('status', isEqualTo: 'approved')
          .get();

      _flashSaleProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();

      notifyListeners();
      return _flashSaleProducts;
    } catch (e) {
      print('Error getting flash sale products: $e');
      return [];
    }
  }
}
