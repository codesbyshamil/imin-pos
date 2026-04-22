import 'package:flutter/material.dart';
import '../providers/printer_provider.dart';

class PrinterStatusChip extends StatelessWidget {
  final PrinterProvider printer;

  const PrinterStatusChip({super.key, required this.printer});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (printer.status) {
      PrinterStatus.ready => ('Ready', Colors.greenAccent, Icons.check_circle),
      PrinterStatus.printing => ('Printing...', Colors.amberAccent, Icons.print),
      PrinterStatus.connecting => ('Connecting...', Colors.lightBlueAccent, Icons.sync),
      PrinterStatus.error => ('Error', Colors.redAccent, Icons.error),
      PrinterStatus.disconnected => ('Offline', Colors.grey.shade400, Icons.print_disabled),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
