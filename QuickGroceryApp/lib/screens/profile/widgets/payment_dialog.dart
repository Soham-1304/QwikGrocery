import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Draft representation of user payment input for simulation.
class PaymentDraft {
  const PaymentDraft(
    this.type,
    this.label, {
    this.lastFour = '',
    this.upiId = '',
  });
  final String type, label, lastFour, upiId;
}

/// Modal dialog for adding simulated cards or UPI IDs.
class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController(text: 'Demo card');
  final _lastFour = TextEditingController();
  final _upi = TextEditingController(text: 'demo@upi');
  String _type = 'card';

  @override
  void dispose() {
    _label.dispose();
    _lastFour.dispose();
    _upi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add demo payment'),
    content: SizedBox(
      width: 420,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Simulation only. Enter no real payment credentials.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Method'),
              items: const [
                DropdownMenuItem(
                  value: 'card',
                  child: Text('Card (masked demo)'),
                ),
                DropdownMenuItem(value: 'upi', child: Text('UPI (demo ID)')),
              ],
              onChanged: (value) => setState(() => _type = value ?? 'card'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _label,
              decoration: InputDecoration(
                labelText: _type == 'card' ? 'Card label' : 'UPI label',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            if (_type == 'card')
              TextFormField(
                controller: _lastFour,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Last four digits only',
                ),
                validator: (v) => v == null || !RegExp(r'^\d{4}$').hasMatch(v)
                    ? 'Enter exactly four digits'
                    : null,
              )
            else
              TextFormField(
                controller: _upi,
                decoration: const InputDecoration(labelText: 'Demo UPI ID'),
                validator: (v) =>
                    v == null || !RegExp(r'^[\w.-]{2,}@[\w.-]{2,}$').hasMatch(v)
                        ? 'Enter a demo UPI ID such as demo@upi'
                        : null,
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            PaymentDraft(
              _type,
              _label.text.trim(),
              lastFour: _lastFour.text,
              upiId: _upi.text.trim(),
            ),
          );
        },
        child: const Text('Save demo method'),
      ),
    ],
  );
}
