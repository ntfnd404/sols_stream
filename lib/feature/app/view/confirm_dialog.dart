import 'package:flutter/material.dart';

/// Confirmation dialog content shown by a dialog-as-route (`TransparentPage`).
/// A pure view: the route wires [onConfirm]/[onCancel] to `popWith`. `AlertDialog`
/// themes itself, so there are no hardcoded colors.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: Text(message),
    actions: <Widget>[
      TextButton(onPressed: onCancel, child: const Text('Cancel')),
      FilledButton(onPressed: onConfirm, child: const Text('Confirm')),
    ],
  );
}
