class ClockInRequest {
  final int userId;
  final int vehicleId;
  final String datetime;
  final String meterReading; // File path
  final String readingPicture; // File path

  ClockInRequest({
    required this.userId,
    required this.vehicleId,
    required this.datetime,
    required this.meterReading,
    required this.readingPicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'vehicle_id': vehicleId,
      'datetime': datetime,
      'meter_reading': meterReading,
      'reading_picture': readingPicture,
    };
  }
}

class ClockOutRequest {
  final int userId;
  final int vehicleId;
  final String datetime;
  final String meterReading; // File path
  final String readingPicture; // File path

  ClockOutRequest({
    required this.userId,
    required this.vehicleId,
    required this.datetime,
    required this.meterReading,
    required this.readingPicture,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'vehicle_id': vehicleId,
      'datetime': datetime,
      'meter_reading': meterReading,
      'reading_picture': readingPicture,
    };
  }
}

class IncidentReportRequest {
  final int userId;
  final int incidentTypeId;
  final String note;
  final List<String> photos; // List of file paths

  IncidentReportRequest({
    required this.userId,
    required this.incidentTypeId,
    required this.note,
    required this.photos,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'incident_type_id': incidentTypeId,
      'note': note,
      'photos': photos,
    };
  }
}
