import 'package:flutter/material.dart';
import '../domain/models/transaction.dart';

class FilterOptions {
  DateTime? startDate;
  DateTime? endDate;
  double? minAmount;
  double? maxAmount;
  List<TransactionType>? transactionTypes;
  bool? hasNote;

  FilterOptions({
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.transactionTypes,
    this.hasNote,
  });

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      (transactionTypes != null && transactionTypes!.isNotEmpty) ||
      hasNote != null;

  int get activeFilterCount {
    int count = 0;
    if (startDate != null) count++;
    if (endDate != null) count++;
    if (minAmount != null) count++;
    if (maxAmount != null) count++;
    if (transactionTypes != null && transactionTypes!.isNotEmpty) count++;
    if (hasNote != null) count++;
    return count;
  }

  void clear() {
    startDate = null;
    endDate = null;
    minAmount = null;
    maxAmount = null;
    transactionTypes = null;
    hasNote = null;
  }
}

class AdvancedFilterDialog extends StatefulWidget {
  final FilterOptions initialFilters;

  const AdvancedFilterDialog({
    Key? key,
    required this.initialFilters,
  }) : super(key: key);

  @override
  State<AdvancedFilterDialog> createState() => _AdvancedFilterDialogState();

  static Future<FilterOptions?> show(BuildContext context, FilterOptions currentFilters) {
    return showDialog<FilterOptions>(
      context: context,
      builder: (context) => AdvancedFilterDialog(initialFilters: currentFilters),
    );
  }
}

class _AdvancedFilterDialogState extends State<AdvancedFilterDialog> {
  late FilterOptions _filters;
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = FilterOptions(
      startDate: widget.initialFilters.startDate,
      endDate: widget.initialFilters.endDate,
      minAmount: widget.initialFilters.minAmount,
      maxAmount: widget.initialFilters.maxAmount,
      transactionTypes: widget.initialFilters.transactionTypes != null
          ? List.from(widget.initialFilters.transactionTypes!)
          : null,
      hasNote: widget.initialFilters.hasNote,
    );

    if (_filters.minAmount != null) {
      _minAmountController.text = _filters.minAmount.toString();
    }
    if (_filters.maxAmount != null) {
      _maxAmountController.text = _filters.maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filters.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _filters.startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filters.endDate ?? DateTime.now(),
      firstDate: _filters.startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _filters.endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.filter_alt, color: Colors.blue),
          const SizedBox(width: 12),
          const Expanded(child: Text('Advanced Filters')),
          if (_filters.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filters.activeFilterCount}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Section
            const Text(
              'DATE RANGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _filters.startDate != null
                          ? '${_filters.startDate!.day}/${_filters.startDate!.month}/${_filters.startDate!.year}'
                          : 'Start Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: _selectStartDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      _filters.endDate != null
                          ? '${_filters.endDate!.day}/${_filters.endDate!.month}/${_filters.endDate!.year}'
                          : 'End Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: _selectEndDate,
                  ),
                ),
              ],
            ),
            if (_filters.startDate != null || _filters.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear dates', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _filters.startDate = null;
                      _filters.endDate = null;
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Amount Range Section
            const Text(
              'AMOUNT RANGE (TND)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.arrow_upward, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      _filters.minAmount = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.arrow_downward, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (value) {
                      _filters.maxAmount = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            if (_filters.minAmount != null || _filters.maxAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear amounts', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    setState(() {
                      _filters.minAmount = null;
                      _filters.maxAmount = null;
                      _minAmountController.clear();
                      _maxAmountController.clear();
                    });
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Transaction Type Section
            const Text(
              'TRANSACTION TYPE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('Credit'),
                  selected: _filters.transactionTypes?.contains(TransactionType.CREDIT) ?? false,
                  onSelected: (selected) {
                    setState(() {
                      _filters.transactionTypes ??= [];
                      if (selected) {
                        _filters.transactionTypes!.add(TransactionType.CREDIT);
                      } else {
                        _filters.transactionTypes!.remove(TransactionType.CREDIT);
                      }
                      if (_filters.transactionTypes!.isEmpty) {
                        _filters.transactionTypes = null;
                      }
                    });
                  },
                  avatar: const Icon(Icons.add_circle, size: 18),
                ),
                FilterChip(
                  label: const Text('Payment'),
                  selected: _filters.transactionTypes?.contains(TransactionType.PAYMENT) ?? false,
                  onSelected: (selected) {
                    setState(() {
                      _filters.transactionTypes ??= [];
                      if (selected) {
                        _filters.transactionTypes!.add(TransactionType.PAYMENT);
                      } else {
                        _filters.transactionTypes!.remove(TransactionType.PAYMENT);
                      }
                      if (_filters.transactionTypes!.isEmpty) {
                        _filters.transactionTypes = null;
                      }
                    });
                  },
                  avatar: const Icon(Icons.remove_circle, size: 18),
                ),
                FilterChip(
                  label: const Text('Balance Credit'),
                  selected: _filters.transactionTypes?.contains(TransactionType.BALANCE_CREDIT) ?? false,
                  onSelected: (selected) {
                    setState(() {
                      _filters.transactionTypes ??= [];
                      if (selected) {
                        _filters.transactionTypes!.add(TransactionType.BALANCE_CREDIT);
                      } else {
                        _filters.transactionTypes!.remove(TransactionType.BALANCE_CREDIT);
                      }
                      if (_filters.transactionTypes!.isEmpty) {
                        _filters.transactionTypes = null;
                      }
                    });
                  },
                  avatar: const Icon(Icons.account_balance_wallet, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Other Filters Section
            const Text(
              'OTHER FILTERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Has Note', style: TextStyle(fontSize: 14)),
              subtitle: const Text('Show only transactions with notes', style: TextStyle(fontSize: 12)),
              value: _filters.hasNote ?? false,
              onChanged: (value) {
                setState(() => _filters.hasNote = value == true ? true : null);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() => _filters.clear());
            _minAmountController.clear();
            _maxAmountController.clear();
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _filters),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Apply', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
