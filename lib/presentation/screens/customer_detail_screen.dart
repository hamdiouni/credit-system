import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/user.dart';
import '../../generated/app_localizations.dart';
import '../../services/pdf_service_selector.dart';
import '../../services/csv_export_service.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/advanced_filter_dialog.dart';
import '../../utils/search_helper.dart';
import 'add_credit_screen.dart';
import 'add_payment_screen.dart';
import 'edit_transaction_screen.dart';

class CustomerDetailScreen extends StatefulWidget {
  final dynamic customerId;

  const CustomerDetailScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  String _transactionSearchQuery = '';
  FilterOptions _filterOptions = FilterOptions();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadAllCustomers();
    });
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    // Apply search
    if (_transactionSearchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return SearchHelper.matchesTransactionSearch(
          t.note,
          t.amount,
          _transactionSearchQuery,
        );
      }).toList();
    }

    // Apply filters
    if (_filterOptions.startDate != null || _filterOptions.endDate != null) {
      filtered = filtered.where((t) {
        return SearchHelper.isInDateRange(
          t.createdAt,
          _filterOptions.startDate,
          _filterOptions.endDate,
        );
      }).toList();
    }

    if (_filterOptions.minAmount != null || _filterOptions.maxAmount != null) {
      filtered = filtered.where((t) {
        return SearchHelper.isInAmountRange(
          t.amount,
          _filterOptions.minAmount,
          _filterOptions.maxAmount,
        );
      }).toList();
    }

    if (_filterOptions.transactionTypes != null && _filterOptions.transactionTypes!.isNotEmpty) {
      filtered = filtered.where((t) {
        return _filterOptions.transactionTypes!.contains(t.type);
      }).toList();
    }

    if (_filterOptions.hasNote == true) {
      filtered = filtered.where((t) => t.note != null && t.note!.isNotEmpty).toList();
    }

    return filtered;
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'sugar':
        return l10n.sugar;
      case 'milk':
        return l10n.milk;
      case 'oil':
        return l10n.oil;
      case 'rice':
        return l10n.rice;
      case 'flour':
        return l10n.flour;
      case 'tea':
        return l10n.tea;
      case 'coffee':
        return l10n.coffee;
      case 'butter':
        return l10n.butter;
      case 'cheese':
        return l10n.cheese;
      case 'eggs':
        return l10n.eggs;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.customerDetails),
            actions: [
              // Delete customer button (Admin only)
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (!authProvider.hasPermission(Permission.deleteCustomer)) {
                    return const SizedBox.shrink();
                  }
                  
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: l10n.deleteCustomer,
                    onPressed: () async {
                      final customerData = provider.getCustomerWithDebt(widget.customerId);
                      if (customerData == null) return;
                  
                  final customer = customerData.customer;
                  final hasTransactions = customerData.transactions.isNotEmpty;
                  final debt = customerData.remainingDebt;
                  
                  // Check if customer has unpaid debt
                  if (hasTransactions && debt > 0) {
                    // Customer has debt - cannot delete
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l10n.deleteCustomer)),
                          ],
                        ),
                        content: Text(
                          'Cannot delete customer with unpaid debt.\n\n'
                          'Current debt: ${debt.toStringAsFixed(3)} TND\n\n'
                          'Please collect payment before deleting.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.back),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  
                  // Customer has no debt (or no transactions) - allow deletion with confirmation
                  String confirmMessage = '${l10n.confirmDelete}\n\n${customer.name}';
                  if (hasTransactions) {
                    confirmMessage += '\n\nThis customer has ${customerData.transactions.length} transaction(s) but no outstanding debt.';
                  }
                  
                  final confirmed = await ConfirmationDialog.showDeleteConfirmation(
                    context: context,
                    title: l10n.deleteCustomer,
                    message: confirmMessage,
                    confirmText: 'Delete',
                    cancelText: l10n.cancel,
                  );
                  
                  if (!confirmed || !context.mounted) return;
                  
                  // Delete customer
                  try {
                    await context.read<CustomerProvider>().deleteCustomer(customer.id!);
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 12),
                          Expanded(child: Text('${customer.name} deleted successfully')),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                  Navigator.pop(context, true); // Return to list
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Delete failed: $e')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                }
              }
            },
          );
                },
              ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final customerData = provider.getCustomerWithDebt(widget.customerId);
          if (customerData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.customerNotFound, style: Theme.of(context).textTheme.titleMedium),
              ),
            );
          }

          final customer = customerData.customer;
          final debt = customerData.remainingDebt;
          final transactions = customerData.transactions;
          
          // Calculate balance credit
          final balanceCredit = transactions
              .where((t) => t.type == TransactionType.BALANCE_CREDIT)
              .fold(0.0, (sum, t) => sum + t.amount);

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<CustomerProvider>().loadAllCustomers();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text('${l10n.phone}: ${customer.phone}'),
                          const SizedBox(height: 8),
                          Text('${l10n.createdDate}: ${AppDateFormatter.formatDate(customer.createdAt, Localizations.localeOf(context).languageCode)}'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: debt > 0 ? Colors.red.shade50 : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.balance,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    debt.toStringAsFixed(2),
                                    key: ValueKey<double>(debt),
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: debt > 0 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Show balance credit if exists
                          if (balanceCredit > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet, color: Colors.blue.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.balanceCreditLabel,
                                        style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    balanceCredit.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addCredit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddCreditScreen(
                              customerId: widget.customerId,
                            ),
                          ),
                        );
                        if (result != null) {
                          await context.read<CustomerProvider>().loadAllCustomers();
                          setState(() {});
                        }
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.remove),
                      label: Text(l10n.addPayment),
                      onPressed: debt > 0
                          ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddPaymentScreen(
                                    customerId: widget.customerId,
                                  ),
                                ),
                              );
                              if (result != null) {
                                await context.read<CustomerProvider>().loadAllCustomers();
                                setState(() {});
                              }
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Export buttons row
                Row(
                  children: [
                    Expanded(
                      child: _ExportPdfButton(
                        customer: customer,
                        transactions: customerData.transactions,
                        appTitle: l10n.appTitle,
                        l10n: l10n,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ExportCsvButton(
                        customer: customer,
                        transactions: customerData.transactions,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Transactions history header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.transactions,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (transactions.isNotEmpty)
                      Row(
                        children: [
                          // Filter button
                          IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.filter_alt),
                                if (_filterOptions.hasActiveFilters)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${_filterOptions.activeFilterCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            tooltip: 'Filter transactions',
                            onPressed: () async {
                              final result = await AdvancedFilterDialog.show(
                                context,
                                _filterOptions,
                              );
                              if (result != null) {
                                setState(() => _filterOptions = result);
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                
                // Search bar (only show if there are transactions)
                if (transactions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _transactionSearchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() => _transactionSearchQuery = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() => _transactionSearchQuery = value);
                    },
                  ),
                ],
                const SizedBox(height: 12),
                
                // Filter summary
                if (_filterOptions.hasActiveFilters)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_filterOptions.activeFilterCount} filter(s) active',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _filterOptions.clear());
                          },
                          child: const Text('Clear', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                
                // Filtered transactions list
                Builder(
                  builder: (context) {
                    final filteredTransactions = _filterTransactions(transactions);
                    
                    if (filteredTransactions.isEmpty && transactions.isNotEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No transactions match your search or filters',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    if (filteredTransactions.isEmpty) {
                      return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noTransactions,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                      final isCredit = transaction.type == TransactionType.CREDIT;
                      final isBalanceCredit = transaction.type == TransactionType.BALANCE_CREDIT;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCredit ? Colors.red.shade100 : 
                                             isBalanceCredit ? Colors.blue.shade100 : Colors.green.shade100,
                            child: Text(
                              '${transaction.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            '${transaction.amount.toStringAsFixed(2)} TND',
                            style: TextStyle(
                              color: isCredit ? Colors.red : 
                                     isBalanceCredit ? Colors.blue : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                // Don't allow editing balance credit transactions
                                if (isBalanceCredit) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: const [
                                          Icon(Icons.info_outline, color: Colors.white),
                                          SizedBox(width: 12),
                                          Expanded(child: Text('Balance credit transactions cannot be edited')),
                                        ],
                                      ),
                                      backgroundColor: Colors.orange,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  );
                                  return;
                                }
                                
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditTransactionScreen(transaction: transaction),
                                  ),
                                );
                                if (result != null) {
                                  await context.read<CustomerProvider>().loadAllCustomers();
                                  setState(() {});
                                }
                              } else if (value == 'delete') {
                                final confirmed = await ConfirmationDialog.showDeleteConfirmation(
                                  context: context,
                                  title: 'Delete Transaction',
                                  message: 'Are you sure you want to delete this ${isCredit ? "credit" : isBalanceCredit ? "balance credit" : "payment"} transaction?\n\nAmount: ${transaction.amount.toStringAsFixed(2)} TND\n\nThis will affect the customer\'s balance.',
                                  confirmText: 'Delete',
                                  cancelText: l10n.cancel,
                                );
                                
                                if (!confirmed || !context.mounted) return;
                                
                                try {
                                  await context.read<TransactionProvider>().deleteTransaction(transaction.id);
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: const [
                                            Icon(Icons.check_circle, color: Colors.white),
                                            SizedBox(width: 12),
                                            Expanded(child: Text('Transaction deleted successfully')),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                    await context.read<CustomerProvider>().loadAllCustomers();
                                    setState(() {});
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(Icons.error_outline, color: Colors.white),
                                            const SizedBox(width: 12),
                                            Expanded(child: Text('Delete failed: $e')),
                                          ],
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (context) {
                              final authProvider = context.read<AuthProvider>();
                              final canDelete = authProvider.hasPermission(Permission.deleteTransaction);
                              
                              return [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 12),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                if (canDelete)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 12),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                              ];
                            },
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction date
                              Text(
                                AppDateFormatter.formatDateTime(transaction.createdAt, Localizations.localeOf(context).languageCode),
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                              if (transaction.selectedItems.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: transaction.selectedItems.map((item) {
                                      final parts = item.split(':');
                                      final key = parts[0];
                                      final qty = parts.length > 1 ? parts[1] : '1';
                                      final label = _getLocalizedLabel(context, key);
                                      return Chip(
                                        label: Text('$label x$qty', style: const TextStyle(fontSize: 11)),
                                        backgroundColor: Colors.grey.shade100,
                                      );
                                    }).toList(),
                                  ),
                                ),
                              if (transaction.note != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${transaction.note}',
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
                ],
              ),
            ),
          );
        },
      ),
        );
      },
    );
  }
}

