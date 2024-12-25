
// ChangeNotifier for managing the cart
import 'package:billing_app/Model/product.model.dart';
import 'package:flutter/material.dart';

class Cart with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items => _items;

  void addItem(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void updateItem(int index, Product product) {
    _items[index] = product;
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  double get total {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get discount {
    return total > 100 ? total * 0.1 : 0; // Example discount logic
  }

  double get tax {
    return total * 0.05; // Example tax logic
  }

  double get finalTotal {
    return total - discount + tax;
  }
}