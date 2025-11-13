import 'package:flutter/material.dart';

class ChecklistItem extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String>? onChanged;
  final bool photoRequired;

  const ChecklistItem({
    super.key,
    required this.title,
    this.options = const ['Pass', 'Fail', 'N/A'],
    this.selected,
    this.onChanged,
    this.photoRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (photoRequired)
                  const Text(
                    '[📸 Photo Required]',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: options
                  .map(
                    (o) => ChoiceChip(
                      label: Text(o),
                      selected: selected == o,
                      onSelected: (_) => onChanged?.call(o),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
