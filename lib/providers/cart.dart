import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String img;
  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price,
      this.img});
}

class Cart extends ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title, String img) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity + 1,
          img: value.img,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
          img: img,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId].quantity > 1) {
      _items.update(
        productId,
        (value) => CartItem(
            id: value.id,
            title: value.title,
            quantity: value.quantity,
            price: value.price),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
