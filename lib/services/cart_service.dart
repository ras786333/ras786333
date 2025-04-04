import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(String userId, Product product, int quantity) async {
    try {
      await _firestore.collection('carts').doc(userId).collection('items').add({
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'quantity': quantity,
        'imageUrl': product.imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding to cart: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error getting cart items: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String userId, String itemId) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      print('Error removing from cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(
      String userId, String itemId, int quantity) async {
    try {
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(itemId)
          .update({'quantity': quantity});
    } catch (e) {
      print('Error updating cart item quantity: $e');
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}
