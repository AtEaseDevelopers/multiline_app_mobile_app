import 'dart:convert';

/// Represents a single checklist question/item
class ChecklistItem {
  final int id;
  final String question;
  final String fieldType; // 'boolean', 'text', etc.
  final int isRequired;
  String? answer; // User's answer
  String? remarks; // Optional remarks

  ChecklistItem({
    required this.id,
    required this.question,
    required this.fieldType,
    required this.isRequired,
    this.answer,
    this.remarks,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as int,
      question: json['question'] as String,
      fieldType: json['field_type'] as String,
      isRequired: json['is_required'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'field_type': fieldType,
      'is_required': isRequired,
      'answer': answer,
      'remarks': remarks,
    };
  }

  bool get isBoolean => fieldType.toLowerCase() == 'boolean';
  bool get isYesNo => fieldType.toLowerCase() == 'yes_no';
  bool get isText => fieldType.toLowerCase() == 'text';
  bool get isMandatory => isRequired == 1;
  bool get isAnswered => answer != null && answer!.isNotEmpty;
}

/// Represents a checklist section with multiple items
class ChecklistSection {
  final int checklistSectionId;
  final String title;
  final List<ChecklistItem> items;

  ChecklistSection({
    required this.checklistSectionId,
    required this.title,
    required this.items,
  });

  factory ChecklistSection.fromJson(Map<String, dynamic> json) {
    // Parse items from JSON string
    final itemsString = json['items'] as String;
    final itemsList = jsonDecode(itemsString) as List<dynamic>;

    return ChecklistSection(
      checklistSectionId: json['checklist_section_id'] as int,
      title: json['title'] as String,
      items: itemsList
          .map((item) => ChecklistItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checklist_section_id': checklistSectionId,
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get totalItems => items.length;
  int get answeredItems => items.where((item) => item.isAnswered).length;
  double get progress => totalItems > 0 ? answeredItems / totalItems : 0.0;
  bool get isComplete => answeredItems == totalItems;
}

/// Represents the checklist template
class ChecklistTemplate {
  final int id;
  final String name;
  final String description;

  ChecklistTemplate({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) {
    return ChecklistTemplate(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }
}

/// Main response from daily-checklist API
class DailyChecklistResponse {
  final ChecklistTemplate template;
  final List<ChecklistSection> questions;

  DailyChecklistResponse({required this.template, required this.questions});

  factory DailyChecklistResponse.fromJson(Map<String, dynamic> json) {
    final template = ChecklistTemplate.fromJson(
      json['template'] as Map<String, dynamic>,
    );
    final questionsList = json['questions'] as List<dynamic>;

    return DailyChecklistResponse(
      template: template,
      questions: questionsList
          .map((q) => ChecklistSection.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'template': template.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  int get totalQuestions =>
      questions.fold(0, (sum, section) => sum + section.totalItems);
  int get answeredQuestions =>
      questions.fold(0, (sum, section) => sum + section.answeredItems);
  double get overallProgress =>
      totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;
  bool get isComplete => answeredQuestions == totalQuestions;
}

/// Model for submitting checklist response
class ChecklistResponse {
  final int checklistQuestionId;
  final String answer;
  final String? remarks;

  ChecklistResponse({
    required this.checklistQuestionId,
    required this.answer,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'checklist_question_id': checklistQuestionId,
      'answer': answer,
      'remarks': remarks,
    };
  }
}
