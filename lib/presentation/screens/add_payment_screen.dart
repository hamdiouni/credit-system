import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../domain/models/transaction.dart';
import '../../generated/app_localizations.dart';
import '../../utils/validators.dart';
import '../../widgets/confirmation_dialog.dart';

class AddPaymentScreen extends StatefulWidget {
  final dynamic customerId;

  const AddPaymentScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _commentFocusNode = FocusNode();
  final _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _allowOverpayment = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus amount field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _commentController.dispose();
    _amountFocusNode.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Auto-scroll to bottom (buttons) with smooth animation
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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

  void _savePayment() async {
    final l10n = AppLocalizations.of(context);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      
      // Get current debt to check for overpayment
      final provider = context.read<TransactionProvider>();
      final transactions = await provider.getCustomerTransactions(widget.customerId);
      
      // Calculate current debt
      double totalCredit = 0;
      double totalPayment = 0;
      double balanceCredit = 0;
      
      for (final txn in transactions) {
        if (txn.type == TransactionType.CREDIT) {
          totalCredit += txn.amount;
        } else if (txn.type == TransactionType.PAYMENT) {
          totalPayment += txn.amount;
        } else if (txn.type == TransactionType.BALANCE_CREDIT) {
          balanceCredit += txn.amount;
        }
      }
      
      final currentDebt = (totalCredit - totalPayment - balanceCredit).clamp(0.0, double.infinity);
      
      // Check for overpayment
      if (amount > currentDebt && !_allowOverpayment) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.overpaymentError(
                      amount.toStringAsFixed(3),
                      currentDebt.toStringAsFixed(3),
                    )),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() => _isLoading = true);

      // If overpayment is allowed and amount exceeds debt
      if (amount > currentDebt && _allowOverpayment) {
        // Calculate balance amount
        final balanceAmount = amount - currentDebt;
        
        // Confirm overpayment
        final confirmed = await ConfirmationDialog.showConfirmation(
          context: context,
          title: 'Confirm Overpayment',
          message: 'Payment amount (${amount.toStringAsFixed(3)} TND) exceeds debt (${currentDebt.toStringAsFixed(3)} TND).\n\n'
                   'Balance credit of ${balanceAmount.toStringAsFixed(3)} TND will be added to customer account.\n\n'
                   'Continue?',
          confirmText: 'Confirm',
          cancelText: 'Cancel',
          icon: Icons.info_outline,
          confirmColor: Colors.blue,
        );
        
        if (!confirmed || !mounted) {
          setState(() => _isLoading = false);
          return;
        }
        
        // Split into payment and balance credit
        final paymentAmount = currentDebt;
        
        // Add payment transaction
        if (paymentAmount > 0) {
          final paymentTransaction = Transaction(
            id: 0,
            customerId: widget.customerId,
            amount: paymentAmount,
            type: TransactionType.PAYMENT,
            note: _commentController.text.isNotEmpty ? _commentController.text : null,
            createdAt: _selectedDate,
          );
          await provider.addTransaction(paymentTransaction);
        }
        
        // Add balance credit transaction
        final balanceTransaction = Transaction(
          id: 0,
          customerId: widget.customerId,
          amount: balanceAmount,
          type: TransactionType.BALANCE_CREDIT,
          note: 'Overpayment balance credit',
          createdAt: _selectedDate,
        );
        await provider.addTransaction(balanceTransaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.paymentAddedWithBalance(balanceAmount.toStringAsFixed(3)))),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Normal payment
        final transaction = Transaction(
          id: 0,
          customerId: widget.customerId,
          amount: amount,
          type: TransactionType.PAYMENT,
          note: _commentController.text.isNotEmpty ? _commentController.text : null,
          createdAt: _selectedDate,
        );

        await provider.addTransaction(transaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(l10n.paymentAdded)),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e, stackTrace) {
      print('❌ [AddPaymentScreen] Error: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
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
        title: Text(l10n.addPayment),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.payment),
                  suffixText: 'TND',
                  helperText: 'Enter payment amount',
                ),
                validator: Validators.validateAmount,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) => _scrollToBottom(),
              ),
            const SizedBox(height: 16),
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
            TextFormField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              enabled: !_isLoading,
              textInputAction: TextInputAction.done,
              onTap: () => _scrollToBottom(),
              onChanged: (_) => _scrollToBottom(),
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
            const SizedBox(height: 16),
            
            // Overpayment checkbox
            CheckboxListTile(
              title: Text(l10n.allowOverpayment),
              subtitle: Text(l10n.allowOverpaymentSubtitle),
              value: _allowOverpayment,
              enabled: !_isLoading,
              onChanged: (val) {
                setState(() => _allowOverpayment = val ?? false);
              },
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
                  onPressed: _isLoading ? null : _savePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
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
