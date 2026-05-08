import 'package:flutter/material.dart';

import '../../../../models/contact.dart';

class ConfirmDeleteContactDialog {
  const ConfirmDeleteContactDialog._();

  static Future<bool> show(
    BuildContext context, {
    required Contact contact,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('Delete "${contact.name}"?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result == true;
  }
}
