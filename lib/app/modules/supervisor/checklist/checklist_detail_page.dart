import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/shimmer_loading.dart';
import 'checklist_detail_controller.dart';

class ChecklistDetailPage extends StatelessWidget {
  const ChecklistDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChecklistDetailController());

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        title: const Text('Checklist Details'),
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value &&
            controller.checklistDetail.value == null) {
          return ShimmerLoading.supervisorDashboard(context);
        }

        // Show error state
        if (controller.errorMessage.value != null &&
            controller.checklistDetail.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.loadChecklistDetails,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final checklist = controller.checklistDetail.value;
        if (checklist == null) {
          return const Center(child: Text('No data available'));
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _HeaderCard(checklist: checklist),
                    const SizedBox(height: 16),

                    // Remarks Section (from supervisor) - Above Items
                    if (checklist.remarks != null &&
                        checklist.remarks!.isNotEmpty) ...[
                      const _SectionTitle(title: 'Supervisor Remarks'),
                      const SizedBox(height: 10),
                      _SupervisorRemarksCard(remarks: checklist.remarks!),
                      const SizedBox(height: 16),
                    ],

                    // Items Section
                    if (checklist.responses.isNotEmpty) ...[
                      _SectionTitle(
                        title:
                            'Checklist Items (${checklist.responses.length})',
                      ),
                      const SizedBox(height: 10),
                      ...checklist.responses.map(
                        (response) => _ChecklistItemCard(response: response),
                      ),
                    ],

                    // Company Section
                    if (checklist.companyName.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const _SectionTitle(title: 'Company'),
                      const SizedBox(height: 10),
                      _CommentsCard(comments: checklist.companyName),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _ActionButtons(controller: controller),
          ],
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final checklist;
  const _HeaderCard({required this.checklist});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.checklist_rtl,
                    color: AppColors.success,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checklist.template,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.person,
              label: 'Driver',
              value: checklist.driver,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.directions_car,
              label: 'Vehicle',
              value: checklist.registrationNumber,
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.access_time,
              label: 'Submitted',
              value: _formatDateTime(checklist.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class _ChecklistItemCard extends StatelessWidget {
  final response;
  const _ChecklistItemCard({required this.response});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title Badge
            if (response.sectionTitle.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  response.sectionTitle,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // Question
            Text(
              response.question,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            // Answer
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: _getValueColor(response.answer),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Answer: ${response.answer}',
                    style: TextStyle(
                      color: _getValueColor(response.answer),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Remarks
            if (response.remarks != null && response.remarks!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.note,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        response.remarks!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getValueColor(String? value) {
    if (value == null) return Colors.grey;
    switch (value.toLowerCase()) {
      case 'yes':
      case 'good':
        return Colors.green;
      case 'no':
      case 'bad':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _CommentsCard extends StatelessWidget {
  final String comments;
  const _CommentsCard({required this.comments});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(comments, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _SupervisorRemarksCard extends StatefulWidget {
  final String remarks;
  const _SupervisorRemarksCard({required this.remarks});

  @override
  State<_SupervisorRemarksCard> createState() => _SupervisorRemarksCardState();
}

class _SupervisorRemarksCardState extends State<_SupervisorRemarksCard> {
  bool _isExpanded = false;
  static const int _wordLimit = 100;

  bool get _needsExpansion {
    return widget.remarks.split(' ').length > _wordLimit;
  }

  String get _displayText {
    if (!_needsExpansion || _isExpanded) {
      return widget.remarks;
    }
    final words = widget.remarks.split(' ');
    return '${words.take(_wordLimit).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _displayText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            if (_needsExpansion) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'See less' : 'See more',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ChecklistDetailController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => OutlinedButton.icon(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                      ? null
                      : controller.showRejectDialog,
                  icon: controller.isRejecting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                      ? null
                      : controller.showApproveDialog,
                  icon: controller.isApproving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
