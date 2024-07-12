import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/products.dart';

class TimbuApiService {
  final String baseUrl = 'https://api.timbu.cloud';

  Future<List<Product>> fetchProducts({int page = 1, int size = 20}) async {
    final apiKey = dotenv.env['APIKEY'];
    final appId = dotenv.env['APPID'];
    final organizationId = dotenv.env['ORGANIZATIONID'];

    final url = '$baseUrl/products?organization_id=$organizationId&reverse_sort=false&page=$page&size=$size&Appid=$appId&Apikey=$apiKey';
    print('Fetching products from: $url'); // Debug print

    final response = await http.get(Uri.parse(url));

    print('Response status code: ${response.statusCode}'); // Debug print
    print('Response body: ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData.containsKey('items') && responseData['items'] is List) {
        final List<dynamic> productsJson = responseData['items'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        print('Unexpected response structure: $responseData'); // Debug print
        return [];
      }
    } else {
      throw Exception('Failed to load products');
    }
  }
}