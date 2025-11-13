class ChecklistDetailResponse {
  final ChecklistDetail? checklist;

  ChecklistDetailResponse({this.checklist});

  factory ChecklistDetailResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistDetailResponse(
      checklist: json['data']?['details'] != null
          ? ChecklistDetail.fromJson(
              json['data']['details'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ChecklistDetail {
  final int id;
  final String driver;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String companyName;
  final String? remarks;
  final List<ChecklistResponse> responses;

  ChecklistDetail({
    required this.id,
    required this.driver,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.companyName,
    this.remarks,
    this.responses = const [],
  });

  factory ChecklistDetail.fromJson(Map<String, dynamic> json) {
    return ChecklistDetail(
      id: json['id'] as int,
      driver: json['driver'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      template: json['template'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      companyName: json['company_name'] as String? ?? '',
      remarks: json['remarks'] as String?,
      responses:
          (json['responses'] as List<dynamic>?)
              ?.map(
                (e) => ChecklistResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver,
      'registration_number': registrationNumber,
      'template': template,
      'created_at': createdAt,
      'company_name': companyName,
      'remarks': remarks,
      'responses': responses.map((e) => e.toJson()).toList(),
    };
  }
}

class ChecklistResponse {
  final String sectionTitle;
  final String question;
  final String answer;
  final String? remarks;

  ChecklistResponse({
    required this.sectionTitle,
    required this.question,
    required this.answer,
    this.remarks,
  });

  factory ChecklistResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistResponse(
      sectionTitle: json['section_title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      remarks: json['remarks'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_title': sectionTitle,
      'question': question,
      'answer': answer,
      'remarks': remarks,
    };
  }
}
