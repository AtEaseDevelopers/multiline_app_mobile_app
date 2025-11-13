import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'clock_controller.dart';
import '../dashboard/driver_dashboard_controller.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/searchable_dropdown.dart';
import '../../../core/values/app_strings.dart';

class ClockPage extends GetView<ClockController> {
  const ClockPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if arguments is a Map or String
    final args = Get.arguments;
    final bool isClockOut;
    final bool isMandatory;

    if (args is Map) {
      isClockOut = args['type'] == 'clockOut';
      isMandatory = args['isMandatory'] ?? false;
    } else {
      isClockOut = args == 'clockOut';
      isMandatory = false;
    }

    final meterReadingController = TextEditingController();
    final notesController = TextEditingController();

    Future<void> pickDashboardPhoto() async {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        controller.readingPicturePath.value = image.path;
      }
    }

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation if mandatory clock out
        if (isMandatory && isClockOut) {
          Get.snackbar(
            'Clock Out Required',
            'You must clock out before accessing the dashboard',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
            duration: const Duration(seconds: 3),
          );
          return false; // Prevent back navigation
        }
        return true; // Allow back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isClockOut ? SKeys.clockOut.tr : SKeys.clockIn.tr),
          automaticallyImplyLeading:
              !isMandatory, // Hide back button if mandatory
          leading: isMandatory
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show mandatory warning banner if applicable
                if (isMandatory && isClockOut)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      border: Border.all(color: Colors.orange.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clock Out Required',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You must clock out from your previous shift before accessing the dashboard.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Current Date/Time Display
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Date & Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            StreamBuilder(
                              stream: Stream.periodic(
                                const Duration(seconds: 1),
                              ),
                              builder: (context, snapshot) {
                                final now = DateTime.now();
                                final dateStr =
                                    '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
                                final timeStr =
                                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Current Vehicle/Company Info (for both clock in and clock out)
                _buildInfoCard(isClockOut),
                const SizedBox(height: 16),

                // Vehicle selection dropdown (only for clock in)
                if (!isClockOut) ...[
                  const Text(
                    'Select Vehicle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SearchableDropdown(
                    items: controller.vehicles,
                    selectedItem: controller.selectedVehicle.value,
                    itemAsString: (vehicle) {
                      if (vehicle.companyName.isEmpty) {
                        return vehicle.registrationNumber;
                      }
                      return '${vehicle.registrationNumber} - ${vehicle.companyName}';
                    },
                    onChanged: (vehicle) {
                      if (vehicle != null) {
                        controller.selectedVehicle.value = vehicle;
                      }
                    },
                    hintText: 'Choose a vehicle',
                    searchHint: 'Search by vehicle number or company...',
                    itemBuilder: (vehicle) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.registrationNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (vehicle.companyName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              vehicle.companyName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Vehicle Details Display
                  Obx(() {
                    if (controller.selectedVehicle.value != null) {
                      final vehicle = controller.selectedVehicle.value!;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Vehicle Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _VehicleInfoRow(
                              icon: Icons.confirmation_number,
                              label: 'Lorry Number',
                              value: vehicle.registrationNumber,
                            ),
                            const SizedBox(height: 8),
                            _VehicleInfoRow(
                              icon: Icons.business,
                              label: 'Company',
                              value: vehicle.companyName,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 16),
                ],

                Text(
                  '📏 ${isClockOut ? "Final Meter Reading" : SKeys.odometerReading.tr}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: meterReadingController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter meter reading (e.g., 12345.5)',
                    suffixText: 'km',
                  ),
                  onChanged: (value) {
                    // Auto-format with km suffix
                    if (value.isNotEmpty && !value.endsWith(' km')) {
                      // Just update the display, actual value is stored in controller
                    }
                  },
                ),
                const SizedBox(height: 16),

                Text(
                  '📸 ${isClockOut ? "Dashboard Photo" : "Vehicle Photo"} (Required)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (controller.readingPicturePath.value != null) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(controller.readingPicturePath.value!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              controller.readingPicturePath.value = null;
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return OutlinedButton.icon(
                      onPressed: pickDashboardPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                        isClockOut
                            ? 'Take Dashboard Photo'
                            : 'Take Vehicle Photo',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    );
                  }
                }),
                const SizedBox(height: 16),

                Text(
                  SKeys.notesOptional.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter any notes or remarks',
                  ),
                ),
                const SizedBox(height: 24),

                PrimaryButton(
                  text: isClockOut
                      ? SKeys.confirmClockOut.tr
                      : SKeys.confirmClockIn.tr,
                  fullWidth: true,
                  onPressed: () {
                    if (!isClockOut &&
                        controller.selectedVehicle.value == null) {
                      Get.snackbar(
                        'Error',
                        'Please select a vehicle',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    if (meterReadingController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter meter reading',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    if (controller.readingPicturePath.value == null) {
                      Get.snackbar(
                        'Error',
                        'Please take a photo',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }

                    // Concatenate meter reading with " km"
                    final meterReadingWithKm =
                        '${meterReadingController.text} km';

                    if (isClockOut) {
                      controller.clockOut(
                        meterReading: meterReadingWithKm,
                        readingPicturePath:
                            controller.readingPicturePath.value!,
                      );
                    } else {
                      controller.clockIn(
                        meterReading: meterReadingWithKm,
                        readingPicturePath:
                            controller.readingPicturePath.value!,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ), // Close WillPopScope
    );
  }

  // Build info card showing current vehicle and company
  Widget _buildInfoCard(bool isClockOut) {
    try {
      final dashboardController = Get.find<DriverDashboardController>();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isClockOut ? Colors.orange.shade50 : Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isClockOut ? Colors.orange.shade200 : Colors.green.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isClockOut ? Icons.access_time_filled : Icons.access_time,
                  color: isClockOut
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isClockOut ? 'Ending Shift' : 'Starting Shift',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isClockOut
                        ? Colors.orange.shade900
                        : Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.business,
              label: 'Company',
              value: dashboardController.companyName,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.group,
              label: 'Group',
              value: dashboardController.group,
            ),
          ],
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}

// Info Row Widget
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
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}

// Vehicle Info Row Widget
class _VehicleInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _VehicleInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
