import 'dart:convert';

class InspectionItem {
  final int id;
  final String name;
  final String fieldType; // 'yes_no', 'good_bad'
  final int isRequired;
  String? value; // User's selection
  String? photoPath; // Photo if required

  InspectionItem({
    required this.id,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    this.value,
    this.photoPath,
  });

  factory InspectionItem.fromJson(Map<String, dynamic> json) {
    return InspectionItem(
      id: json['id'] as int,
      name: json['name'] as String,
      fieldType: json['field_type'] as String,
      isRequired: json['is_required'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'field_type': fieldType,
      'is_required': isRequired,
      'value': value,
      'photo_path': photoPath,
    };
  }

  bool get isYesNo => fieldType == 'yes_no';
  bool get isGoodBad => fieldType == 'good_bad';
  bool get isText => fieldType == 'text';
  bool get isMandatory => isRequired == 1;
  bool get isAnswered => value != null && value!.isNotEmpty;
  bool get needsPhoto => value == 'No' || value == 'Bad';
}

class InspectionSection {
  final int templateId;
  final int sectionId;
  final String sectionTitle;
  final List<InspectionItem> items;

  InspectionSection({
    required this.templateId,
    required this.sectionId,
    required this.sectionTitle,
    required this.items,
  });

  factory InspectionSection.fromJson(Map<String, dynamic> json) {
    // Parse items from JSON string
    final itemsString = json['items'] as String;
    final itemsList = jsonDecode(itemsString) as List<dynamic>;

    return InspectionSection(
      templateId: json['template_id'] as int,
      sectionId: json['section_id'] as int,
      sectionTitle: json['section_title'] as String,
      items: itemsList
          .map((item) => InspectionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template_id': templateId,
      'section_id': sectionId,
      'section_title': sectionTitle,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get totalItems => items.length;
  int get answeredItems => items.where((item) => item.isAnswered).length;
  double get progress => totalItems > 0 ? answeredItems / totalItems : 0.0;
  bool get isComplete => answeredItems == totalItems;
}

class InspectionVehicleCheckResponse {
  final List<InspectionSection> items;

  InspectionVehicleCheckResponse({required this.items});

  factory InspectionVehicleCheckResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>;
    return InspectionVehicleCheckResponse(
      items: itemsList
          .map(
            (item) => InspectionSection.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((item) => item.toJson()).toList()};
  }

  int get totalSections => items.length;
  int get completedSections =>
      items.where((section) => section.isComplete).length;
  double get overallProgress {
    if (items.isEmpty) return 0.0;
    final totalProgress = items.fold(
      0.0,
      (sum, section) => sum + section.progress,
    );
    return totalProgress / items.length;
  }
}
