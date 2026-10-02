import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import '../models.dart';
import 'session.dart';

class ApiClient {
  ApiClient({required this._session, http.Client? client})
    : _client = client ?? http.Client();

  final SessionController _session;
  final http.Client _client;
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000/api',
  );

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Future<Map<String, String>> _headers({bool authenticated = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated) {
      final token = await _session.token;
      if (token == null) throw const ApiException('Sign in to continue.');
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map<String, dynamic>
          ? (body['error'] as String? ?? 'The request could not be completed.')
          : 'The request could not be completed.';
      throw ApiException(message, statusCode: response.statusCode);
    }
    return body;
  }

  Future<List<Product>> products({
    String search = '',
    String category = '',
    bool? available,
  }) async {
    final query = <String, String>{};
    if (search.trim().isNotEmpty) query['search'] = search.trim();
    if (category.isNotEmpty) query['category'] = category;
    if (available != null) query['available'] = '$available';
    final response = await _client.get(
      _uri('/products', query),
      headers: await _headers(),
    );
    return (_decode(response) as List)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> product(String id) async {
    final response = await _client.get(
      _uri('/products/$id'),
      headers: await _headers(),
    );
    return Product.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<GroceryOrder>> orders() async {
    final response = await _client.get(
      _uri('/orders'),
      headers: await _headers(authenticated: true),
    );
    return (_decode(response) as List)
        .map((item) => GroceryOrder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<GroceryOrder> order(String id) async {
    final response = await _client.get(
      _uri('/orders/$id'),
      headers: await _headers(authenticated: true),
    );
    return GroceryOrder.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<GroceryOrder> createOrder({
    required List<CartLine> items,
    required String name,
    required String phone,
    required String address,
  }) async {
    final response = await _client.post(
      _uri('/orders'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({
        'items': items
            .map(
              (line) => {
                'productId': line.product.id,
                'quantity': line.quantity,
              },
            )
            .toList(),
        'customerName': name,
        'phone': phone,
        'address': address,
      }),
    );
    return GroceryOrder.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<GrocerySubscription>> subscriptions() async {
    final response = await _client.get(
      _uri('/subscriptions'),
      headers: await _headers(authenticated: true),
    );
    return (_decode(response) as List)
        .map(
          (item) => GrocerySubscription.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<GrocerySubscription> saveSubscription({
    String? id,
    required String productId,
    required int quantity,
    required String frequency,
    required DateTime startDate,
    required String deliveryTime,
  }) async {
    final body = jsonEncode({
      'productId': productId,
      'quantity': quantity,
      'frequency': frequency,
      'startDate': startDate.toIso8601String(),
      'deliveryTime': deliveryTime,
    });
    final response = id == null
        ? await _client.post(
            _uri('/subscriptions'),
            headers: await _headers(authenticated: true),
            body: body,
          )
        : await _client.patch(
            _uri('/subscriptions/$id'),
            headers: await _headers(authenticated: true),
            body: body,
          );
    return GrocerySubscription.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  Future<void> setSubscriptionActive(String id, bool active) async {
    final response = await _client.patch(
      _uri('/subscriptions/$id'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({'active': active}),
    );
    _decode(response);
  }
}
