import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  final EdgeInsets padding;
  const OfflineBanner({super.key, this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      color: Colors.amber.shade800.withValues(alpha:  0.9),
      child: const Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.wifi_off, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sin conexión. Mostrando datos en caché (si existen).',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
