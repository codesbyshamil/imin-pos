class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String emoji;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.emoji,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

// Sample product catalog
final List<Product> sampleProducts = [
  // Food
  const Product(id: 'f1', name: 'Burger', price: 8.99, category: 'Food', emoji: '🍔'),
  const Product(id: 'f2', name: 'Pizza Slice', price: 4.50, category: 'Food', emoji: '🍕'),
  const Product(id: 'f3', name: 'Hot Dog', price: 3.25, category: 'Food', emoji: '🌭'),
  const Product(id: 'f4', name: 'Sandwich', price: 6.75, category: 'Food', emoji: '🥪'),
  const Product(id: 'f5', name: 'Salad', price: 7.50, category: 'Food', emoji: '🥗'),
  const Product(id: 'f6', name: 'Fries', price: 2.99, category: 'Food', emoji: '🍟'),
  // Drinks
  const Product(id: 'd1', name: 'Coffee', price: 3.50, category: 'Drinks', emoji: '☕'),
  const Product(id: 'd2', name: 'Juice', price: 2.75, category: 'Drinks', emoji: '🧃'),
  const Product(id: 'd3', name: 'Water', price: 1.50, category: 'Drinks', emoji: '💧'),
  const Product(id: 'd4', name: 'Soda', price: 2.25, category: 'Drinks', emoji: '🥤'),
  const Product(id: 'd5', name: 'Latte', price: 4.75, category: 'Drinks', emoji: '🥛'),
  const Product(id: 'd6', name: 'Tea', price: 2.50, category: 'Drinks', emoji: '🍵'),
  // Snacks
  const Product(id: 's1', name: 'Chips', price: 1.99, category: 'Snacks', emoji: '🥨'),
  const Product(id: 's2', name: 'Cookie', price: 1.50, category: 'Snacks', emoji: '🍪'),
  const Product(id: 's3', name: 'Muffin', price: 2.75, category: 'Snacks', emoji: '🧁'),
  const Product(id: 's4', name: 'Donut', price: 2.25, category: 'Snacks', emoji: '🍩'),
  const Product(id: 's5', name: 'Brownie', price: 2.50, category: 'Snacks', emoji: '🍫'),
  const Product(id: 's6', name: 'Pretzel', price: 1.75, category: 'Snacks', emoji: '🥨'),
];
