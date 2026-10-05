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
    defaultValue: 'https://qwikgrocery.onrender.com/api',
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

  Future<CustomerProfile> profile() async {
    final response = await _client.get(
      _uri('/profile'),
      headers: await _headers(authenticated: true),
    );
    return CustomerProfile.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> saveProfileName(String name) async {
    final response = await _client.patch(
      _uri('/profile'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({'name': name}),
    );
    _decode(response);
  }

  Future<void> updateProfile({String? name}) async {
    if (name != null) {
      await saveProfileName(name);
    }
  }

  Future<SavedAddress> addAddress(SavedAddress address) async {
    final response = await _client.post(
      _uri('/profile/addresses'),
      headers: await _headers(authenticated: true),
      body: jsonEncode(address.toJson()),
    );
    return SavedAddress.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> deleteAddress(String id) async {
    final response = await _client.delete(
      _uri('/profile/addresses/$id'),
      headers: await _headers(authenticated: true),
    );
    _decode(response);
  }

  Future<SavedPaymentMethod> addPaymentMethod({
    required String type,
    required String label,
    String lastFour = '',
    String upiId = '',
  }) async {
    final response = await _client.post(
      _uri('/profile/payment-methods'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({
        'type': type,
        'label': label,
        if (type == 'card') 'lastFour': lastFour,
        if (type == 'upi') 'upiId': upiId,
      }),
    );
    return SavedPaymentMethod.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  Future<void> deletePaymentMethod(String id) async {
    final response = await _client.delete(
      _uri('/profile/payment-methods/$id'),
      headers: await _headers(authenticated: true),
    );
    _decode(response);
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

  Stream<GroceryOrder> orderStream(
    String id, {
    Duration pollInterval = const Duration(seconds: 2),
  }) async* {
    while (true) {
      try {
        final current = await order(id);
        yield current;
        if (current.status == 'delivered' || current.status == 'cancelled') {
          break;
        }
      } catch (_) {
        // Silently tolerate intermittent connection jitter
      }
      await Future<void>.delayed(pollInterval);
    }
  }

  Future<GroceryOrder> createOrder({
    required List<CartLine> items,
    required String name,
    required String phone,
    required String address,
    String? paymentMethodId,
    String? addressId,
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
        if (addressId != null) 'addressId': addressId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      }),
    );
    return GroceryOrder.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<List<GroceryOrder>> staffOrders() async {
    final response = await _client.get(
      _uri('/orders/staff'),
      headers: await _headers(authenticated: true),
    );
    return (_decode(response) as List)
        .map((item) => GroceryOrder.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<GroceryOrder> setOrderStatus(String id, String status) async {
    final response = await _client.patch(
      _uri('/orders/$id/status'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({'status': status}),
    );
    return GroceryOrder.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<WalletSummary> wallet() async {
    final response = await _client.get(
      _uri('/wallet'),
      headers: await _headers(authenticated: true),
    );
    return WalletSummary.fromJson(_decode(response) as Map<String, dynamic>);
  }

  Future<void> topUpWallet(int amountCents) async {
    final response = await _client.post(
      _uri('/wallet/topups'),
      headers: await _headers(authenticated: true),
      body: jsonEncode({'amountCents': amountCents}),
    );
    _decode(response);
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
    required List<Map<String, dynamic>> items,
    required String addressId,
    required String frequency,
    required DateTime startDate,
    required String deliveryTime,
  }) async {
    final body = jsonEncode({
      'items': items,
      'addressId': addressId,
      'frequency': frequency,
      'startDate': startDate.toIso8601String().split('T').first,
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

  Future<void> deleteSubscription(String id) async {
    final response = await _client.delete(
      _uri('/subscriptions/$id'),
      headers: await _headers(authenticated: true),
    );
    _decode(response);
  }
}
