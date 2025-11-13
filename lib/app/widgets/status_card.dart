import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum StatusType { pending, completed, error, info }

class StatusCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final StatusType status;
  final VoidCallback? onTap;
  final Widget? trailing;

  const StatusCard({
    super.key,
    required this.title,
    this.subtitle,
    this.status = StatusType.info,
    this.onTap,
    this.trailing,
  });

  Color _statusColor() {
    switch (status) {
      case StatusType.pending:
        return AppColors.warning;
      case StatusType.completed:
        return AppColors.success;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 48,
                decoration: BoxDecoration(
                  color: _statusColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
