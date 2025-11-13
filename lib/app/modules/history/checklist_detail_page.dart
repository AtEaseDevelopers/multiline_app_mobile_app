import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/history_model.dart';
import '../../data/services/history_service.dart';
import '../../widgets/shimmer_loading.dart';

class ChecklistDetailPage extends StatefulWidget {
  const ChecklistDetailPage({super.key});

  @override
  State<ChecklistDetailPage> createState() => _ChecklistDetailPageState();
}

class _ChecklistDetailPageState extends State<ChecklistDetailPage> {
  final HistoryService _historyService = HistoryService();
  ChecklistDetail? checklist;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChecklistDetails();
  }

  Future<void> _loadChecklistDetails() async {
    try {
      final int id = Get.arguments as int;
      final detail = await _historyService.getChecklistDetails(id);

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        if (detail.checklist != null) {
          checklist = detail.checklist;
          isLoading = false;
        } else {
          errorMessage = 'Checklist details not available';
          isLoading = false;
        }
      });
    } catch (e) {
      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Checklist Details'),
        elevation: 0,
        backgroundColor: AppColors.brandRed,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? _buildShimmerLoading(context)
          : errorMessage != null
          ? _buildErrorView()
          : _buildContent(),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return ShimmerLoading.shimmerEffect(
      context: context,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header shimmer
            ShimmerLoading.box(
              width: double.infinity,
              height: 200,
              context: context,
            ),
            const SizedBox(height: 16),
            // Stats shimmer
            ShimmerLoading.box(
              width: double.infinity,
              height: 100,
              context: context,
            ),
            const SizedBox(height: 16),
            // Content shimmers
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading.box(
                  width: double.infinity,
                  height: 120,
                  context: context,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load checklist',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _loadChecklistDetails();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (checklist == null) return const SizedBox.shrink();

    final checklistData = checklist!; // Non-null assertion for cleaner code

    // Group responses by section title
    final Map<String, List<ChecklistResponse>> groupedResponses = {};
    for (var response in checklistData.responses) {
      if (!groupedResponses.containsKey(response.sectionTitle)) {
        groupedResponses[response.sectionTitle] = [];
      }
      groupedResponses[response.sectionTitle]!.add(response);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.brandRed,
                  AppColors.brandRed.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandRed.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.checklist_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            checklistData.template,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'ID: #${checklistData.id}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.directions_car,
                  'Vehicle',
                  checklistData.vehicleNumber,
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.business,
                  'Company',
                  checklistData.companyName,
                  Colors.grey,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date & Time',
                  '${checklistData.date} at ${checklistData.time}',
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Summary Stats Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.folder_outlined,
                  groupedResponses.length.toString(),
                  'Sections',
                  AppColors.brandRed,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatItem(
                  Icons.chat_bubble_outline,
                  checklistData.responses.length.toString(),
                  'Questions',
                  Colors.orange,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildStatItem(
                  Icons.note_alt_outlined,
                  checklistData.responses
                      .where((r) => r.remarks != null && r.remarks!.isNotEmpty)
                      .length
                      .toString(),
                  'Remarks',
                  Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Checklist Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey[300], thickness: 1),
          ),

          const SizedBox(height: 16),

          // Supervisor Remarks Section - Above Checklist Details
          if (checklistData.remarks != null &&
              checklistData.remarks!.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Supervisor Remarks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SupervisorRemarksCard(remarks: checklistData.remarks!),
            ),
            const SizedBox(height: 16),
          ],

          // Grouped Sections
          ...groupedResponses.entries.map((entry) {
            return _buildSectionCard(entry.key, entry.value);
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSectionCard(
    String sectionTitle,
    List<ChecklistResponse> responses,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandRed.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open, color: AppColors.brandRed, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${responses.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: responses.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              return _buildResponseItem(responses[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResponseItem(ChecklistResponse response) {
    final answerIcon = _getAnswerIcon(response.answer);
    final answerColor = _getAnswerColor(response.answer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: answerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(answerIcon, color: answerColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: answerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: answerColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      response.answer,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: answerColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Show remarks if available
        if (response.remarks != null && response.remarks!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Remarks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  response.remarks!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  IconData _getAnswerIcon(String answer) {
    final lowerAnswer = answer.toLowerCase();
    if (lowerAnswer.contains('yes') ||
        lowerAnswer.contains('good') ||
        lowerAnswer.contains('pass') ||
        lowerAnswer.contains('ok') ||
        lowerAnswer.contains('complete')) {
      return Icons.check_circle;
    } else if (lowerAnswer.contains('no') ||
        lowerAnswer.contains('bad') ||
        lowerAnswer.contains('fail') ||
        lowerAnswer.contains('incomplete')) {
      return Icons.cancel;
    } else {
      return Icons.info;
    }
  }

  Color _getAnswerColor(String answer) {
    final lowerAnswer = answer.toLowerCase();
    if (lowerAnswer.contains('yes') ||
        lowerAnswer.contains('good') ||
        lowerAnswer.contains('pass') ||
        lowerAnswer.contains('ok') ||
        lowerAnswer.contains('complete')) {
      return const Color(0xFF4CAF50); // Green
    } else if (lowerAnswer.contains('no') ||
        lowerAnswer.contains('bad') ||
        lowerAnswer.contains('fail') ||
        lowerAnswer.contains('incomplete')) {
      return const Color(0xFFF44336); // Red
    } else {
      return const Color(0xFFFF9800); // Orange
    }
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
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
    );
  }
}
