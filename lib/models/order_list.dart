import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/contants.dart';

class OrderList with ChangeNotifier {
  List<Order> _items = [];
  final String? _token;
  final String? _userId;

  OrderList([this._token = '', this._items = const [], this._userId = '']);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();

    final uri = Uri.parse('${Constants.ORDER_BASE_URL}/$_userId.json?auth=$_token');
    final response = await http.post(
      uri,
      body: jsonEncode({
        "total": cart.totalAmount,
        "date": date.toIso8601String(),
        "products": cart.items.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'name': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );

    final id = jsonDecode(response.body)['name'];

    _items.insert(
      0,
      Order(
        id: id,
        total: cart.totalAmount,
        products: cart.items.values.toList(),
        date: date,
      ),
    );

    notifyListeners();
  }

  Future<void> loadOrders() async {
    List<Order> items = [];

    final uri = Uri.parse('${Constants.ORDER_BASE_URL}/$_userId.json?auth=$_token');
    final response = await http.get(uri);

    if (response.body == 'null') return;

    final Map<String, dynamic> data = jsonDecode(response.body);

    data.forEach((orderId, orderData) {
      items.add(
        Order(
          id: orderId,
          date: DateTime.parse(orderData['date']),
          total: orderData['total'],
          products: (orderData['products'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['name'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList(),
        ),
      );
    });

    // Coloca do mais recente para o mais antigo
    _items = items.reversed.toList();
    notifyListeners();
  }
}
