import 'dart:convert';

enum TransactionType { CREDIT, PAYMENT, BALANCE_CREDIT }

class Transaction {
  final dynamic id;
  final dynamic customerId;
  final TransactionType type;
  final double amount;
  final String? note;
  final DateTime createdAt;
  final List<String> selectedItems; // Grocery items

  Transaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.note,
    required this.createdAt,
    this.selectedItems = const [],
  });

  Transaction copyWith({
    dynamic id,
    dynamic customerId,
    TransactionType? type,
    double? amount,
    String? note,
    DateTime? createdAt,
    List<String>? selectedItems,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }

  // Serialize selectedItems to JSON string for storage
  String get selectedItemsJson => jsonEncode(selectedItems);

  // Deserialize selectedItems from JSON string
  static List<String> parseSelectedItems(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.cast<String>().toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'note': note,
      'selected_items': selectedItemsJson,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      customerId: map['customer_id'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
      ),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
      selectedItems: parseSelectedItems(map['selected_items'] as String?),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() =>
      'Transaction(id: $id, customerId: $customerId, type: $type, amount: $amount, note: $note, selectedItems: $selectedItems, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          type == other.type &&
          amount == other.amount &&
          note == other.note &&
          selectedItems == other.selectedItems &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      customerId.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      note.hashCode ^
      selectedItems.hashCode ^
      createdAt.hashCode;
}
