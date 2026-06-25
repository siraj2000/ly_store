class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.country,
    required this.city,
    required this.region,
    required this.streetAddress,
    required this.postalCode,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String phone;
  final String country;
  final String city;
  final String region;
  final String streetAddress;
  final String postalCode;
  final bool isDefault;

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? country,
    String? city,
    String? region,
    String? streetAddress,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      region: region ?? this.region,
      streetAddress: streetAddress ?? this.streetAddress,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      streetAddress: json['streetAddress'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'country': country,
    'city': city,
    'region': region,
    'streetAddress': streetAddress,
    'postalCode': postalCode,
    'isDefault': isDefault,
  };
}
