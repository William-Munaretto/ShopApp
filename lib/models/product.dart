import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/contants.dart';

class Product with ChangeNotifier {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Future<void> toggleFavorite(String token, String userId) async {
    _toggleFavorite(); // atualiza otimistamente a UI
    try {
      final uri = Uri.parse(
        '${Constants.USER_FAVORITE_URL}/$userId/$id.json?auth=$token',
      );

      final response = await http.put(
        uri,
        body: jsonEncode(isFavorite),
      );

      if (response.statusCode >= 400) {
        _toggleFavorite(); // rollback em caso de erro no servidor
      }
    } catch (error) {
      _toggleFavorite(); // rollback em caso de exceção (rede, etc)
    }
  }
}
