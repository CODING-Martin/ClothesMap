import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};
  final List<ProductModel> _products = [];

  Map<String, int> get items => Map.unmodifiable(_items);

  int get itemCount => _items.values.fold(0, (sum, qty) => sum + qty);

  double get totalPrice {
    double total = 0;
    for (final entry in _items.entries) {
      final product = _products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => const ProductModel(
          id: '',
          storeId: '',
          name: '',
          description: '',
          price: 0,
          category: '',
        ),
      );
      total += product.effectivePrice * entry.value;
    }
    return total;
  }

  void addItem(ProductModel product) {
    if (!_products.any((p) => p.id == product.id)) {
      _products.add(product);
    }
    _items[product.id] = (_items[product.id] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]! <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = _items[productId]! - 1;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int getQuantity(String productId) => _items[productId] ?? 0;

  bool contains(String productId) => _items.containsKey(productId);
}
