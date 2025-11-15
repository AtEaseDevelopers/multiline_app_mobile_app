import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reports_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/report_model.dart';
import '../../core/values/app_strings.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      appBar: AppBar(
        title: Text(SKeys.myReports.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadReports,
            tooltip: SKeys.refresh.tr,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(SKeys.loadingReports.tr),
              ],
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: controller.loadReports,
                  icon: const Icon(Icons.refresh),
                  label: Text(SKeys.retry.tr),
                ),
              ],
            ),
          );
        }

        if (controller.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  SKeys.noReports.tr,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadReports,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reports.length,
            itemBuilder: (context, index) {
              final report = controller.reports[index];
              return _ReportCard(
                report: report,
                index: index,
                controller: controller,
              );
            },
          ),
        );
      }),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final DriverReport report;
  final int index;
  final ReportsController controller;

  const _ReportCard({
    required this.report,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDownloading = controller.downloadingReportIndex.value == index;
      final isDownloaded = controller.downloadedFiles.containsKey(
        report.fileName,
      );

      return Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: isDownloading
              ? null
              : () {
                  if (isDownloaded) {
                    controller.openDownloadedFile(report.fileName);
                  } else {
                    controller.downloadReport(index);
                  }
                },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // PDF Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: AppColors.brandBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                // Report Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.friendlyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.fileName,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      if (report.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(report.createdAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Download Button/Status Icon
                if (isDownloading)
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            // Show determinate progress only if > 5% (real progress)
                            // Show indeterminate (spinning) for 0-5% range
                            value: controller.downloadProgress.value >= 0.05
                                ? controller.downloadProgress.value
                                : null, // null = indeterminate/spinning
                            strokeWidth: 3,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.brandBlue,
                            ),
                          ),
                        ),
                        // Show percentage text only if progress >= 5% and < 100%
                        if (controller.downloadProgress.value >= 0.05 &&
                            controller.downloadProgress.value < 1.0)
                          Text(
                            '${(controller.downloadProgress.value * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandBlue,
                            ),
                          )
                        // Show checkmark at 100%
                        else if (controller.downloadProgress.value >= 1.0)
                          Icon(
                            Icons.check_circle,
                            size: 24,
                            color: Colors.green,
                          )
                        // Show downloading icon for initial/indeterminate state (0-5%)
                        else
                          Icon(
                            Icons.downloading,
                            size: 20,
                            color: AppColors.brandBlue,
                          ),
                      ],
                    ),
                  )
                else
                  // Action Icon (Download or Open)
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (isDownloaded ? Colors.green : AppColors.brandBlue)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDownloaded ? Icons.folder_open : Icons.download,
                      color: isDownloaded ? Colors.green : AppColors.brandBlue,
                      size: 28,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
