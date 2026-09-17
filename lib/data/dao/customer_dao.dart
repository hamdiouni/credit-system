import 'package:credit_app/domain/models/customer.dart';
import '../database/database_interface.dart';

class CustomerDAO {
  final DatabaseInterface _db;

  CustomerDAO(this._db);

  Future<dynamic> addCustomer(Customer customer) async {
    return await _db.addCustomer(customer);
  }

  Future<dynamic> createCustomer(Customer customer) async {
    return await _db.addCustomer(customer);
  }

  Future<List<Customer>> getAllCustomers() async {
    return await _db.getAllCustomers();
  }

  Future<Customer?> getCustomerById(dynamic id) async {
    return await _db.getCustomerById(id);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _db.updateCustomer(customer);
  }

  Future<void> deleteCustomer(dynamic id) async {
    await _db.deleteCustomer(id);
  }
}
