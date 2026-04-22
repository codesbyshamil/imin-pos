import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _taxRate = 0.08; // 8% tax
  String _orderNumber = '';

  List<CartItem> get items => List.unmodifiable(_items);
  double get taxRate => _taxRate;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get taxAmount => subtotal * _taxRate;

  double get total => subtotal + taxAmount;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  String get orderNumber => _orderNumber;

  void addProduct(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == productId);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _orderNumber = '';
    notifyListeners();
  }

  void setTaxRate(double rate) {
    _taxRate = rate;
    notifyListeners();
  }

  String generateOrderNumber() {
    final now = DateTime.now();
    _orderNumber =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    notifyListeners();
    return _orderNumber;
  }
}
