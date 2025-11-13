import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/history_model.dart';
import '../../data/services/history_service.dart';
import '../../widgets/shimmer_loading.dart';

class InspectionDetailPage extends StatefulWidget {
  const InspectionDetailPage({super.key});

  @override
  State<InspectionDetailPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionDetailPage> {
  final HistoryService _historyService = HistoryService();
  InspectionDetail? inspection;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInspectionDetails();
  }

  Future<void> _loadInspectionDetails() async {
    try {
      final int id = Get.arguments as int;
      final detail = await _historyService.getInspectionDetails(id);

      if (!mounted) return; // Check if widget is still mounted

      setState(() {
        if (detail.inspection != null) {
          inspection = detail.inspection;
          isLoading = false;
        } else {
          errorMessage = 'Inspection details not available';
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
      appBar: AppBar(title: const Text('Inspection Details'), elevation: 0),
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
            'Failed to load inspection',
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
              _loadInspectionDetails();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (inspection == null) return const SizedBox.shrink();

    final inspectionData = inspection!; // Non-null assertion for cleaner code

    // Group responses by section
    final Map<String, List<InspectionResponse>> groupedResponses = {};
    for (var response in inspectionData.responses) {
      if (!groupedResponses.containsKey(response.sectionTitle)) {
        groupedResponses[response.sectionTitle] = [];
      }
      groupedResponses[response.sectionTitle]!.add(response);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in,
                          color: AppColors.brandBlue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inspectionData.template,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: #${inspectionData.id}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.directions_car,
                    'Vehicle',
                    inspectionData.registrationNumber,
                    AppColors.brandBlue,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.business,
                    'Company',
                    inspectionData.companyName,
                    Colors.grey[700]!,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date & Time',
                    '${inspectionData.date} at ${inspectionData.time}',
                    Colors.grey[700]!,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Summary Stats
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.topic,
                    'Sections',
                    groupedResponses.length.toString(),
                    AppColors.info,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildStatItem(
                    Icons.quiz,
                    'Questions',
                    inspectionData.responses.length.toString(),
                    AppColors.brandBlue,
                  ),
                  Container(height: 40, width: 1, color: Colors.grey[300]),
                  _buildStatItem(
                    Icons.photo_library,
                    'Photos',
                    inspectionData.responses
                        .where((r) => r.photo != null)
                        .length
                        .toString(),
                    AppColors.warning,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Supervisor Remarks Section - Above Inspection Details
          if (inspectionData.remarks != null &&
              inspectionData.remarks!.isNotEmpty) ...[
            Text(
              'Supervisor Remarks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            _SupervisorRemarksCard(remarks: inspectionData.remarks!),
            const SizedBox(height: 16),
          ],

          // Section Title
          Text(
            'Inspection Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),

          // Grouped Responses by Section
          ...groupedResponses.entries.map((entry) {
            return _buildSectionCard(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    String sectionTitle,
    List<InspectionResponse> responses,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.folder_open,
                  color: AppColors.brandBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    sectionTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${responses.length} items',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...responses.map((response) => _buildResponseItem(response)),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseItem(InspectionResponse response) {
    final bool hasPhoto = response.photo != null && response.photo!.isNotEmpty;
    final Color answerColor = _getAnswerColor(response.answer);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _getAnswerIcon(response.answer),
                color: answerColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      response.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
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
                          fontSize: 13,
                          color: answerColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasPhoto) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                response.photo!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  IconData _getAnswerIcon(String answer) {
    final lowerAnswer = answer.toLowerCase();
    if (lowerAnswer == 'yes' ||
        lowerAnswer == 'good' ||
        lowerAnswer == 'pass') {
      return Icons.check_circle;
    } else if (lowerAnswer == 'no' ||
        lowerAnswer == 'bad' ||
        lowerAnswer == 'fail') {
      return Icons.cancel;
    }
    return Icons.info;
  }

  Color _getAnswerColor(String answer) {
    final lowerAnswer = answer.toLowerCase();
    if (lowerAnswer == 'yes' ||
        lowerAnswer == 'good' ||
        lowerAnswer == 'pass') {
      return AppColors.success;
    } else if (lowerAnswer == 'no' ||
        lowerAnswer == 'bad' ||
        lowerAnswer == 'fail') {
      return AppColors.error;
    }
    return AppColors.warning;
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
      elevation: 2,
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
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
