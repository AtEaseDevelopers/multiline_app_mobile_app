import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_strings.dart';
import '../../data/models/history_model.dart';
import 'history_controller.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Wait for tab controller to be ready
      if (!controller.isTabControllerReady.value) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(title: Text(SKeys.history.tr), elevation: 0),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(SKeys.history.tr),
          elevation: 0,
          bottom: controller.userType.value == 'supervisor'
              ? TabBar(
                  controller: controller.tabController,
                  onTap: controller.changeTab,
                  tabs: [
                    Tab(text: SKeys.inspections.tr),
                    Tab(text: SKeys.dailyChecklists.tr),
                  ],
                )
              : TabBar(
                  controller: controller.tabController,
                  onTap: controller.changeTab,
                  tabs: [
                    Tab(text: SKeys.incidents.tr),
                    Tab(text: SKeys.inspections.tr),
                    Tab(text: SKeys.dailyChecklists.tr),
                  ],
                ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).iconTheme.color?.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.refresh,
                    child: Text(SKeys.retry.tr),
                  ),
                ],
              ),
            );
          }

          // Return appropriate TabBarView based on user type
          if (controller.userType.value == 'supervisor') {
            return TabBarView(
              controller: controller.tabController,
              children: [_InspectionsTab(), _ChecklistsTab()],
            );
          }

          return TabBarView(
            controller: controller.tabController,
            children: [_IncidentsTab(), _InspectionsTab(), _ChecklistsTab()],
          );
        }),
      );
    });
  }
}

// Incidents Tab
class _IncidentsTab extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.sortedIncidents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                SKeys.noIncidents.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                SKeys.incidentsWillAppear.tr,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sortedIncidents.length,
          itemBuilder: (context, index) {
            final incident = controller.sortedIncidents[index];
            return _IncidentCard(incident: incident);
          },
        ),
      );
    });
  }
}

class _IncidentCard extends GetView<HistoryController> {
  final IncidentHistoryItem incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.navigateToIncidentDetail(incident.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      incident.incidentType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status badge removed for driver - no need to show pending approval
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    incident.vehicleNumber,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${incident.date} ${incident.time}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Inspections Tab
class _InspectionsTab extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.sortedInspections.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                SKeys.noInspections.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                SKeys.inspectionsWillAppear.tr,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sortedInspections.length,
          itemBuilder: (context, index) {
            final inspection = controller.sortedInspections[index];
            return _InspectionCard(inspection: inspection);
          },
        ),
      );
    });
  }
}

class _InspectionCard extends GetView<HistoryController> {
  final InspectionHistoryItem inspection;

  const _InspectionCard({required this.inspection});

  Color _getStatusColor() {
    switch (inspection.status.toLowerCase()) {
      case 'pass':
      case 'passed':
        return AppColors.success;
      case 'fail':
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.navigateToInspectionDetail(inspection.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 20,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          inspection.vehicleNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      inspection.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (inspection.inspectorName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      inspection.inspectorName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${inspection.date} ${inspection.time}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Checklists Tab
class _ChecklistsTab extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.sortedChecklists.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.checklist_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                SKeys.noChecklists.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                SKeys.checklistsWillAppear.tr,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.sortedChecklists.length,
          itemBuilder: (context, index) {
            final checklist = controller.sortedChecklists[index];
            return _ChecklistCard(checklist: checklist);
          },
        ),
      );
    });
  }
}

class _ChecklistCard extends GetView<HistoryController> {
  final ChecklistHistoryItem checklist;

  const _ChecklistCard({required this.checklist});

  Color _getStatusColor() {
    switch (checklist.status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'incomplete':
      case 'pending':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.navigateToChecklistDetail(checklist.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          size: 20,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          checklist.vehicleNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      checklist.status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (checklist.totalItems != null &&
                  checklist.completedItems != null)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${checklist.completedItems} / ${checklist.totalItems} items completed',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${checklist.date} ${checklist.time}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