/// PDF export button with loading state and proper success/error feedback.
class _ExportPdfButton extends StatefulWidget {
  final Customer customer;
  final List<Transaction> transactions;
  final String appTitle;
  final AppLocalizations l10n;

  const _ExportPdfButton({
    required this.customer,
    required this.transactions,
    required this.appTitle,
    required this.l10n,
  });

  @override
  State<_ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends State<_ExportPdfButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.download),
      label: Text(_loading ? widget.l10n.exportingPdf : widget.l10n.exportPdf),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
      ),
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                // Use the new PDF service selector for better Arabic support
                await PdfServiceSelector.generateCustomerReport(
                  customer: widget.customer,
                  transactions: widget.transactions,
                  appTitle: widget.appTitle,
                  language: Localizations.localeOf(context).languageCode,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(widget.l10n.success)),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e, st) {
                if (!mounted) return;
                debugPrint('PDF export error: $e');
                debugPrint('$st');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${widget.l10n.error}: ${e.toString()}')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
    );
  }
}


/// CSV export button with loading state
class _ExportCsvButton extends StatefulWidget {
  final Customer customer;
  final List<Transaction> transactions;

  const _ExportCsvButton({
    required this.customer,
    required this.transactions,
  });

  @override
  State<_ExportCsvButton> createState() => _ExportCsvButtonState();
}

class _ExportCsvButtonState extends State<_ExportCsvButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.table_chart),
      label: Text(_loading ? 'Exporting...' : 'Export CSV'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      onPressed: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              try {
                await CsvExportService.exportCustomerTransactions(
                  customer: widget.customer,
                  transactions: widget.transactions,
                  language: Localizations.localeOf(context).languageCode,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('CSV exported successfully')),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              } catch (e, st) {
                if (!mounted) return;
                debugPrint('CSV export error: $e');
                debugPrint('$st');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Export failed: ${e.toString()}')),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
    );
  }
}
