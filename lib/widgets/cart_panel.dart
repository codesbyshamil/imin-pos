import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartPanel extends StatelessWidget {
  final VoidCallback onCheckout;
  final VoidCallback onPrintTest;

  const CartPanel({
    super.key,
    required this.onCheckout,
    required this.onPrintTest,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Column(
      children: [
        // Cart header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color(0xFF1A73E8)),
              const SizedBox(width: 8),
              const Text(
                'Current Order',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (cart.items.isNotEmpty)
                TextButton.icon(
                  onPressed: cart.clearCart,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cart items list
        Expanded(
          child: cart.items.isEmpty
              ? _EmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return _CartItemTile(item: item);
                  },
                ),
        ),

        const Divider(height: 1),

        // Totals
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _TotalRow(
                  label: 'Subtotal',
                  value: '\$${cart.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 4),
              _TotalRow(
                label:
                    'Tax (${(cart.taxRate * 100).toStringAsFixed(0)}%)',
                value: '\$${cart.taxAmount.toStringAsFixed(2)}',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(
                    '\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF1A73E8)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Checkout button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: cart.items.isEmpty ? null : onCheckout,
                  icon: const Icon(Icons.print),
                  label: const Text('Checkout & Print',
                      style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Print test button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: onPrintTest,
                  icon: const Icon(Icons.bug_report, size: 18),
                  label: const Text('Print Test Page'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No items yet',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Tap products to add them',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      leading: Text(item.product.emoji, style: const TextStyle(fontSize: 22)),
      title: Text(item.product.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      subtitle: Text(
        '\$${item.product.price.toStringAsFixed(2)} each',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: () => cart.removeProduct(item.product.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('${item.quantity}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: () => cart.addProduct(item.product),
          ),
          const SizedBox(width: 4),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A73E8),
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
