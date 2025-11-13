import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../data/services/activity_tracker_service.dart';
import '../../../data/services/incident_service.dart';
import '../dashboard/driver_dashboard_controller.dart';

class IncidentController extends GetxController {
  final IncidentService _incidentService = IncidentService();
  final ImagePicker _picker = ImagePicker();

  // Form fields (matching API parameters)
  final selectedTypeId = RxnInt();
  final selectedTypeName = RxnString();
  final note = ''.obs; // Changed from 'description' to match API
  final selectedPhotos = <String>[].obs;

  // Vehicle management
  final vehicles = <Vehicle>[].obs;
  final selectedVehicle = Rxn<Vehicle>();
  final isLoadingVehicles = false.obs;

  // UI state
  final isLoading = false.obs;
  final isLoadingTypes = false.obs;
  final incidentTypes = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadIncidentTypesAndVehicles();
  }

  /// Load incident types and vehicles from API
  Future<void> loadIncidentTypesAndVehicles() async {
    try {
      isLoadingTypes.value = true;
      isLoadingVehicles.value = true;

      final data = await _incidentService.getIncidentTypesAndVehicles();

      // Set incident types
      final types = data['incident_types'] as List<Map<String, dynamic>>;
      incidentTypes.value = types;

      // Auto-select first type if available
      if (types.isNotEmpty) {
        selectedTypeId.value = types.first['id'] as int;
        selectedTypeName.value = types.first['name'] as String;
      }

      // Set vehicles
      final vehicleList = data['vehicles'] as List<Vehicle>;
      vehicles.value = vehicleList;

      // Auto-select first vehicle if available
      if (vehicleList.isNotEmpty) {
        selectedVehicle.value = vehicleList.first;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingTypes.value = false;
      isLoadingVehicles.value = false;
    }
  }

  /// Load incident types from API (legacy method)
  Future<void> loadIncidentTypes() async {
    await loadIncidentTypesAndVehicles();
  }

  /// Pick photos from gallery
  Future<void> pickPhotos() async {
    try {
      if (selectedPhotos.length >= 5) {
        Get.snackbar(
          'Limit Reached',
          'Maximum 5 photos allowed',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final images = await _picker.pickMultiImage(
        limit: 5 - selectedPhotos.length,
      );
      if (images.isNotEmpty) {
        selectedPhotos.addAll(images.map((img) => img.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick photos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Take photo with camera
  Future<void> takePhoto() async {
    try {
      if (selectedPhotos.length >= 5) {
        Get.snackbar(
          'Limit Reached',
          'Maximum 5 photos allowed',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        selectedPhotos.add(image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove photo
  void removePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
    }
  }

  /// Validate form (API requires: incident_type_id, vehicle_id, note, photos)
  bool get isFormValid {
    return selectedTypeId.value != null &&
        selectedVehicle.value != null &&
        note.value.trim().isNotEmpty &&
        selectedPhotos.isNotEmpty;
  }

  /// Set selected incident type
  void setIncidentType(Map<String, dynamic> type) {
    selectedTypeId.value = type['id'] as int;
    selectedTypeName.value = type['name'] as String;
  }

  /// Submit incident report (API parameters: user_id, incident_type_id, vehicle_id, note, photos)
  Future<void> submitReport() async {
    if (!isFormValid) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields:\n• Select incident type\n• Select vehicle\n• Provide incident description\n• At least 1 photo',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get clockin_id from dashboard controller
      int? clockinId;
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        clockinId = dashboardController.clockinId;
      } catch (e) {
        // Dashboard controller might not be available
      }

      // Submit and get response
      final response = await _incidentService.submitIncidentReport(
        incidentTypeId: selectedTypeId.value!,
        vehicleId: selectedVehicle.value!.id,
        note: note.value,
        photoPaths: selectedPhotos,
        clockinId: clockinId,
      );

      // Track activity
      await ActivityTrackerService.trackIncident(
        incidentType: selectedTypeName.value ?? 'Unknown',
        location: '', // Location can be added if available
      );

      // Refresh dashboard data before showing dialog
      try {
        final dashboardController = Get.find<DriverDashboardController>();
        await dashboardController.refreshDashboard();
      } catch (e) {
        // Dashboard controller might not be available
        print('Dashboard refresh error: $e');
      }

      // Show professional dialog with response data
      await _showIncidentResponseDialog(response);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit report: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Show Professional Dialog with Response Data
  Future<void> _showIncidentResponseDialog(ApiResponse response) async {
    // Extract response data
    final responseData = response.data;

    String title = 'Incident Reported Successfully';
    String instructions = '';
    String contactNumber = '';

    // Parse response data if available
    if (responseData != null && responseData is Map<String, dynamic>) {
      if (responseData['title'] != null) {
        title = responseData['title'].toString();
      }
      if (responseData['instructions'] != null) {
        instructions = responseData['instructions'].toString();
      }
      if (responseData['contact_number'] != null) {
        contactNumber = responseData['contact_number'].toString();
      }
    }

    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Instructions (if available)
                if (instructions.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          instructions,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contact Number (if available)
                if (contactNumber.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.phone,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                contactNumber,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Copy to clipboard
                            final data = ClipboardData(text: contactNumber);
                            Clipboard.setData(data);
                            Get.snackbar(
                              'Copied',
                              'Contact number copied to clipboard',
                              backgroundColor: Colors.green.shade100,
                              colorText: Colors.green.shade900,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                              margin: const EdgeInsets.all(16),
                            );
                          },
                          icon: Icon(
                            Icons.copy,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 8),

                // Go to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.offAllNamed('/driver/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Go to Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Must use button to close
    );
  }
}
