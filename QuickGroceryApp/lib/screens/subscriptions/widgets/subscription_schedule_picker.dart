import 'package:flutter/material.dart';

/// Frequency and delivery time/date picker for subscription form.
class SubscriptionSchedulePicker extends StatelessWidget {
  const SubscriptionSchedulePicker({
    super.key,
    required this.frequency,
    required this.date,
    required this.time,
    required this.frequencies,
    required this.onFrequencyChanged,
    required this.onPickDate,
    required this.onPickTime,
  });

  final String frequency;
  final DateTime date;
  final TimeOfDay time;
  final List<String> frequencies;
  final ValueChanged<String?> onFrequencyChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Delivery schedule',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        initialValue: frequency,
        decoration: const InputDecoration(labelText: 'Schedule Frequency'),
        items: frequencies
            .map((f) => DropdownMenuItem(value: f, child: Text(f)))
            .toList(),
        onChanged: onFrequencyChanged,
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('${date.day}/${date.month}/${date.year}'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPickTime,
              icon: const Icon(Icons.schedule),
              label: Text(time.format(context)),
            ),
          ),
        ],
      ),
    ],
  );
}
