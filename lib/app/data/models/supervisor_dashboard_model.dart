class SupervisorDashboardData {
  final List<DashboardInspection> inspections;
  final List<DashboardChecklist> checklists;
  final int notificationsCount;

  SupervisorDashboardData({
    required this.inspections,
    required this.checklists,
    this.notificationsCount = 0,
  });

  factory SupervisorDashboardData.fromJson(Map<String, dynamic> json) {
    return SupervisorDashboardData(
      inspections:
          (json['inspections'] as List<dynamic>?)
              ?.map(
                (e) => DashboardInspection.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      checklists:
          (json['checklists'] as List<dynamic>?)
              ?.map(
                (e) => DashboardChecklist.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      notificationsCount: json['notifications'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspections': inspections.map((e) => e.toJson()).toList(),
      'checklists': checklists.map((e) => e.toJson()).toList(),
      'notifications': notificationsCount,
    };
  }
}

class DashboardInspection {
  final int id;
  final String driver;
  final String registrationNumber;
  final String template;
  final String createdAt;

  DashboardInspection({
    required this.id,
    required this.driver,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
  });

  factory DashboardInspection.fromJson(Map<String, dynamic> json) {
    return DashboardInspection(
      id: json['id'] as int,
      driver: json['driver'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      template: json['template'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver,
      'registration_number': registrationNumber,
      'template': template,
      'created_at': createdAt,
    };
  }
}

class DashboardChecklist {
  final int id;
  final String driver;
  final String registrationNumber;
  final String template;
  final String createdAt;

  DashboardChecklist({
    required this.id,
    required this.driver,
    required this.registrationNumber,
    required this.template,
    required this.createdAt,
  });

  factory DashboardChecklist.fromJson(Map<String, dynamic> json) {
    return DashboardChecklist(
      id: json['id'] as int,
      driver: json['driver'] as String? ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      template: json['template'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driver,
      'registration_number': registrationNumber,
      'template': template,
      'created_at': createdAt,
    };
  }
}
