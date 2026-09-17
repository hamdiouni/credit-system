class Customer {
  final dynamic id;
  final String name;
  final String? phone;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  Customer copyWith({
    dynamic id,
    String? name,
    String? phone,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

    @override
    String toString() =>
      'Customer(id: $id, name: $name, phone: $phone, createdAt: $createdAt)';

    @override
    bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        name == other.name &&
        phone == other.phone &&
        createdAt == other.createdAt;

    @override
    int get hashCode =>
      id.hashCode ^ name.hashCode ^ phone.hashCode ^ createdAt.hashCode;
}
