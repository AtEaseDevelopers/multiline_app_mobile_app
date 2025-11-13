import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PhotoUploadField extends StatefulWidget {
  final String label;
  final int maxPhotos;
  final bool requiredField;
  final ValueChanged<List<ImageProvider>>? onPhotosChanged;
  final int initialCount;
  final ValueChanged<int>? onCountChanged;

  const PhotoUploadField({
    super.key,
    required this.label,
    this.maxPhotos = 5,
    this.requiredField = false,
    this.onPhotosChanged,
    this.initialCount = 0,
    this.onCountChanged,
  });

  @override
  State<PhotoUploadField> createState() => _PhotoUploadFieldState();
}

class _PhotoUploadFieldState extends State<PhotoUploadField> {
  List<String> _photoPaths = [];

  @override
  void initState() {
    super.initState();
    _photoPaths = [];
  }

  void _notify() {
    widget.onCountChanged?.call(_photoPaths.length);
    if (widget.onPhotosChanged != null) {
      final images = _photoPaths
          .map((p) => Image.file(File(p), fit: BoxFit.cover).image)
          .toList();
      widget.onPhotosChanged!(images);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (images.isNotEmpty) {
      setState(() {
        _photoPaths.addAll(images.map((e) => e.path));
        if (_photoPaths.length > widget.maxPhotos) {
          _photoPaths = _photoPaths.sublist(0, widget.maxPhotos);
        }
      });
      _notify();
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _photoPaths.add(image.path);
        if (_photoPaths.length > widget.maxPhotos) {
          _photoPaths = _photoPaths.sublist(0, widget.maxPhotos);
        }
      });
      _notify();
    }
  }

  void _removeAt(int index) {
    setState(() {
      _photoPaths.removeAt(index);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
            if (widget.requiredField)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Existing thumbnails
            for (int i = 0; i < _photoPaths.length; i++)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_photoPaths[i]),
                        fit: BoxFit.cover,
                        width: 64,
                        height: 64,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    top: -8,
                    child: InkWell(
                      onTap: () => _removeAt(i),
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black54,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            // Add buttons
            if (_photoPaths.length < widget.maxPhotos)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _pickFromGallery,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _takePhoto,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
