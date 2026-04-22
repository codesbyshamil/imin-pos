import 'package:flutter/foundation.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer/enums.dart';
import 'package:imin_printer/imin_style.dart';
import '../models/product.dart';

enum PrinterStatus { disconnected, connecting, ready, printing, error }

class PrinterProvider extends ChangeNotifier {
  final IminPrinter _printer = IminPrinter();
  PrinterStatus _status = PrinterStatus.disconnected;
  String _statusMessage = 'Not initialized';
  bool _isInitialized = false;

  PrinterStatus get status => _status;
  String get statusMessage => _statusMessage;
  bool get isReady => _status == PrinterStatus.ready;
  bool get isInitialized => _isInitialized;

  Future<void> initPrinter() async {
    _setStatus(PrinterStatus.connecting, 'Initializing printer...');
    try {
      await _printer.initPrinter();
      _isInitialized = true;
      _setStatus(PrinterStatus.ready, 'Printer ready');
    } catch (e) {
      _setStatus(PrinterStatus.error, 'Init failed: $e');
    }
  }

  Future<void> printTestPage() async {
    if (!_ensureReady()) return;
    _setStatus(PrinterStatus.printing, 'Printing test page...');
    try {
      await _printer.setTextSize(28);
      await _printer.setTextTypeface(IminTypeface.typefaceMonospace);
      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.printText('=== PRINTER TEST ===\n');
      await _printer.setTextSize(22);
      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.printText('iMin D1 Pro\n');
      await _printer.printText('POS System Test\n\n');
      await _printer.setAlignment(IminPrintAlign.left);
      await _printer.setTextSize(20);
      await _printer.printText('Alignment Tests:\n');
      await _printer.setAlignment(IminPrintAlign.left);
      await _printer.printText('LEFT ALIGNED TEXT\n');
      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.printText('CENTER ALIGNED TEXT\n');
      await _printer.setAlignment(IminPrintAlign.right);
      await _printer.printText('RIGHT ALIGNED TEXT\n\n');
      await _printer.setAlignment(IminPrintAlign.left);
      await _printer.printText('Font Size Tests:\n');
      for (int size in [18, 22, 26, 30]) {
        await _printer.setTextSize(size);
        await _printer.printText('Size $size: Hello iMin!\n');
      }
      await _printer.setTextSize(20);
      await _printer.printText('\nCharacter Map:\n');
      await _printer.printText('0123456789\n');
      await _printer.printText('ABCDEFGHIJKLMNOPQRSTUVWXYZ\n');
      await _printer.printText('abcdefghijklmnopqrstuvwxyz\n');
      await _printer.printText('!@#\$%^&*()-+=[]{}|;:,.<>?\n\n');
      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.setTextSize(22);
      await _printer.printText('--- TEST COMPLETE ---\n');
      await _printer.printAndLineFeed();
      await _printer.partialCut();
      _setStatus(PrinterStatus.ready, 'Test page printed');
    } catch (e) {
      _setStatus(PrinterStatus.error, 'Print failed: $e');
    }
  }

