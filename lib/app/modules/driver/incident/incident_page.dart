import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_strings.dart';
import '../../../widgets/searchable_dropdown.dart';
import 'incident_controller.dart';

class IncidentPage extends GetView<IncidentController> {
  const IncidentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.reportIncident.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Type Dropdown
              Text(
                SKeys.incidentType.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              if (controller.isLoadingTypes.value)
                const SizedBox(
                  height: 60,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading incident types...'),
                      ],
                    ),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: controller.selectedTypeId.value,
                  items: controller.incidentTypes
                      .map(
                        (type) => DropdownMenuItem<int>(
                          value: type['id'] as int,
                          child: Text(type['name'] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final type = controller.incidentTypes.firstWhere(
                        (t) => t['id'] == val,
                      );
                      controller.setIncidentType(type);
                    }
                  },
                ),
              const SizedBox(height: 16),

              // Vehicle Selection Dropdown
              const Text(
                '🚛 Select Vehicle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              if (controller.isLoadingVehicles.value)
                const SizedBox(
                  height: 60,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading vehicles...'),
                      ],
                    ),
                  ),
                )
              else if (controller.vehicles.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No vehicles available',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )
              else
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
              const SizedBox(height: 16),

              // Note/Description
              Text(
                '📝 ${SKeys.description.tr}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                minLines: 4,
                maxLines: null,
                onChanged: (v) => controller.note.value = v,
                decoration: InputDecoration(
                  hintText: 'Describe the incident in detail',
                  border: const OutlineInputBorder(),
                  counterText: '${controller.note.value.length} characters',
                ),
              ),
              const SizedBox(height: 16),

              // Photo Evidence with image picker integration
              Text(SKeys.photoEvidence.tr),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Display selected photos
                  ...controller.selectedPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photoPath = entry.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(photoPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: InkWell(
                            onTap: () => controller.removePhoto(index),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),

                  // Add photo buttons
                  if (controller.selectedPhotos.length < 5) ...[
                    InkWell(
                      onTap: () => controller.pickPhotos(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.takePhoto(),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                        controller.isFormValid && !controller.isLoading.value
                        ? () => controller.submitReport()
                        : null,
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(SKeys.submitReport.tr),
                  ),
                ),
              ),
              // Add bottom padding for device navigation buttons
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      }),
    );
  }
}
