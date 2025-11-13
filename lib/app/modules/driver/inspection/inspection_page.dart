import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/values/app_strings.dart';
import '../../../data/models/inspection_model.dart';
import 'inspection_controller.dart';

class InspectionPage extends GetView<InspectionController> {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SKeys.vehicleInspection.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.sections.isEmpty) {
          return const Center(child: Text('No inspection checklist available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator
              Row(
                children: [
                  Text('${SKeys.progress.tr}:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: controller.progress.value,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(controller.progress.value * 100).toStringAsFixed(0)}%',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Select All Toggle Button
              Obx(
                () => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.selectAllEnabled.value
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: controller.selectAllEnabled.value
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: controller.toggleSelectAll,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              controller.selectAllEnabled.value
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.selectAllEnabled.value
                                        ? 'All Items Selected (Pass/Good)'
                                        : 'Select All Items',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    controller.selectAllEnabled.value
                                        ? 'Tap to deselect all checks'
                                        : 'Tap to mark all as Yes/Good',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              controller.selectAllEnabled.value
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Render all sections
              ...controller.sections.asMap().entries.map((sectionEntry) {
                final sectionIndex = sectionEntry.key;
                final section = sectionEntry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.sectionTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),

                    // Render all items in this section
                    ...section.items.asMap().entries.map((itemEntry) {
                      final itemIndex = itemEntry.key;
                      final item = itemEntry.value;

                      return _InspectionItemWidget(
                        item: item,
                        sectionIndex: sectionIndex,
                        itemIndex: itemIndex,
                        controller: controller,
                      );
                    }).toList(),

                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),

              // Action buttons
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.canSubmit.value
                    ? () => controller.submit()
                    : null,
                child: Text(SKeys.continueNext.tr),
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

// Widget for individual inspection item with photo support
class _InspectionItemWidget extends StatelessWidget {
  final InspectionItem item;
  final int sectionIndex;
  final int itemIndex;
  final InspectionController controller;

  const _InspectionItemWidget({
    required this.item,
    required this.sectionIndex,
    required this.itemIndex,
    required this.controller,
  });

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();

    // Show dialog to choose camera or gallery
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Select Photo Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        controller.addPhotoToItem(sectionIndex, itemIndex, image.path);
      }
    }
  }

  List<String> _getOptions(InspectionItem item) {
    if (item.isYesNo) {
      return ['Yes', 'No'];
    } else if (item.isGoodBad) {
      return ['Good', 'Bad'];
    }
    return ['Pass', 'Fail', 'N/A'];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentItem = controller.sections[sectionIndex].items[itemIndex];

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item title and photo indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                      currentItem.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (currentItem.isMandatory)
                    const Text(
                      '* Required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Options based on field type
              if (item.isText)
                _TextInputField(
                  key: ValueKey('text_${currentItem.id}'),
                  initialValue: currentItem.value ?? '',
                  onChanged: (value) {
                    controller.updateItem(sectionIndex, itemIndex, value);
                  },
                )
              else
                Wrap(
                  spacing: 16,
                  children: _getOptions(currentItem).map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: currentItem.value == option,
                      onSelected: (_) {
                        controller.updateItem(sectionIndex, itemIndex, option);
                      },
                    );
                  }).toList(),
                ),

              // Photo section if needed
              if (currentItem.needsPhoto || currentItem.photoPath != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    if (currentItem.photoPath != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(currentItem.photoPath!),
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                controller.addPhotoToItem(
                                  sectionIndex,
                                  itemIndex,
                                  '',
                                );
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
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Add Photo'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      );
    });
  }
}

// Stateful widget for text input to prevent text reversal issue
class _TextInputField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _TextInputField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<_TextInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      decoration: InputDecoration(
        hintText: 'Enter comment...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLines: 3,
      onChanged: widget.onChanged,
    );
  }
}
