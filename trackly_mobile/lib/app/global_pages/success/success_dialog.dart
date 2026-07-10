import 'package:flutter/material.dart';

void showSuccessDialog(
  BuildContext context, {
  String message = 'Success!',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (
          BuildContext context,
        ) {
          // Auto-dismiss after 2 seconds
          Future.delayed(
            const Duration(
              seconds: 2,
            ),
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          );

          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Big green check circle icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Success message
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
  );
}
