import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../domain/models/transaction.dart';
import '../../generated/app_localizations.dart';
import '../../services/csv_export_service.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/connection_status_widget.dart';
import 'add_customer_screen.dart';
import 'customer_detail_screen.dart';
import 'settings_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  String _searchQuery = '';
  String _sortBy = 'name'; // name, debt_high, debt_low, date_new, date_old
  bool _showOnlyWithDebt = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CustomerProvider>().loadAllCustomers();
    });
  }

  List<CustomerWithDebt> _sortAndFilterCustomers(List<CustomerWithDebt> customers) {
    var filtered = List<CustomerWithDebt>.from(customers);
    
    // Filter by debt status
    if (_showOnlyWithDebt) {
      filtered = filtered.where((c) => c.remainingDebt > 0).toList();
    }
    
    // Sort
    switch (_sortBy) {
      case 'debt_high':
        filtered.sort((a, b) => b.remainingDebt.compareTo(a.remainingDebt));
        break;
      case 'debt_low':
        filtered.sort((a, b) => a.remainingDebt.compareTo(b.remainingDebt));
        break;
      case 'date_new':
        filtered.sort((a, b) => b.customer.createdAt.compareTo(a.customer.createdAt));
        break;
      case 'date_old':
        filtered.sort((a, b) => a.customer.createdAt.compareTo(b.customer.createdAt));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a.customer.name.toLowerCase().compareTo(b.customer.name.toLowerCase()));
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customers),
        elevation: 2,
        actions: [
          // Connection status indicator
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: ConnectionStatusIndicator(),
          ),
          // CSV Export button
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to CSV',
            onPressed: () async {
              final provider = context.read<CustomerProvider>();
              if (provider.customersWithDebt.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('No customers to export')),
                      ],
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
                return;
              }
              
              try {
                // Prepare data with balance credit
                final dataToExport = provider.customersWithDebt.map((data) {
                  final balanceCredit = data.transactions
                      .where((t) => t.type == TransactionType.BALANCE_CREDIT)
                      .fold(0.0, (sum, t) => sum + t.amount);
                  
                  return {
                    'customer': data.customer,
                    'remainingDebt': data.remainingDebt,
                    'balanceCredit': balanceCredit,
                  };
                }).toList();
                
                await CsvExportService.exportCustomers(
                  customersWithDebt: dataToExport,
                  language: Localizations.localeOf(context).languageCode,
                );
                
                if (context.mounted) {
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
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Export failed: $e')),
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
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
              provider.clearError();
            }
          });

          // Search bar and filters
          return Column(
            children: [
              // Connection status banner (shows when offline)
              const ConnectionStatusWidget(),
              
              // Statistics summary card
              if (!provider.isLoading && provider.customersWithDebt.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _StatisticsSummary(customersWithDebt: provider.customersWithDebt),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Sort and filter row
                    Row(
                      children: [
                        // Sort dropdown
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                isExpanded: true,
                                icon: const Icon(Icons.sort, size: 20),
                                items: [
                                  DropdownMenuItem(value: 'name', child: Row(
                                    children: const [
                                      Icon(Icons.sort_by_alpha, size: 18),
                                      SizedBox(width: 8),
                                      Text('Name'),
                                    ],
                                  )),
                                  DropdownMenuItem(value: 'debt_high', child: Row(
                                    children: const [
                                      Icon(Icons.arrow_downward, size: 18),
                                      SizedBox(width: 8),
                                      Text('Debt: High to Low'),
                                    ],
                                  )),
                                  DropdownMenuItem(value: 'debt_low', child: Row(
                                    children: const [
                                      Icon(Icons.arrow_upward, size: 18),
                                      SizedBox(width: 8),
                                      Text('Debt: Low to High'),
                                    ],
                                  )),
                                  DropdownMenuItem(value: 'date_new', child: Row(
                                    children: const [
                                      Icon(Icons.new_releases, size: 18),
                                      SizedBox(width: 8),
                                      Text('Newest First'),
                                    ],
                                  )),
                                  DropdownMenuItem(value: 'date_old', child: Row(
                                    children: const [
                                      Icon(Icons.history, size: 18),
                                      SizedBox(width: 8),
                                      Text('Oldest First'),
                                    ],
                                  )),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sortBy = value);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Filter chip
                        FilterChip(
                          label: const Text('With Debt'),
                          selected: _showOnlyWithDebt,
                          onSelected: (selected) {
                            setState(() => _showOnlyWithDebt = selected);
                          },
                          avatar: Icon(
                            _showOnlyWithDebt ? Icons.check_circle : Icons.filter_alt,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Customer list
              Expanded(
                child: provider.isLoading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) => const CustomerListSkeleton(),
                      )
                    : Builder(
                        builder: (context) {
                          var customers = _searchQuery.isEmpty
                              ? provider.customersWithDebt
                              : provider.searchCustomers(_searchQuery);
                          
                          // Apply sort and filter
                          customers = _sortAndFilterCustomers(customers);

                          if (customers.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                                      size: 80,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchQuery.isEmpty ? l10n.noCustomers : l10n.search,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_searchQuery.isEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.addCustomer,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async => await provider.loadAllCustomers(),
                            child: ListView.builder(
                              itemCount: customers.length,
                              itemBuilder: (context, index) {
                                final customerData = customers[index];
                                final customer = customerData.customer;
                                final debt = customerData.remainingDebt;
                                
                                // Calculate balance credit
                                final balanceCredit = customerData.transactions
                                    .where((t) => t.type == TransactionType.BALANCE_CREDIT)
                                    .fold(0.0, (sum, t) => sum + t.amount);

                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: debt > 0 ? Colors.red.shade100 : Colors.green.shade100,
                                      child: Text(
                                        debt > 0 ? '-' : '+',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(customer.name),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l10n.debt(debt.toStringAsFixed(2))),
                                        if (balanceCredit > 0)
                                          Row(
                                            children: [
                                              Icon(Icons.account_balance_wallet, size: 14, color: Colors.blue.shade700),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${l10n.balanceLabel}: ${balanceCredit.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        debt > 0
                                            ? Chip(
                                                label: Text(debt.toStringAsFixed(2)),
                                                backgroundColor: Colors.red.shade100,
                                              )
                                            : Chip(
                                                label: Text(l10n.paid),
                                                backgroundColor: Colors.green.shade100,
                                              ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CustomerDetailScreen(
                                            customerId: customer.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // After adding a customer, reload the list
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );
          if (result != null) {
            // Reload customers if a new one was added (result may be the new id)
            context.read<CustomerProvider>().loadAllCustomers();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Statistics summary widget showing total customers, debt, and balance credit
class _StatisticsSummary extends StatelessWidget {
  final List<CustomerWithDebt> customersWithDebt;

  const _StatisticsSummary({required this.customersWithDebt});

  @override
  Widget build(BuildContext context) {
    final totalCustomers = customersWithDebt.length;
    final customersWithDebtCount = customersWithDebt.where((c) => c.remainingDebt > 0).length;
    final totalDebt = customersWithDebt.fold<double>(0, (sum, c) => sum + c.remainingDebt);
    final totalBalanceCredit = customersWithDebt.fold<double>(0, (sum, c) {
      return sum + c.transactions
          .where((t) => t.type == TransactionType.BALANCE_CREDIT)
          .fold<double>(0, (s, t) => s + t.amount);
    });

    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.people,
              label: 'Customers',
              value: totalCustomers.toString(),
            ),
            Container(width: 1, height: 40, color: Colors.white30),
            _StatItem(
              icon: Icons.warning_amber,
              label: 'With Debt',
              value: customersWithDebtCount.toString(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white30, thickness: 1),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: Icons.trending_up,
              label: 'Total Debt',
              value: '${totalDebt.toStringAsFixed(2)} TND',
              valueColor: Colors.red.shade100,
            ),
            if (totalBalanceCredit > 0) ...[
              Container(width: 1, height: 40, color: Colors.white30),
              _StatItem(
                icon: Icons.account_balance_wallet,
                label: 'Balance Credit',
                value: '${totalBalanceCredit.toStringAsFixed(2)} TND',
                valueColor: Colors.green.shade100,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Individual statistic item
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
