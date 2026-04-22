import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/printer_provider.dart';
import 'screens/pos_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IminPosApp());
}

class IminPosApp extends StatelessWidget {
  const IminPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
      ],
      child: MaterialApp(
        title: 'iMin POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A73E8),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const PosScreen(),
      ),
    );
  }
}
