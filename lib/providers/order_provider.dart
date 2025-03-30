import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('orders');
      if (ordersJson != null) {
        final List<dynamic> decoded = json.decode(ordersJson);
        _orders = decoded.map((item) => Order.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_orders.map((o) => o.toJson()).toList());
      await prefs.setString('orders', encoded);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    await saveData();
    notifyListeners();
  }

  Future<void> updateOrder(Order order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index >= 0) {
      _orders[index] = order;
      await saveData();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String id) async {
    _orders.removeWhere((order) => order.id == id);
    await saveData();
    notifyListeners();
  }

  Order findById(String id) {
    return _orders.firstWhere((order) => order.id == id);
  }
}
