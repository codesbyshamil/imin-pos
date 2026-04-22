# iMin POS — Flutter App for iMin D1 Pro Printer

A simple Flutter POS (Point of Sale) app built to test the **iMin D1 Pro** built-in thermal printer using the official [`imin_printer`](https://pub.dev/packages/imin_printer) Flutter package.

---

## 📦 Features

| Feature | Description |
|---|---|
| 🛍️ Product Catalog | 18 sample products across Food, Drinks & Snacks |
| 🛒 Cart Management | Add/remove items, quantity control, auto-totals |
| 🖨️ Receipt Printing | Full receipt with items, tax, totals, barcode |
| 🧪 Test Page | Printer diagnostic: fonts, alignment, character map |
| 👨‍🍳 Kitchen Orders | Separate kitchen ticket printing |
| 💵 Cash Drawer | Open drawer via printer command |
| 📊 Printer Status | Live status indicator in app bar |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android SDK (API 26+)
- iMin D1 Pro device (runs Android 10)
- USB or WiFi connection to the device for ADB

### 1. Clone & Install

```bash
flutter pub get
```

### 2. Run on iMin D1 Pro

Connect the D1 Pro via USB with ADB enabled:

```bash
# Verify device is connected
adb devices

# Build & deploy
flutter run --release
```

Or build an APK for sideloading:

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🖨️ Printer Usage

### Initialize
The app **auto-initializes** the printer on startup. If it fails, tap the ⚙️ settings icon → **Re-initialize Printer**.

### Print a Receipt
1. Tap products to add them to the cart
2. Tap **Checkout & Print**
3. Select payment method (Cash/Card/E-Wallet)
4. For cash: enter the tendered amount to see change
5. Tap **Print Receipt** — the D1 Pro will print and cut

### Print Test Page
- Tap **Print Test Page** in the cart panel, or
- Go to ⚙️ Settings → **Print Test Page**

### Open Cash Drawer
Go to ⚙️ Settings → **Open Cash Drawer**

---

## 📁 Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/
│   └── product.dart           # Product & CartItem models + sample data
├── providers/
│   ├── cart_provider.dart     # Cart state management
│   └── printer_provider.dart  # iMin printer SDK wrapper
├── screens/
│   └── pos_screen.dart        # Main POS layout
└── widgets/
    ├── product_grid.dart      # Product grid with tap-to-add
    ├── cart_panel.dart        # Cart sidebar with totals
    └── printer_status_bar.dart # AppBar status chip
```

---

## 🔧 iMin SDK Integration

This app uses the [`imin_printer`](https://pub.dev/packages/imin_printer) package, which wraps the official iMin Printer SDK via a Flutter plugin.

**Key methods used:**

```dart
await _printer.initPrinter();           // Initialize SDK
await _printer.setTextSize(24);         // Set font size (18–36)
await _printer.setTextBold(true);       // Bold text
await _printer.setAlignment(align);     // left / center / right
await _printer.printText('Hello\n');    // Print text line
await _printer.printBarCode(...);       // Print barcode (Code128)
await _printer.printAndLineFeed();      // Feed paper
await _printer.partialCut();            // Cut paper
await _printer.openCashBox();           // Trigger cash drawer
```

---

## ⚠️ Notes

- The app is **Android only** (iMin D1 Pro is Android-based)
- The `imin_printer` package communicates with the built-in printer service via AIDL — **no Bluetooth or USB setup required** on the device itself
- `minSdk` is set to **26** (Android 8.0) per iMin SDK requirements
- For production, replace sample products and store info in `product.dart` and `printer_provider.dart`
