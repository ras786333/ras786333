import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Products Collection
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure the ID is included
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Ensure the ID is included
          ...data,
        };
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      rethrow;
    }
  }

  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      // Create document and get the ID
      final DocumentReference docRef =
          await _firestore.collection('products').add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the document with its own ID
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(
      String id, Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('products').doc(id).update({
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // Categories Collection
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('categories').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting categories: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getCategory(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('categories').doc(id).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      await _firestore.collection('categories').add(categoryData);
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> category) async {
    try {
      await _firestore.collection('categories').doc(id).update({
        ...category,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }

  // Orders Collection
  Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('orders').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting orders: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrder(String id) async {
    try {
      final DocumentSnapshot doc =
          await _firestore.collection('orders').doc(id).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  Future<void> addOrder(Map<String, dynamic> orderData) async {
    try {
      await _firestore.collection('orders').add(orderData);
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }

  Future<void> updateOrder(String id, Map<String, dynamic> order) async {
    try {
      await _firestore.collection('orders').doc(id).update({
        ...order,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _firestore.collection('orders').doc(id).delete();
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  // ഡാറ്റ ബാക്കപ്പ്
  Future<void> backupData() async {
    try {
      // ഉത്പന്നങ്ങൾ ബാക്കപ്പ്
      final productsSnapshot = await _firestore.collection('products').get();
      final products = productsSnapshot.docs.map((doc) => doc.data()).toList();

      // ഓർഡറുകൾ ബാക്കപ്പ്
      final ordersSnapshot = await _firestore.collection('orders').get();
      final orders = ordersSnapshot.docs.map((doc) => doc.data()).toList();

      // ബാക്കപ്പ് ഡാറ്റ സേവ് ചെയ്യുക
      await _firestore.collection('backups').doc('latest').set({
        'products': products,
        'orders': orders,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('ഡാറ്റ ബാക്കപ്പ് വിജയകരമായി');
    } catch (e) {
      print('ഡാറ്റ ബാക്കപ്പ് പരാജയപ്പെട്ടു: $e');
    }
  }

  // ഡാറ്റ റെസ്റ്റോർ
  Future<void> restoreData() async {
    try {
      // ബാക്കപ്പ് ഡാറ്റ ലോഡ് ചെയ്യുക
      final backupSnapshot =
          await _firestore.collection('backups').doc('latest').get();
      final backupData = backupSnapshot.data();

      if (backupData != null) {
        // ഉത്പന്നങ്ങൾ റെസ്റ്റോർ
        final products = backupData['products'] as List;
        for (var product in products) {
          await _firestore.collection('products').add(product);
        }

        // ഓർഡറുകൾ റെസ്റ്റോർ
        final orders = backupData['orders'] as List;
        for (var order in orders) {
          await _firestore.collection('orders').add(order);
        }
      }

      print('ഡാറ്റ റെസ്റ്റോർ വിജയകരമായി');
    } catch (e) {
      print('ഡാറ്റ റെസ്റ്റോർ പരാജയപ്പെട്ടു: $e');
    }
  }

  // Add review for a product
  Future<void> addReview(String productId, String userId, String userName,
      double rating, String comment) async {
    try {
      await _firestore.collection('reviews').add({
        'productId': productId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  // Get reviews for a product
  Future<List<Map<String, dynamic>>> getProductReviews(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting reviews: $e');
      rethrow;
    }
  }

  // Get average rating for a product
  Future<double> getProductAverageRating(String productId) async {
    try {
      final reviews = await getProductReviews(productId);
      if (reviews.isEmpty) return 0.0;

      final totalRating = reviews.fold(
          0.0, (sum, review) => sum + (review['rating'] as double));
      return totalRating / reviews.length;
    } catch (e) {
      print('Error calculating average rating: $e');
      rethrow;
    }
  }

  // Get reviews stream for a product
  Stream<List<Map<String, dynamic>>> getReviewsStream(String productId) {
    return _firestore
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Get products stream
  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
