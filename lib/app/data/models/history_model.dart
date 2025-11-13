// History Models
// These models represent the structure for history data from the API
// API Response format: {data: {inspections: [], checklists: [], incidents: []}, message: "", status: true}

class HistoryResponse {
  final List<IncidentHistoryItem> incidents;
  final List<InspectionHistoryItem> inspections;
  final List<ChecklistHistoryItem> checklists;

  HistoryResponse({
    required this.incidents,
    required this.inspections,
    required this.checklists,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle the nested 'data' object from API response
    final data = json['data'] ?? json;

    return HistoryResponse(
      incidents: data['incidents'] != null
          ? (data['incidents'] as List)
                .map((item) => IncidentHistoryItem.fromJson(item))
                .toList()
          : [],
      inspections: data['inspections'] != null
          ? (data['inspections'] as List)
                .map((item) => InspectionHistoryItem.fromJson(item))
                .toList()
          : [],
      checklists: data['checklists'] != null
          ? (data['checklists'] as List)
                .map((item) => ChecklistHistoryItem.fromJson(item))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'incidents': incidents.map((item) => item.toJson()).toList(),
        'inspections': inspections.map((item) => item.toJson()).toList(),
        'checklists': checklists.map((item) => item.toJson()).toList(),
      },
    };
  }
}

// Incident History Item
// API format: {id, registration_number, incident_type, created_at}
class IncidentHistoryItem {
  final int id;
  final String registrationNumber;
  final String incidentType;
  final String createdAt;

  IncidentHistoryItem({
    required this.id,
    required this.registrationNumber,
    required this.incidentType,
    required this.createdAt,
  });

  factory IncidentHistoryItem.fromJson(Map<String, dynamic> json) {
    return IncidentHistoryItem(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      incidentType: json['incident_type'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'incident_type': incidentType,
      'created_at': createdAt,
    };
  }

  // Helper getters for UI display
  String get vehicleNumber => registrationNumber;

  String get template => incidentType; // For consistency with other types

  String get status => 'Pending'; // Incidents don't have status in API

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
  }
}

// Inspection History Item
// API format: {id, registration_number, template, created_at, status}
class InspectionHistoryItem {
  final int id;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String status;

  InspectionHistoryItem({
    required this.id,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.status,
  });

  factory InspectionHistoryItem.fromJson(Map<String, dynamic> json) {
    return InspectionHistoryItem(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      template: json['template'] ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'template': template,
      'created_at': createdAt,
      'status': status,
    };
  }

  // Helper getters for backward compatibility and UI display
  String get vehicleNumber => registrationNumber;
  String? get inspectorName => null; // Not provided in new API format
  String? get notes => null; // Not provided in new API format

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
  }
}

// Checklist History Item
// API format: {id, registration_number, template, created_at, status}
class ChecklistHistoryItem {
  final int id;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String status;

  ChecklistHistoryItem({
    required this.id,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.status,
  });

  factory ChecklistHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChecklistHistoryItem(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      template: json['template'] ?? '',
      createdAt: json['created_at'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'template': template,
      'created_at': createdAt,
      'status': status,
    };
  }

  // Helper getters for backward compatibility and UI display
  String get vehicleNumber => registrationNumber;
  int? get totalItems => null; // Not provided in new API format
  int? get completedItems => null; // Not provided in new API format

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
  }
} // Detail Response Models

class InspectionDetailResponse {
  final InspectionDetail? inspection;

  InspectionDetailResponse({this.inspection});

  factory InspectionDetailResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 InspectionDetailResponse.fromJson called with:');
    print('  JSON keys: ${json.keys.toList()}');

    final data = json['data'];
    print('  data is null: ${data == null}');

    if (data != null) {
      print('  data keys: ${(data as Map).keys.toList()}');
      final details = data['details'];
      print('  details is null: ${details == null}');

      if (details != null) {
        print('  details keys: ${(details as Map).keys.toList()}');
      }

      return InspectionDetailResponse(
        inspection: details != null ? InspectionDetail.fromJson(details) : null,
      );
    }

    // If no 'data' key, maybe the API is returning the details directly
    print('  No data key found, checking for details key directly');
    final directDetails = json['details'];
    print('  direct details is null: ${directDetails == null}');

    return InspectionDetailResponse(
      inspection: directDetails != null
          ? InspectionDetail.fromJson(directDetails)
          : null,
    );
  }
}

class InspectionDetail {
  final int id;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String companyName;
  final String? remarks;
  final List<InspectionResponse> responses;

  InspectionDetail({
    required this.id,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.companyName,
    this.remarks,
    required this.responses,
  });

  factory InspectionDetail.fromJson(Map<String, dynamic> json) {
    return InspectionDetail(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      template: json['template'] ?? '',
      createdAt: json['created_at'] ?? '',
      companyName: json['company_name'] ?? '',
      remarks: json['remarks'] as String?,
      responses: json['responses'] != null
          ? (json['responses'] as List)
                .map((item) => InspectionResponse.fromJson(item))
                .toList()
          : [],
    );
  }

