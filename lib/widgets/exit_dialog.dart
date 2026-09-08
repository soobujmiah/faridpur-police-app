import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Future<bool> showExitConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('অ্যাপ থেকে বের হবেন?'),
      content: const Text('আপনি কি নিশ্চিতভাবে অ্যাপটি বন্ধ করতে চান?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('না'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('হ্যাঁ'),
        ),
      ],
    ),
  );
  return result ?? false;
}
