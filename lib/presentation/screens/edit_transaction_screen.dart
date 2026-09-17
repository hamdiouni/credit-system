import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/grocery_item.dart';
import '../../generated/app_localizations.dart';
import '../../utils/validators.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _commentController;
  late DateTime _selectedDate;
  late Map<String, int> _selectedItemsWithQty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _commentController = TextEditingController(text: widget.transaction.note ?? '');
    _selectedDate = widget.transaction.createdAt;
    
    // Parse selected items
    _selectedItemsWithQty = {};
    for (final item in widget.transaction.selectedItems) {
      final parts = item.split(':');
      final key = parts[0];
      final qty = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
      _selectedItemsWithQty[key] = qty;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      final itemsList = _selectedItemsWithQty.entries
          .map((e) => '${e.key}:${e.value}')
          .toList();
      
      final updatedTransaction = widget.transaction.copyWith(
        amount: amount,
        note: _commentController.text.isNotEmpty ? _commentController.text : null,
        selectedItems: itemsList,
        createdAt: _selectedDate,
      );

      setState(() => _isLoading = true);

      await context.read<TransactionProvider>().updateTransaction(updatedTransaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Transaction updated successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Update failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'sugar': return l10n.sugar;
      case 'milk': return l10n.milk;
      case 'oil': return l10n.oil;
      case 'rice': return l10n.rice;
      case 'flour': return l10n.flour;
      case 'tea': return l10n.tea;
      case 'coffee': return l10n.coffee;
      case 'butter': return l10n.butter;
      case 'cheese': return l10n.cheese;
      case 'eggs': return l10n.eggs;
      case 'salt': return l10n.salt;
      case 'detergent': return l10n.detergent;
      case 'soap': return l10n.soap;
      case 'chocolate': return l10n.chocolate;
      case 'biscuits': return l10n.biscuits;
      case 'tomato': return l10n.tomato;
      case 'onion': return l10n.onion;
      case 'potato': return l10n.potato;
      case 'bread': return l10n.bread;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isCredit = widget.transaction.type == TransactionType.CREDIT;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCredit ? 'Edit Credit' : 'Edit Payment'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Editing ${isCredit ? "credit" : "payment"} transaction',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'TND',
                  helperText: 'Enter ${isCredit ? "credit" : "payment"} amount',
                ),
                validator: Validators.validateAmount,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 16),

              // Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.date}: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _selectDate(context),
                    child: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grocery Items (only for credit transactions)
              if (isCredit) ...[
                Text(
                  l10n.selectItems,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...GroceryItems.defaultItems.map((item) {
                  final label = _getLocalizedLabel(context, item.key);
                  final isChecked = _selectedItemsWithQty.containsKey(item.key);
                  final qty = _selectedItemsWithQty[item.key] ?? 1;

                  return Card(
                    child: CheckboxListTile(
                      title: Text(label),
                      subtitle: isChecked
                          ? Row(
                              children: [
                                Text('${l10n.quantity}: '),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    enabled: !_isLoading,
                                    controller: TextEditingController(text: qty.toString()),
                                    onChanged: (val) {
                                      setState(() {
                                        final q = int.tryParse(val) ?? 1;
                                        _selectedItemsWithQty[item.key] = q > 0 ? q : 1;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.all(4),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                      value: isChecked,
                      enabled: !_isLoading,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedItemsWithQty[item.key] = 1;
                          } else {
                            _selectedItemsWithQty.remove(item.key);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],

              // Comment
              TextFormField(
                controller: _commentController,
                enabled: !_isLoading,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: l10n.optionalComment,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                  helperText: 'Optional - Add a note',
                ),
                validator: Validators.validateNote,
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
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
