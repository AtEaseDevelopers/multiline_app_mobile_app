import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/history_model.dart';
import '../../data/services/history_service.dart';
import '../../data/services/storage_service.dart';

class HistoryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final HistoryService _historyService = HistoryService();

  // Tab Management
  TabController? tabController;
  final tabIndex = 0.obs;
  final userType = ''.obs;
  final isTabControllerReady = false.obs;

  // Loading States
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // History Data
  final incidents = <IncidentHistoryItem>[].obs;
  final inspections = <InspectionHistoryItem>[].obs;
  final checklists = <ChecklistHistoryItem>[].obs;

  // Detail Data
  final selectedIncidentDetail = Rxn<IncidentDetail>();
  final selectedInspectionDetail = Rxn<InspectionDetail>();
  final selectedChecklistDetail = Rxn<ChecklistDetail>();

  @override
  void onInit() {
    super.onInit();
    _initializeTabController();
    loadHistoryData();
  }

  Future<void> _initializeTabController() async {
    // Get user type to determine tab count
    final type = await StorageService.getUserType();
    userType.value = type ?? '';

    // Supervisors have 2 tabs (Inspections, Checklists), drivers have 3 (Incidents, Inspections, Checklists)
    final tabCount = userType.value == 'supervisor' ? 2 : 3;
    tabController = TabController(length: tabCount, vsync: this);
    isTabControllerReady.value = true;
  }

  @override
  void onClose() {
    tabController?.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    tabIndex.value = index;
    tabController?.animateTo(index);
  }

  /// Load History Data based on user role
  Future<void> loadHistoryData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // Determine user role
      final userRole = await StorageService.getUserType();

      HistoryResponse historyData;
      if (userRole == 'supervisor') {
        historyData = await _historyService.getSupervisorHistory();
      } else {
        historyData = await _historyService.getDriverHistory();
      }

      // Update lists
      incidents.value = historyData.incidents;
      inspections.value = historyData.inspections;
      checklists.value = historyData.checklists;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load history: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh History Data
  @override
  Future<void> refresh() async {
    await loadHistoryData();
  }

  /// Navigate to Inspection Details (data loads in detail page)
  void navigateToInspectionDetail(int id) {
    Get.toNamed('/history/inspection-detail', arguments: id);
  }

  /// Navigate to Checklist Details (data loads in detail page)
  void navigateToChecklistDetail(int id) {
    Get.toNamed('/history/checklist-detail', arguments: id);
  }

  /// Navigate to Incident Details (data loads in detail page)
  void navigateToIncidentDetail(int id) {
    Get.toNamed('/history/incident-detail', arguments: id);
  }

  // Getters for filtered/sorted data
  List<IncidentHistoryItem> get sortedIncidents {
    final list = List<IncidentHistoryItem>.from(incidents);
    list.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    return list;
  }

  List<InspectionHistoryItem> get sortedInspections {
    final list = List<InspectionHistoryItem>.from(inspections);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<ChecklistHistoryItem> get sortedChecklists {
    final list = List<ChecklistHistoryItem>.from(checklists);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }
}
