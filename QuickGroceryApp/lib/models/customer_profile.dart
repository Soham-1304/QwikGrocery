class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.line1,
    this.line2 = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.postalCode,
    this.latitude,
    this.longitude,
  });
  final String id,
      label,
      recipientName,
      phone,
      line1,
      line2,
      landmark,
      city,
      state,
      postalCode;
  final double? latitude, longitude;
  bool get hasMapPin => latitude != null && longitude != null;
  String get formatted => [
    line1,
    line2,
    landmark,
    city,
    state,
    postalCode,
  ].where((part) => part.trim().isNotEmpty).join(', ');
  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: json['id'] as String? ?? '',
    label: json['label'] as String? ?? 'Address',
    recipientName: json['recipientName'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    line1: json['line1'] as String? ?? '',
    line2: json['line2'] as String? ?? '',
    landmark: json['landmark'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    postalCode: json['postalCode'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble(),
    longitude: (json['longitude'] as num?)?.toDouble(),
  );
  Map<String, dynamic> toJson() => {
    'label': label,
    'recipientName': recipientName,
    'phone': phone,
    'line1': line1,
    'line2': line2,
    'landmark': landmark,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    if (latitude != null && longitude != null) 'latitude': latitude,
    if (latitude != null && longitude != null) 'longitude': longitude,
  };
}

class SavedPaymentMethod {
  const SavedPaymentMethod({
    required this.id,
    required this.type,
    required this.label,
    this.lastFour = '',
    this.upiId = '',
  });
  final String id, type, label, lastFour, upiId;
  String get display =>
      type == 'card' ? '$label •••• $lastFour' : '$label · $upiId';
  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) =>
      SavedPaymentMethod(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? 'upi',
        label: json['label'] as String? ?? '',
        lastFour: json['lastFour'] as String? ?? '',
        upiId: json['upiId'] as String? ?? '',
      );
}

class CustomerProfile {
  const CustomerProfile({
    this.name = '',
    this.email = '',
    this.role = 'customer',
    this.addresses = const [],
    this.paymentMethods = const [],
  });
  final String name, email, role;
  final List<SavedAddress> addresses;
  final List<SavedPaymentMethod> paymentMethods;
  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'customer',
        addresses: (json['addresses'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(SavedAddress.fromJson)
            .toList(),
        paymentMethods: (json['paymentMethods'] as List? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(SavedPaymentMethod.fromJson)
            .toList(),
      );
}
