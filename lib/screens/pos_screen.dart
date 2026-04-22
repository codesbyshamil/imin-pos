import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/printer_provider.dart';
import '../models/product.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/printer_status_bar.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Food', 'Drinks', 'Snacks'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().initPrinter();
    });
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return sampleProducts;
    return sampleProducts
        .where((p) => p.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.point_of_sale, size: 24),
            SizedBox(width: 8),
            Text('iMin POS — D1 Pro',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Consumer<PrinterProvider>(
            builder: (ctx, printer, _) => PrinterStatusChip(printer: printer),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Printer Settings',
            onPressed: () => _showPrinterDialog(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _CategoryTabs(
            categories: _categories,
            selected: _selectedCategory,
            onSelect: (c) => setState(() => _selectedCategory = c),
          ),
        ),
      ),
      body: Row(
        children: [
          // Product Grid (left/center)
          Expanded(
            flex: 3,
            child: ProductGrid(products: _filteredProducts),
          ),
          // Divider
          const VerticalDivider(width: 1, thickness: 1),
          // Cart Panel (right)
          SizedBox(
            width: 320,
            child: CartPanel(
              onCheckout: () => _handleCheckout(context),
              onPrintTest: () =>
                  context.read<PrinterProvider>().printTestPage(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final printer = context.read<PrinterProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty!')),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => _CheckoutDialog(total: cart.total),
    );

    if (result == null) return;

    final orderNumber = cart.generateOrderNumber();
    final paymentMethod = result['method'] as String;
    final tendered = result['tendered'] as double?;

    await printer.printReceipt(
      items: cart.items.toList(),
      subtotal: cart.subtotal,
      taxAmount: cart.taxAmount,
      total: cart.total,
      taxRate: cart.taxRate,
      orderNumber: orderNumber,
      paymentMethod: paymentMethod,
      amountTendered: tendered,
    );

    if (context.mounted) {
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #$orderNumber completed!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showPrinterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _PrinterSettingsDialog(),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A73E8),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1A73E8)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutDialog extends StatefulWidget {
  final double total;
  const _CheckoutDialog({required this.total});

  @override
  State<_CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<_CheckoutDialog> {
  String _paymentMethod = 'Cash';
  final _tenderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Checkout'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: \$${widget.total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Payment Method:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Cash', 'Card', 'E-Wallet'].map((m) {
                return ChoiceChip(
                  label: Text(m),
                  selected: _paymentMethod == m,
                  onSelected: (_) => setState(() => _paymentMethod = m),
                );
              }).toList(),
            ),
            if (_paymentMethod == 'Cash') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _tenderController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount Tendered (\$)',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final tendered = double.tryParse(_tenderController.text);
            Navigator.pop(context, {
              'method': _paymentMethod,
              'tendered': tendered,
            });
          },
          icon: const Icon(Icons.print),
          label: const Text('Print Receipt'),
        ),
      ],
    );
  }
}

class _PrinterSettingsDialog extends StatelessWidget {
  const _PrinterSettingsDialog();

  @override
  Widget build(BuildContext context) {
    final printer = context.watch<PrinterProvider>();
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.print),
          SizedBox(width: 8),
          Text('Printer Settings'),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusRow(
                label: 'Status', value: printer.statusMessage),
            const Divider(),
            _ActionButton(
              icon: Icons.refresh,
              label: 'Re-initialize Printer',
              onTap: () => printer.initPrinter(),
            ),
            _ActionButton(
              icon: Icons.print,
              label: 'Print Test Page',
              onTap: () {
                Navigator.pop(context);
                printer.printTestPage();
              },
            ),
            _ActionButton(
              icon: Icons.payments,
              label: 'Open Cash Drawer',
              onTap: () => printer.openCashDrawer(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatusRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey)),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1A73E8)),
      title: Text(label),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
