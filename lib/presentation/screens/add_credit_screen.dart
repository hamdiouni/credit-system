import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/grocery_item.dart';
import '../../generated/app_localizations.dart';
import '../../utils/validators.dart';

class AddCreditScreen extends StatefulWidget {
  final dynamic customerId;

  const AddCreditScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  State<AddCreditScreen> createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _commentController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _commentFocusNode = FocusNode();
  final _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  Map<String, int> _selectedItemsWithQty = {}; // key -> quantity
  bool _isLoading = false;

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

  void _saveCredit() async {
    final l10n = AppLocalizations.of(context);

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final amount = double.parse(_amountController.text);
      // Format selected items with quantities (key:quantity)
      final itemsList = _selectedItemsWithQty.entries
          .map((e) => '${e.key}:${e.value}')
          .toList();
      final transaction = Transaction(
        id: 0,
        customerId: widget.customerId,
        amount: amount,
        type: TransactionType.CREDIT,
        note: _commentController.text.isNotEmpty ? _commentController.text : null,
        selectedItems: itemsList,
        createdAt: _selectedDate,
      );

      setState(() => _isLoading = true);

      await context.read<TransactionProvider>().addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.creditAdded)),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getLocalizedLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // Use hardcoded translations since generator has issues
    final translations = {
      'en': {
        'pasta': 'Pasta', 'couscous': 'Couscous', 'oats': 'Oats',
        'yogurt': 'Yogurt', 'cream': 'Cream', 'juice': 'Juice',
        'soda': 'Soda', 'water': 'Water', 'carrot': 'Carrot',
        'cucumber': 'Cucumber', 'pepper': 'Pepper', 'lettuce': 'Lettuce',
        'garlic': 'Garlic', 'apple': 'Apple', 'banana': 'Banana',
        'orange': 'Orange', 'lemon': 'Lemon', 'grapes': 'Grapes',
        'watermelon': 'Watermelon', 'chicken': 'Chicken', 'beef': 'Beef',
        'lamb': 'Lamb', 'fish': 'Fish', 'sausage': 'Sausage',
        'baguette': 'Baguette', 'croissant': 'Croissant', 'cake': 'Cake',
        'chips': 'Chips', 'candy': 'Candy', 'nuts': 'Nuts',
        'shampoo': 'Shampoo', 'tissue': 'Tissue', 'toothpaste': 'Toothpaste',
        'pepper_spice': 'Black Pepper', 'cumin': 'Cumin', 'paprika': 'Paprika',
        'vinegar': 'Vinegar', 'ketchup': 'Ketchup', 'mayonnaise': 'Mayonnaise',
        'tuna': 'Tuna', 'beans': 'Beans', 'tomato_sauce': 'Tomato Sauce',
        'olives': 'Olives', 'ice_cream': 'Ice Cream', 'frozen_veg': 'Frozen Vegetables',
        'pizza': 'Pizza',
      },
      'ar': {
        'pasta': 'معكرونة', 'couscous': 'كسكس', 'oats': 'شوفان',
        'yogurt': 'زبادي', 'cream': 'كريمة', 'juice': 'عصير',
        'soda': 'مشروب غازي', 'water': 'ماء', 'carrot': 'جزر',
        'cucumber': 'خيار', 'pepper': 'فلفل', 'lettuce': 'خس',
        'garlic': 'ثوم', 'apple': 'تفاح', 'banana': 'موز',
        'orange': 'برتقال', 'lemon': 'ليمون', 'grapes': 'عنب',
        'watermelon': 'بطيخ', 'chicken': 'دجاج', 'beef': 'لحم بقر',
        'lamb': 'لحم خروف', 'fish': 'سمك', 'sausage': 'نقانق',
        'baguette': 'باغيت', 'croissant': 'كرواسون', 'cake': 'كعكة',
        'chips': 'رقائق', 'candy': 'حلوى', 'nuts': 'مكسرات',
        'shampoo': 'شامبو', 'tissue': 'مناديل', 'toothpaste': 'معجون أسنان',
        'pepper_spice': 'فلفل أسود', 'cumin': 'كمون', 'paprika': 'بابريكا',
        'vinegar': 'خل', 'ketchup': 'كاتشب', 'mayonnaise': 'مايونيز',
        'tuna': 'تونة', 'beans': 'فاصوليا', 'tomato_sauce': 'صلصة طماطم',
        'olives': 'زيتون', 'ice_cream': 'آيس كريم', 'frozen_veg': 'خضروات مجمدة',
        'pizza': 'بيتزا',
      },
      'fr': {
        'pasta': 'Pâtes', 'couscous': 'Couscous', 'oats': 'Avoine',
        'yogurt': 'Yaourt', 'cream': 'Crème', 'juice': 'Jus',
        'soda': 'Soda', 'water': 'Eau', 'carrot': 'Carotte',
        'cucumber': 'Concombre', 'pepper': 'Poivron', 'lettuce': 'Laitue',
        'garlic': 'Ail', 'apple': 'Pomme', 'banana': 'Banane',
        'orange': 'Orange', 'lemon': 'Citron', 'grapes': 'Raisins',
        'watermelon': 'Pastèque', 'chicken': 'Poulet', 'beef': 'Bœuf',
        'lamb': 'Agneau', 'fish': 'Poisson', 'sausage': 'Saucisse',
        'baguette': 'Baguette', 'croissant': 'Croissant', 'cake': 'Gâteau',
        'chips': 'Chips', 'candy': 'Bonbons', 'nuts': 'Noix',
        'shampoo': 'Shampooing', 'tissue': 'Mouchoirs', 'toothpaste': 'Dentifrice',
        'pepper_spice': 'Poivre Noir', 'cumin': 'Cumin', 'paprika': 'Paprika',
        'vinegar': 'Vinaigre', 'ketchup': 'Ketchup', 'mayonnaise': 'Mayonnaise',
        'tuna': 'Thon', 'beans': 'Haricots', 'tomato_sauce': 'Sauce Tomate',
        'olives': 'Olives', 'ice_cream': 'Glace', 'frozen_veg': 'Légumes Surgelés',
        'pizza': 'Pizza',
      },
    };

    // Try hardcoded translation first
    if (translations[locale]?.containsKey(key) == true) {
      return translations[locale]![key]!;
    }

    // Fall back to existing l10n methods
    switch (key) {
      case 'rice': return l10n.rice;
      case 'flour': return l10n.flour;
      case 'milk': return l10n.milk;
      case 'butter': return l10n.butter;
      case 'cheese': return l10n.cheese;
      case 'eggs': return l10n.eggs;
      case 'tea': return l10n.tea;
      case 'coffee': return l10n.coffee;
      case 'tomato': return l10n.tomato;
      case 'onion': return l10n.onion;
      case 'potato': return l10n.potato;
      case 'bread': return l10n.bread;
      case 'chocolate': return l10n.chocolate;
      case 'biscuits': return l10n.biscuits;
      case 'detergent': return l10n.detergent;
      case 'soap': return l10n.soap;
      case 'salt': return l10n.salt;
      case 'sugar': return l10n.sugar;
      case 'oil': return l10n.oil;
      default: return key;
    }
  }

  String _getCategoryLabel(BuildContext context, String category) {
    final locale = Localizations.localeOf(context).languageCode;
    
    final categories = {
      'en': {
        'grains': '🌾 Grains & Staples',
        'dairy': '🥛 Dairy Products',
        'beverages': '☕ Beverages',
        'vegetables': '🥬 Vegetables',
        'fruits': '🍎 Fruits',
        'meat': '🍖 Meat & Poultry',
        'bakery': '🥖 Bakery',
        'snacks': '🍫 Snacks & Sweets',
        'household': '🧼 Household Items',
        'spices': '🧂 Spices & Condiments',
        'canned': '🥫 Canned & Packaged',
        'frozen': '🧊 Frozen Foods',
      },
      'ar': {
        'grains': '🌾 الحبوب والأساسيات',
        'dairy': '🥛 منتجات الألبان',
        'beverages': '☕ المشروبات',
        'vegetables': '🥬 الخضروات',
        'fruits': '🍎 الفواكه',
        'meat': '🍖 اللحوم والدواجن',
        'bakery': '🥖 المخبوزات',
        'snacks': '🍫 الوجبات الخفيفة والحلويات',
        'household': '🧼 المنتجات المنزلية',
        'spices': '🧂 التوابل والبهارات',
        'canned': '🥫 المعلبات والمعبأة',
        'frozen': '🧊 المجمدات',
      },
      'fr': {
        'grains': '🌾 Céréales et Produits de Base',
        'dairy': '🥛 Produits Laitiers',
        'beverages': '☕ Boissons',
        'vegetables': '🥬 Légumes',
        'fruits': '🍎 Fruits',
        'meat': '🍖 Viandes et Volailles',
        'bakery': '🥖 Boulangerie',
        'snacks': '🍫 Collations et Sucreries',
        'household': '🧼 Produits Ménagers',
        'spices': '🧂 Épices et Condiments',
        'canned': '🥫 Conserves et Emballés',
        'frozen': '🧊 Produits Surgelés',
      },
    };

    return categories[locale]?[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCredit),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
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
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixText: 'TND',
                  helperText: 'Enter credit amount',
                ),
                validator: Validators.validateAmount,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (_) => _scrollToBottom(),
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

            // Grocery Items Checklist (Grouped by Category)
            Text(
              l10n.selectItems,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...GroceryItems.getAllCategories().map((category) {
              final categoryItems = GroceryItems.getByCategory(category);
              return ExpansionTile(
                title: Text(
                  _getCategoryLabel(context, category),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                initiallyExpanded: false,
                children: categoryItems.map((item) {
                  final label = _getLocalizedLabel(context, item.key);
                  final isChecked = _selectedItemsWithQty.containsKey(item.key);
                  final qty = _selectedItemsWithQty[item.key] ?? 1;

                  return CheckboxListTile(
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
                                  onChanged: (val) {
                                    setState(() {
                                      final q = int.tryParse(val) ?? 1;
                                      _selectedItemsWithQty[item.key] = q > 0 ? q : 1;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: qty.toString(),
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.all(4),
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
                  );
                }).toList(),
              );
            }).toList(),

            const SizedBox(height: 8),
            if (_selectedItemsWithQty.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.selectItems} (${_selectedItemsWithQty.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._selectedItemsWithQty.entries.map((e) {
                      return Text(
                        '• ${_getLocalizedLabel(context, e.key)}: x${e.value}',
                        style: const TextStyle(fontSize: 12),
                      );
                    }).toList(),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Optional Comment
            TextFormField(
              controller: _commentController,
              focusNode: _commentFocusNode,
              enabled: !_isLoading,
              maxLines: 3,
              maxLength: 500,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: l10n.optionalComment,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.note),
                helperText: 'Optional - Add a note',
              ),
              validator: Validators.validateNote,
              onTap: () => _scrollToBottom(),
              onChanged: (_) => _scrollToBottom(),
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
                  onPressed: _isLoading ? null : _saveCredit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
