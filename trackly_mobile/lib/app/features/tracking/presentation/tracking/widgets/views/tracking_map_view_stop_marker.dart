import 'package:flutter/material.dart';

class StopMarker extends StatelessWidget {
  final bool isFirst;

  const StopMarker({
    super.key,
    required this.isFirst,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final color = Colors.greenAccent; // : Colors.orangeAccent;

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 2),
            color: Colors.black26,
          ),
        ],
      ),
      alignment: Alignment.center,
    );
  }
}
