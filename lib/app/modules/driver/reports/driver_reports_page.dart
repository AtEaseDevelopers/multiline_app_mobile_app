import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/primary_button.dart';

class DriverReportsPage extends StatelessWidget {
  const DriverReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('My Reports'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          // Header with New Inspection Button
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Inspection Reports',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PrimaryButton(
                  text: 'New Inspection',
                  icon: Icons.add,
                  onPressed: () => Get.toNamed(AppRoutes.inspection),
                ),
              ],
            ),
          ),
          
          // Reports List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sampleReports.length,
              itemBuilder: (context, index) {
                final report = _sampleReports[index];
                return _ReportCard(report: report);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final _InspectionReport report;
  
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: report.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            report.statusIcon,
            color: report.statusColor,
            size: 24,
          ),
        ),
        title: Text(
          report.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report.date,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: report.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: report.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          // Navigate to report details
        },
      ),
    );
  }
}

class _InspectionReport {
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final IconData statusIcon;

  const _InspectionReport({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });
}

final List<_InspectionReport> _sampleReports = [
  _InspectionReport(
    title: 'Pre-Trip Inspection #001',
    date: 'Today • 08:30 AM',
    status: 'Passed',
    statusColor: AppColors.success,
    statusIcon: Icons.check_circle,
  ),
  _InspectionReport(
    title: 'Post-Trip Inspection #045',
    date: 'Yesterday • 06:45 PM',
    status: 'Passed',
    statusColor: AppColors.success,
    statusIcon: Icons.check_circle,
  ),
  _InspectionReport(
    title: 'Pre-Trip Inspection #044',
    date: '2 days ago • 08:15 AM',
    status: 'Failed',
    statusColor: AppColors.brandRed,
    statusIcon: Icons.error,
  ),
  _InspectionReport(
    title: 'Pre-Trip Inspection #043',
    date: '3 days ago • 08:20 AM',
    status: 'Under Review',
    statusColor: AppColors.warning,
    statusIcon: Icons.pending,
  ),
  _InspectionReport(
    title: 'Post-Trip Inspection #042',
    date: '3 days ago • 07:30 PM',
    status: 'Passed',
    statusColor: AppColors.success,
    statusIcon: Icons.check_circle,
  ),
];