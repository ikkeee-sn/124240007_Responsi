import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> getProducts({int limit = 30}) async {
    final response = await http.get(Uri.parse('$baseUrl/products?limit=$limit'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List productsJson = data['products'] ?? [];
      return productsJson.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk (Status: ${response.statusCode})');
    }
  }

  static Future<Product> getSingleProduct(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Gagal memuat detail produk #$id (Status: ${response.statusCode})');
    }
  }

  static Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/products/category-list'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => item.toString()).toList();
    } else {
      throw Exception('Gagal memuat kategori (Status: ${response.statusCode})');
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    final encodedCategory = Uri.encodeComponent(category);
    final response = await http.get(Uri.parse('$baseUrl/products/category/$encodedCategory'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List productsJson = data['products'] ?? [];
      return productsJson.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat produk kategori $category (Status: ${response.statusCode})');
    }
  }
}
