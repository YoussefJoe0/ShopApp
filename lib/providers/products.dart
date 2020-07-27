import 'package:flutter/material.dart';
import 'package:shopapp/models/http_exceptions.dart';
import 'product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //     id: '1',
    //     title: 'White',
    //     description: 'this is a te-shirt white its a smooth',
    //     imageUrl:
    //         'https://5.imimg.com/data5/YB/QU/MY-24671135/blank-t-shirt-500x500.jpg',
    //     price: 25.00),
    // Product(
    //     id: '2',
    //     title: 'Black',
    //     description: 'this is a te-shirt black its a dark',
    //     imageUrl:
    //         'https://images.squarespace-cdn.com/content/v1/5c7e4843797f74590fa26ad8/1551886580105-TT57AINOL06SMMMFLLXG/ke17ZwdGBToddI8pDm48kDcfM4wjscSdsbp7HqcZX0IUqsxRUqqbr1mOJYKfIPR7LoDQ9mXPOjoJoqy81S2I8PaoYXhp6HxIwZIk7-Mi3Tsic-L2IOPH3Dwrhl-Ne3Z2kxJ_yMf_wxGZStbloE0XMQLlMRHxq5anmPOMNXBqPywKMshLAGzx4R3EDFOm1kBS/Shirt_Solo.png',
    //     price: 55.00),
    // Product(
    //     id: '3',
    //     title: 'Gray',
    //     description: 'this is a te-shirt gray its a smooth',
    //     imageUrl:
    //         'https://i.ya-webdesign.com/images/transparent-tshirt-gray-2.png',
    //     price: 33.00),
    // Product(
    //     id: '4',
    //     title: 'Blue',
    //     description: 'this is a te-shirt blue its a nice',
    //     imageUrl:
    //         'https://cdn1.brandability.co.za/2019/03/19195237/Mens-All-Star-T-Shirt-Royal-Blue.jpg',
    //     price: 64.00),
    // Product(
    //     id: '5',
    //     title: 'Pink',
    //     description: 'this is a te-shirt pink its a cool',
    //     imageUrl:
    //         'https://www.myshirt.com.my/wp-content/uploads/2016/01/76000-Gildan-Premium-Soft-Spun-T-Shirt-Heliconia.jpg',
    //     price: 44.00),
    // Product(
    //     id: '6',
    //     title: 'Yellow',
    //     description: 'this is a te-shirt yellow its a perfect',
    //     imageUrl:
    //         'https://store.vegemite.com.au/wp-content/uploads/2019/12/Vegemite_Barty_Tshirt.jpg',
    //     price: 32.00),
    // Product(
    //     id: '7',
    //     title: 'Red',
    //     description: 'this is a te-shirt red it is a sexy',
    //     imageUrl:
    //         'https://www.npeal.com/media/catalog/product/cache/1/thumbnail/1440x1800/9df78eab33525d08d6e5fb8d27136e95/a/w/aw19_npw-1803c_red_1.jpg',
    //     price: 35.99),
    // Product(
    //     id: '7',
    //     title: 'Green',
    //     description: 'this is a te-shirt red it is a sexy',
    //     imageUrl:
    //         'https://www.kidswholesaleclothing.co.uk/4131-thickbox_default/baby-blanks-short-sleeve-tshirt-emerald.jpg',
    //     price: 35.99),
  ];

  // final String authToken;
  // Products(this.authToken, this._items);

  var _showFavoritesOnly = false;
  List<Product> get items {
    if (_showFavoritesOnly) {
      return _items.where((element) => element.isFavorite).toList();
    }
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  void showFavoritesOnly() {
    _showFavoritesOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoritesOnly = false;
    notifyListeners();
  }

  Future<void> fetchAndSetProducts() async {
    final url =
        'https://shopapp-7dbdb.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      print(json.decode(response.body));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          isFavorite: prodData['isFavorite'],
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://shopapp-7dbdb.firebaseio.com/products.json';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        id: json.decode(response.body)['name'],
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = 'https://shopapp-7dbdb.firebaseio.com/products/$id.json';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shopapp-7dbdb.firebaseio.com/products/$id.json';
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpExceptions('Could not delete product');
    }
    existingProduct = null;

    notifyListeners();
  }
}
