import 'dart:convert';

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/contants.dart';

class ProductList with ChangeNotifier {
  List<Product> _items = [];
  String _token;

  // List<Product> _items = [];
  ProductList([this._token = '', this._items = const []]);
  List<Product> get items => [..._items]; // [..._items] é um clone da lista _items.
  List<Product> get favoriteItems => _items.where((product) => product.isFavorite).toList(); // [..._items] é um clone da lista _items.

  int get itemCount {
    return _items.length;
  }

  Future<void> loadProducts(String userId) async {
    _items.clear();

    final productsUri = Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token');
    final favUri = Uri.parse('${Constants.USER_FAVORITE_URL}/$userId.json?auth=$_token');

    final response = await http.get(productsUri);
    if (response.body == 'null') return;

    final favResponse = await http.get(favUri);
    final favData = favResponse.body == 'null' ? {} : jsonDecode(favResponse.body);

    final Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach((productId, productData) {
      final isFavorite = favData[productId] ?? false;
      _items.add(
        Product(
          id: productId,
          name: productData['name'],
          description: productData['description'],
          price: (productData['price'] as num).toDouble(),
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
        ),
      );
    });

    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final uri = Uri.parse('${Constants.PRODUCT_BASE_URL}.json?auth=$_token');
    final response = await http.post(
      uri,
      body: jsonEncode({
        "name": product.name,
        "description": product.description,
        "price": product.price, // não esqueça do price
        "imageUrl": product.imageUrl,
      }),
    );

    final id = jsonDecode(response.body)['name'];
    _items.add(Product(
      id: id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    int index = _items.indexWhere((p) => p.id == product.id);
    final uri = Uri.parse('${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token');
    if (index >= 0) {
      await http.patch(
        uri,
        body: jsonEncode({
          "name": product.name,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
        }),
      );
      _items[index] = product;
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> removeProduct(Product product) async {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index < 0) return;

    final productToRemove = _items[index];
    // Otimista: remove da lista e atualiza UI
    _items.removeAt(index);
    notifyListeners();

    try {
      final uri = Uri.parse(
        '${Constants.PRODUCT_BASE_URL}/${product.id}.json?auth=$_token',
      );

      final response = await http.delete(uri);

      // Logs de diagnóstico — remova em produção
      debugPrint('DELETE $uri => ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode >= 400) {
        // Falhou no servidor: desfaz localmente
        _items.insert(index, productToRemove);
        notifyListeners();
        throw HttpsException(
          msg: 'Não foi possível excluir o produto.',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Exceção (rede, parse, etc): desfaz localmente
      _items.insert(index, productToRemove);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;
    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      name: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );
    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }
}
