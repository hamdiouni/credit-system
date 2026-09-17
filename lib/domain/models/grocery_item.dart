class GroceryItem {
  final String key; // For localization
  final String label; // Fallback/display name
  final String category;

  const GroceryItem({
    required this.key,
    required this.label,
    required this.category,
  });
}

class GroceryCategory {
  static const String grains = 'grains';
  static const String dairy = 'dairy';
  static const String beverages = 'beverages';
  static const String vegetables = 'vegetables';
  static const String fruits = 'fruits';
  static const String meat = 'meat';
  static const String bakery = 'bakery';
  static const String snacks = 'snacks';
  static const String household = 'household';
  static const String spices = 'spices';
  static const String canned = 'canned';
  static const String frozen = 'frozen';
}

class GroceryItems {
  static const List<GroceryItem> defaultItems = [
    // Grains & Staples
    GroceryItem(key: 'rice', label: 'Rice', category: GroceryCategory.grains),
    GroceryItem(key: 'flour', label: 'Flour', category: GroceryCategory.grains),
    GroceryItem(key: 'pasta', label: 'Pasta', category: GroceryCategory.grains),
    GroceryItem(key: 'couscous', label: 'Couscous', category: GroceryCategory.grains),
    GroceryItem(key: 'oats', label: 'Oats', category: GroceryCategory.grains),
    
    // Dairy Products
    GroceryItem(key: 'milk', label: 'Milk', category: GroceryCategory.dairy),
    GroceryItem(key: 'butter', label: 'Butter', category: GroceryCategory.dairy),
    GroceryItem(key: 'cheese', label: 'Cheese', category: GroceryCategory.dairy),
    GroceryItem(key: 'yogurt', label: 'Yogurt', category: GroceryCategory.dairy),
    GroceryItem(key: 'eggs', label: 'Eggs', category: GroceryCategory.dairy),
    GroceryItem(key: 'cream', label: 'Cream', category: GroceryCategory.dairy),
    
    // Beverages
    GroceryItem(key: 'tea', label: 'Tea', category: GroceryCategory.beverages),
    GroceryItem(key: 'coffee', label: 'Coffee', category: GroceryCategory.beverages),
    GroceryItem(key: 'juice', label: 'Juice', category: GroceryCategory.beverages),
    GroceryItem(key: 'soda', label: 'Soda', category: GroceryCategory.beverages),
    GroceryItem(key: 'water', label: 'Water', category: GroceryCategory.beverages),
    
    // Vegetables
    GroceryItem(key: 'tomato', label: 'Tomato', category: GroceryCategory.vegetables),
    GroceryItem(key: 'onion', label: 'Onion', category: GroceryCategory.vegetables),
    GroceryItem(key: 'potato', label: 'Potato', category: GroceryCategory.vegetables),
    GroceryItem(key: 'carrot', label: 'Carrot', category: GroceryCategory.vegetables),
    GroceryItem(key: 'cucumber', label: 'Cucumber', category: GroceryCategory.vegetables),
    GroceryItem(key: 'pepper', label: 'Pepper', category: GroceryCategory.vegetables),
    GroceryItem(key: 'lettuce', label: 'Lettuce', category: GroceryCategory.vegetables),
    GroceryItem(key: 'garlic', label: 'Garlic', category: GroceryCategory.vegetables),
    
    // Fruits
    GroceryItem(key: 'apple', label: 'Apple', category: GroceryCategory.fruits),
    GroceryItem(key: 'banana', label: 'Banana', category: GroceryCategory.fruits),
    GroceryItem(key: 'orange', label: 'Orange', category: GroceryCategory.fruits),
    GroceryItem(key: 'lemon', label: 'Lemon', category: GroceryCategory.fruits),
    GroceryItem(key: 'grapes', label: 'Grapes', category: GroceryCategory.fruits),
    GroceryItem(key: 'watermelon', label: 'Watermelon', category: GroceryCategory.fruits),
    
    // Meat & Poultry
    GroceryItem(key: 'chicken', label: 'Chicken', category: GroceryCategory.meat),
    GroceryItem(key: 'beef', label: 'Beef', category: GroceryCategory.meat),
    GroceryItem(key: 'lamb', label: 'Lamb', category: GroceryCategory.meat),
    GroceryItem(key: 'fish', label: 'Fish', category: GroceryCategory.meat),
    GroceryItem(key: 'sausage', label: 'Sausage', category: GroceryCategory.meat),
    
    // Bakery
    GroceryItem(key: 'bread', label: 'Bread', category: GroceryCategory.bakery),
    GroceryItem(key: 'baguette', label: 'Baguette', category: GroceryCategory.bakery),
    GroceryItem(key: 'croissant', label: 'Croissant', category: GroceryCategory.bakery),
    GroceryItem(key: 'cake', label: 'Cake', category: GroceryCategory.bakery),
    
    // Snacks & Sweets
    GroceryItem(key: 'chocolate', label: 'Chocolate', category: GroceryCategory.snacks),
    GroceryItem(key: 'biscuits', label: 'Biscuits', category: GroceryCategory.snacks),
    GroceryItem(key: 'chips', label: 'Chips', category: GroceryCategory.snacks),
    GroceryItem(key: 'candy', label: 'Candy', category: GroceryCategory.snacks),
    GroceryItem(key: 'nuts', label: 'Nuts', category: GroceryCategory.snacks),
    
    // Household Items
    GroceryItem(key: 'detergent', label: 'Detergent', category: GroceryCategory.household),
    GroceryItem(key: 'soap', label: 'Soap', category: GroceryCategory.household),
    GroceryItem(key: 'shampoo', label: 'Shampoo', category: GroceryCategory.household),
    GroceryItem(key: 'tissue', label: 'Tissue', category: GroceryCategory.household),
    GroceryItem(key: 'toothpaste', label: 'Toothpaste', category: GroceryCategory.household),
    
    // Spices & Condiments
    GroceryItem(key: 'salt', label: 'Salt', category: GroceryCategory.spices),
    GroceryItem(key: 'sugar', label: 'Sugar', category: GroceryCategory.spices),
    GroceryItem(key: 'pepper_spice', label: 'Black Pepper', category: GroceryCategory.spices),
    GroceryItem(key: 'cumin', label: 'Cumin', category: GroceryCategory.spices),
    GroceryItem(key: 'paprika', label: 'Paprika', category: GroceryCategory.spices),
    GroceryItem(key: 'vinegar', label: 'Vinegar', category: GroceryCategory.spices),
    GroceryItem(key: 'ketchup', label: 'Ketchup', category: GroceryCategory.spices),
    GroceryItem(key: 'mayonnaise', label: 'Mayonnaise', category: GroceryCategory.spices),
    
    // Canned & Packaged
    GroceryItem(key: 'oil', label: 'Oil', category: GroceryCategory.canned),
    GroceryItem(key: 'tuna', label: 'Tuna', category: GroceryCategory.canned),
    GroceryItem(key: 'beans', label: 'Beans', category: GroceryCategory.canned),
    GroceryItem(key: 'tomato_sauce', label: 'Tomato Sauce', category: GroceryCategory.canned),
    GroceryItem(key: 'olives', label: 'Olives', category: GroceryCategory.canned),
    
    // Frozen Foods
    GroceryItem(key: 'ice_cream', label: 'Ice Cream', category: GroceryCategory.frozen),
    GroceryItem(key: 'frozen_veg', label: 'Frozen Vegetables', category: GroceryCategory.frozen),
    GroceryItem(key: 'pizza', label: 'Pizza', category: GroceryCategory.frozen),
  ];
  
  // Get items by category
  static List<GroceryItem> getByCategory(String category) {
    return defaultItems.where((item) => item.category == category).toList();
  }
  
  // Get all categories
  static List<String> getAllCategories() {
    return [
      GroceryCategory.grains,
      GroceryCategory.dairy,
      GroceryCategory.beverages,
      GroceryCategory.vegetables,
      GroceryCategory.fruits,
      GroceryCategory.meat,
      GroceryCategory.bakery,
      GroceryCategory.snacks,
      GroceryCategory.household,
      GroceryCategory.spices,
      GroceryCategory.canned,
      GroceryCategory.frozen,
    ];
  }
}
