import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart' as models;
import '../models/product.dart';

class CategoryProvider with ChangeNotifier {
  final List<models.Category> _categories = [];

  List<models.Category> get categories => _categories;

  models.Category getCategoryById(String id) {
    return _categories.firstWhere((category) => category.id == id);
  }

  List<models.Category> getCategoriesBySearch(String query) {
    if (query.isEmpty) {
      return _categories;
    }
    return _categories
        .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void addCategoryFromProduct(Product product) {
    if (!_categories.any((category) => category.name == product.category)) {
      _categories.add(models.Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: product.category,
        image: 'https://example.com/category_placeholder.jpg',
      ));
      notifyListeners();
    }
  }

  void addCategory(models.Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(models.Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }
}
