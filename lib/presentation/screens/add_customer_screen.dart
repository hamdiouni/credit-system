import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../generated/app_localizations.dart';
import '../../domain/models/customer.dart';
import '../../data/repositories/exceptions.dart';
import '../../utils/validators.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveCustomer() async {
    final l10n = AppLocalizations.of(context);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = context.read<CustomerProvider>();
      final normalizedPhone = _phoneController.text.trim();
      if (normalizedPhone.isNotEmpty) {
        final exists = provider.customersWithDebt.any((c) =>
            c.customer.phone != null && c.customer.phone!.trim() == normalizedPhone);
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.phoneInUse),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      setState(() => _isLoading = true);

      final createdId = await provider.addCustomer(
        Customer(
          id: null,
          name: _nameController.text,
          phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
          createdAt: DateTime.now(),
        ),
      );

      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        provider.clearError();
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.customerAdded)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context, createdId ?? true); // return id when available
      }
    } catch (e) {
      if (mounted) {
        print('❌ [AddCustomerScreen] Error caught: $e');
        final l10n = AppLocalizations.of(context);
        if (e is PhoneInUseException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.phoneInUse)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${l10n.error}: ${e.toString()}')),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCustomer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: l10n.customerName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  helperText: 'Enter customer full name',
                ),
                validator: Validators.validateName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                  helperText: 'Optional - Enter phone number',
                ),
                validator: Validators.validatePhone,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 24),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