  Future<void> printReceipt({
    required List<CartItem> items,
    required double subtotal,
    required double taxAmount,
    required double total,
    required double taxRate,
    required String orderNumber,
    required String paymentMethod,
    double? amountTendered,
  }) async {
    if (!_ensureReady()) return;
    _setStatus(PrinterStatus.printing, 'Printing receipt...');
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.setTextSize(28);
      await _printer.setTextStyle(IminFontStyle.bold);
      await _printer.printText('MY STORE\n');
      await _printer.setTextStyle(IminFontStyle.normal);
      await _printer.setTextSize(20);
      await _printer.printText('123 Main Street\n');
      await _printer.printText('City, State 12345\n');
      await _printer.printText('Tel: (555) 123-4567\n');
      await _printer.printText('--------------------------------\n');

      await _printer.setAlignment(IminPrintAlign.left);
      await _printer.setTextSize(20);
      await _printer.printText('Order #: $orderNumber\n');
      await _printer.printText('Date: $dateStr\n');
      await _printer.printText('Time: $timeStr\n');
      await _printer.printText('Cashier: POS Terminal 1\n');
      await _printer.printText('--------------------------------\n');

      await _printer.setTextStyle(IminFontStyle.bold);
      await _printer.printText(
          '${'ITEM'.padRight(16)}${'QTY'.padLeft(4)}${'PRICE'.padLeft(10)}\n');
      await _printer.setTextStyle(IminFontStyle.normal);
      await _printer.printText('--------------------------------\n');

      for (final item in items) {
        final name = item.product.name.length > 16
            ? item.product.name.substring(0, 15) + '.'
            : item.product.name;
        final qty = 'x${item.quantity}'.padLeft(4);
        final price = '\$${item.subtotal.toStringAsFixed(2)}'.padLeft(10);
        await _printer.printText('${name.padRight(16)}$qty$price\n');
        if (item.quantity > 1) {
          await _printer.printText(
              '  @\$${item.product.price.toStringAsFixed(2)} each\n');
        }
      }

      await _printer.printText('--------------------------------\n');
      await _printer.setAlignment(IminPrintAlign.right);
      await _printer.printText('Subtotal:  \$${subtotal.toStringAsFixed(2)}\n');
      await _printer.printText(
          'Tax (${(taxRate * 100).toStringAsFixed(0)}%):  \$${taxAmount.toStringAsFixed(2)}\n');
      await _printer.setTextStyle(IminFontStyle.bold);
      await _printer.setTextSize(24);
      await _printer.printText('TOTAL:  \$${total.toStringAsFixed(2)}\n');
      await _printer.setTextStyle(IminFontStyle.normal);
      await _printer.setTextSize(20);
      await _printer.printText('--------------------------------\n');

      await _printer.setAlignment(IminPrintAlign.left);
      await _printer.printText('Payment: $paymentMethod\n');
      if (amountTendered != null && amountTendered > 0) {
        await _printer.printText(
            'Tendered: \$${amountTendered.toStringAsFixed(2)}\n');
        final change = amountTendered - total;
        await _printer.printText('Change: \$${change.toStringAsFixed(2)}\n');
      }
      await _printer.printText('--------------------------------\n');

      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.setTextSize(20);
      await _printer.printText('\nThank you for your purchase!\n');
      await _printer.printText('Please come again.\n\n');
      await _printer.printText('Powered by iMin D1 Pro\n\n');

      final barcodeContent = orderNumber.replaceAll('-', '');
      await _printer.printBarCode(
        IminBarcodeType.code128,
        barcodeContent,
        style: IminBarCodeStyle(
          align: IminPrintAlign.center,
          height: 60,
          width: 2,
          position: IminBarcodeTextPos.textBelow,
        ),
      );

      await _printer.printAndLineFeed();
      await _printer.partialCut();
      _setStatus(PrinterStatus.ready, 'Receipt printed');
    } catch (e) {
      _setStatus(PrinterStatus.error, 'Print failed: $e');
    }
  }

  Future<void> printKitchenOrder({
    required List<CartItem> items,
    required String orderNumber,
    String? tableNumber,
    String? notes,
  }) async {
    if (!_ensureReady()) return;
    _setStatus(PrinterStatus.printing, 'Printing kitchen order...');
    try {
      final now = DateTime.now();
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      await _printer.setAlignment(IminPrintAlign.center);
      await _printer.setTextSize(30);
      await _printer.setTextStyle(IminFontStyle.bold);
      await _printer.printText('*** KITCHEN ORDER ***\n');
      await _printer.setTextStyle(IminFontStyle.normal);
      await _printer.setTextSize(26);
      await _printer.printText('Order #: $orderNumber\n');
      await _printer.printText('Time: $timeStr\n');
      if (tableNumber != null && tableNumber.isNotEmpty) {
        await _printer.printText('Table: $tableNumber\n');
      }
      await _printer.printText('================================\n');
      await _printer.setAlignment(IminPrintAlign.left);
      for (final item in items) {
        await _printer.setTextStyle(IminFontStyle.bold);
        await _printer.printText('${item.quantity}x ${item.product.name}\n');
        await _printer.setTextStyle(IminFontStyle.normal);
      }
      if (notes != null && notes.isNotEmpty) {
        await _printer.printText('================================\n');
        await _printer.printText('NOTES: $notes\n');
      }
      await _printer.printText('================================\n');
      await _printer.printAndLineFeed();
      await _printer.partialCut();
      _setStatus(PrinterStatus.ready, 'Kitchen order printed');
    } catch (e) {
      _setStatus(PrinterStatus.error, 'Print failed: $e');
    }
  }

  Future<void> openCashDrawer() async {
    if (!_ensureReady()) return;
    try {
      await _printer.openCashBox();
      _setStatus(PrinterStatus.ready, 'Cash drawer opened');
    } catch (e) {
      _setStatus(PrinterStatus.error, 'Drawer failed: $e');
    }
  }

  bool _ensureReady() {
    if (!_isInitialized || _status == PrinterStatus.error) {
      _setStatus(PrinterStatus.error, 'Printer not ready. Please initialize.');
      return false;
    }
    return true;
  }

  void _setStatus(PrinterStatus status, String message) {
    _status = status;
    _statusMessage = message;
    notifyListeners();
  }
}
