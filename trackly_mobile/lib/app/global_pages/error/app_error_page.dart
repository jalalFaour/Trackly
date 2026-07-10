import 'package:flutter/material.dart';

import '../../global_widgets/app_text_widget.dart';

class AppErrorPage extends StatelessWidget {
  final String message;

  const AppErrorPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Center(
          child: AppTextWidget(
            text: message,
            style: const TextStyle(color: Colors.white, fontSize: 26),
          ),
        ),
      ),
    );
  }
}
