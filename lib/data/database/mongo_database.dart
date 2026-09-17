import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/customer.dart';
import '../../domain/models/transaction.dart';
import '../../config/api_config.dart';
import 'database_interface.dart';

class MongoDatabase implements DatabaseInterface {
  static final MongoDatabase _instance = MongoDatabase._internal();
  
  // Use ApiConfig for platform-specific API URLs
  String get apiBaseUrl => ApiConfig.apiUrl;
  
  factory MongoDatabase() {
    return _instance;
  }

  MongoDatabase._internal() {
    print('🔧 [MongoDatabase] Initialized with API URL: $apiBaseUrl');
  }
  
  @override
  String get databaseType => 'MongoDB';
  
  @override
  Future<void> initialize() async {
    print('📦 [MongoDatabase] Initializing MongoDB connection...');
    // MongoDB doesn't need initialization
    print('✅ [MongoDatabase] MongoDB ready');
  }
  
  @override
  Future<bool> isReady() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<void> close() async {
    // MongoDB doesn't need closing
    print('🔒 [MongoDatabase] MongoDB connection closed');
  }

  // ===== CUSTOMERS =====

  Future<dynamic> addCustomer(Customer customer) async {
    try {
      final url = '$apiBaseUrl/customers';
      print('📤 [MongoDatabase] POST $url');
      print('📦 [MongoDatabase] Data: ${customer.name}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': customer.name,
          'phone': customer.phone,
          'createdAt': customer.createdAt.toIso8601String(),
        }),
      );

      print('📥 [MongoDatabase] Response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [MongoDatabase] Customer added: ${data['_id'] ?? data['id']}');
        return data['_id'] ?? data['id'] ?? 0;
      }
      print('❌ [MongoDatabase] Failed: ${response.body}');
      throw Exception('Failed to add customer: ${response.body}');
    } catch (e) {
      print('❌ [MongoDatabase] Error adding customer: $e');
      throw Exception('Error adding customer: $e');
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      final url = '$apiBaseUrl/customers';
      print('📤 [MongoDatabase] GET $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 [MongoDatabase] Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ [MongoDatabase] Retrieved ${data.length} customers');
        return data.map((json) => Customer(
          id: json['_id'] ?? json['id'],
          name: json['name'] ?? '',
          phone: json['phone'],
          createdAt: DateTime.parse(json['createdAt']),
        )).toList();
      }
      print('❌ [MongoDatabase] Failed: ${response.body}');
      throw Exception('Failed to fetch customers: ${response.body}');
    } catch (e) {
      print('❌ [MongoDatabase] Error fetching customers: $e');
      throw Exception('Error fetching customers: $e');
    }
  }

  Future<Customer?> getCustomerById(dynamic id) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/customers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Customer(
          id: json['_id'] ?? json['id'],
          name: json['name'] ?? '',
          phone: json['phone'],
          createdAt: DateTime.parse(json['createdAt']),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching customer: $e');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/customers/${customer.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': customer.name,
          'phone': customer.phone,
          'createdAt': customer.createdAt.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/customers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete customer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting customer: $e');
    }
  }

  // ===== TRANSACTIONS =====

  Future<dynamic> addTransaction(Transaction transaction) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': transaction.customerId.toString(),
          'type': transaction.type.toString().split('.').last.toLowerCase(),
          'amount': transaction.amount,
          'note': transaction.note,
          'selectedItems': transaction.selectedItems,
          'createdAt': transaction.createdAt.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['_id'] ?? data['id'] ?? 0;
      }
      throw Exception('Failed to add transaction: ${response.body}');
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  Future<List<Transaction>> getAllTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Transaction(
          id: json['_id'] ?? json['id'],
          customerId: json['customerId'],
          type: TransactionType.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == (json['type'] ?? 'CREDIT').toString().toLowerCase(),
            orElse: () => TransactionType.CREDIT,
          ),
          amount: double.tryParse(json['amount'].toString()) ?? 0.0,
          note: json['note'],
          selectedItems: List<String>.from(json['selectedItems'] ?? []),
          createdAt: DateTime.parse(json['createdAt']),
        )).toList();
      }
      throw Exception('Failed to fetch transactions: ${response.body}');
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Future<List<Transaction>> getTransactionsByCustomerId(dynamic customerId) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/transactions/customer/$customerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction(
        id: json['_id'] ?? json['id'],
        customerId: json['customerId'],
        type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == (json['type'] ?? 'CREDIT').toString().toLowerCase(),
          orElse: () => TransactionType.CREDIT,
        ),
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        note: json['note'],
        selectedItems: List<String>.from(json['selectedItems'] ?? []),
        createdAt: DateTime.parse(json['createdAt']),
      )).where((t) => t.customerId.toString() == customerId.toString()).toList();
    }
    throw Exception('Failed to fetch transactions: ${response.body}');
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final response = await http.put(
        Uri.parse('$apiBaseUrl/transactions/${transaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customerId': transaction.customerId.toString(),
          'type': transaction.type.toString().split('.').last.toLowerCase(),
          'amount': transaction.amount,
          'note': transaction.note,
          'selectedItems': transaction.selectedItems,
          'createdAt': transaction.createdAt.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(dynamic id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/transactions/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transaction: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  Future<void> deleteAllTransactionsByCustomerId(dynamic customerId) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiBaseUrl/transactions/customer/$customerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete transactions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting transactions: $e');
    }
  }
  
  // ===== SYNC OPERATIONS (Not implemented for MongoDB) =====
  
  @override
  Future<DateTime?> getLastSyncTime() async => null;
  
  @override
  Future<void> setLastSyncTime(DateTime time) async {}
  
  @override
  Future<List<Map<String, dynamic>>> getPendingSyncOperations() async => [];
  
  @override
  Future<void> addSyncOperation(String operation, String entityType, dynamic entityId, Map<String, dynamic> data) async {}
  
  @override
  Future<void> removeSyncOperation(int operationId) async {}
}
