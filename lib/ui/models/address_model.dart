class AddressModel {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String address;
  final String details;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.address,
    this.details = '',
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? name,
    String? phone,
    String? address,
    String? details,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      details: details ?? this.details,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'name': name,
      'phone': phone,
      'address': address,
      'details': details,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      details: json['details'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