  // Helper getters for UI display
  String get vehicleNumber => registrationNumber;

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
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
      sectionTitle: json['section_title'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      photo: json['photo'],
    );
  }
}

// Legacy model for backward compatibility
class InspectionCheckItem {
  final String item;
  final bool checked;
  final String? notes;

  InspectionCheckItem({required this.item, required this.checked, this.notes});

  factory InspectionCheckItem.fromJson(Map<String, dynamic> json) {
    return InspectionCheckItem(
      item: json['item'] ?? '',
      checked: json['checked'] ?? false,
      notes: json['notes'],
    );
  }
}

class ChecklistDetailResponse {
  final ChecklistDetail? checklist;

  ChecklistDetailResponse({this.checklist});

  factory ChecklistDetailResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 ChecklistDetailResponse.fromJson called with:');
    print('  JSON keys: ${json.keys.toList()}');

    final data = json['data'];
    print('  data is null: ${data == null}');

    if (data != null) {
      print('  data keys: ${(data as Map).keys.toList()}');
      final details = data['details'];
      print('  details is null: ${details == null}');

      if (details != null) {
        print('  details keys: ${(details as Map).keys.toList()}');
      }

      return ChecklistDetailResponse(
        checklist: details != null ? ChecklistDetail.fromJson(details) : null,
      );
    }

    // If no 'data' key, maybe the API is returning the details directly
    print('  No data key found, checking for details key directly');
    final directDetails = json['details'];
    print('  direct details is null: ${directDetails == null}');

    return ChecklistDetailResponse(
      checklist: directDetails != null
          ? ChecklistDetail.fromJson(directDetails)
          : null,
    );
  }
}

class ChecklistDetail {
  final int id;
  final String registrationNumber;
  final String template;
  final String createdAt;
  final String companyName;
  final String? remarks;
  final List<ChecklistResponse> responses;

  ChecklistDetail({
    required this.id,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
    required this.companyName,
    this.remarks,
    required this.responses,
  });

  factory ChecklistDetail.fromJson(Map<String, dynamic> json) {
    return ChecklistDetail(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      template: json['template'] ?? '',
      createdAt: json['created_at'] ?? '',
      companyName: json['company_name'] ?? '',
      remarks: json['remarks'] as String?,
      responses: json['responses'] != null
          ? (json['responses'] as List)
                .map((item) => ChecklistResponse.fromJson(item))
                .toList()
          : [],
    );
  }

  // Helper getters for UI display
  String get vehicleNumber => registrationNumber;

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
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
      sectionTitle: json['section_title'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      remarks: json['remarks'],
    );
  }
}

// Legacy model for backward compatibility
class ChecklistTaskItem {
  final String task;
  final bool completed;
  final String? notes;

  ChecklistTaskItem({required this.task, required this.completed, this.notes});

  factory ChecklistTaskItem.fromJson(Map<String, dynamic> json) {
    return ChecklistTaskItem(
      task: json['task'] ?? '',
      completed: json['completed'] ?? false,
      notes: json['notes'],
    );
  }
}

class IncidentDetailResponse {
  final IncidentDetail? incident;

  IncidentDetailResponse({this.incident});

  factory IncidentDetailResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 IncidentDetailResponse.fromJson called with:');
    print('  JSON keys: ${json.keys.toList()}');

    // The API client already extracts data['data'], so json is the {details: {...}} object
    final details = json['details'];
    print('  details is null: ${details == null}');

    if (details != null) {
      print('  details keys: ${(details as Map).keys.toList()}');
      print('  Creating IncidentDetail from details...');

      final incident = IncidentDetail.fromJson(details as Map<String, dynamic>);
      print('  ✅ IncidentDetail created successfully');
      print('  - ID: ${incident.id}');
      print('  - Incident Type: ${incident.incidentType}');
      print('  - Photos count: ${incident.photos.length}');

      return IncidentDetailResponse(incident: incident);
    }

    // Handle null details (no incident data)
    print('  ⚠️ Returning null incident');
    return IncidentDetailResponse(incident: null);
  }
}

class IncidentDetail {
  final int id;
  final String registrationNumber;
  final String incidentType;
  final String createdAt;
  final String companyName;
  final String remarks;
  final List<String> photos;

  IncidentDetail({
    required this.id,
    required this.registrationNumber,
    required this.incidentType,
    required this.createdAt,
    required this.companyName,
    required this.remarks,
    required this.photos,
  });

  factory IncidentDetail.fromJson(Map<String, dynamic> json) {
    return IncidentDetail(
      id: json['id'] ?? 0,
      registrationNumber: json['registration_number'] ?? '',
      incidentType: json['incident_type']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      companyName: json['company_name'] ?? '',
      remarks: json['remarks'] ?? '',
      photos: json['photos'] != null
          ? (json['photos'] as List).map((item) => item.toString()).toList()
          : [],
    );
  }

  // Helper getters for UI display
  String get vehicleNumber => registrationNumber;

  String get template => incidentType; // For consistency with other types

  String get date {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').first;
    }
  }

  String get time {
    try {
      final dateTime = DateTime.parse(createdAt);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createdAt.split(' ').length > 1 ? createdAt.split(' ')[1] : '';
    }
  }
}
