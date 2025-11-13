class InspectionDetailResponse {
  final InspectionDetail? inspection;

  InspectionDetailResponse({this.inspection});

  factory InspectionDetailResponse.fromJson(Map<String, dynamic> json) {
    return InspectionDetailResponse(
      inspection: json['data']?['details'] != null
          ? InspectionDetail.fromJson(
              json['data']['details'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class InspectionDetail {
  final int id;
  final String driver;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String companyName;
  final String? remarks;
  final List<InspectionResponse> responses;

  InspectionDetail({
    required this.id,
    required this.driver,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.companyName,
    this.remarks,
    this.responses = const [],
  });

  factory InspectionDetail.fromJson(Map<String, dynamic> json) {
    return InspectionDetail(
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
                (e) => InspectionResponse.fromJson(e as Map<String, dynamic>),
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

class InspectionResponse {
  final String sectionTitle;
  final String question;
  final String answer;
  final String? photo;

  InspectionResponse({
    required this.sectionTitle,
    required this.question,
    required this.answer,
    this.photo,
  });

  factory InspectionResponse.fromJson(Map<String, dynamic> json) {
    return InspectionResponse(
      sectionTitle: json['section_title'] as String? ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      photo: json['photo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'section_title': sectionTitle,
      'question': question,
      'answer': answer,
      'photo': photo,
    };
  }
}
