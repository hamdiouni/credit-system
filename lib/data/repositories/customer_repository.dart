import 'package:credit_app/domain/models/customer.dart';
import 'package:credit_app/data/dao/customer_dao.dart';
import 'exceptions.dart';

class CustomerRepository {
  final CustomerDAO _customerDAO;

  CustomerRepository(this._customerDAO);

  Future<dynamic> createCustomer(String name, String? phone) async {
    // Normalize phone for comparison
    final normalizedPhone = phone?.trim();
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      final all = await getAllCustomers();
      final exists = all.any((c) => c.phone != null && c.phone!.trim() == normalizedPhone);
      if (exists) {
        throw PhoneInUseException();
      }
    }

    final customer = Customer(
      id: null,
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );
    return await _customerDAO.addCustomer(customer);
  }

  Future<List<Customer>> getAllCustomers() async {
    return await _customerDAO.getAllCustomers();
  }

  Future<Customer?> getCustomerById(dynamic id) async {
    return await _customerDAO.getCustomerById(id);
  }

  Future<void> updateCustomer(Customer customer) async {
    // Ensure phone uniqueness on update
    final normalizedPhone = customer.phone?.trim();
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      final all = await getAllCustomers();
      final conflictExists = all.any((c) => c.phone != null && c.phone!.trim() == normalizedPhone && c.id.toString() != customer.id.toString());
      if (conflictExists) {
        throw PhoneInUseException('Phone number already in use by another customer');
      }
    }
    await _customerDAO.updateCustomer(customer);
  }

  Future<void> deleteCustomer(dynamic id) async {
    await _customerDAO.deleteCustomer(id);
  }
}
